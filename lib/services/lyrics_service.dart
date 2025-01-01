import 'package:genius_lyrics/genius_lyrics.dart' as genius;
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/song.dart';
import '../models/timed_lyrics.dart';

class LyricsService {
  final String _youtubeBaseUrl = 'https://youtube.googleapis.com/youtube/v3';
  final String _lyricsBaseUrl = 'https://api.lyrics.ovh/v1';
  final String _apiKey = 'AIzaSyCoxJ2v2eGXgxVjjnWiYB4YD1OLyPV2AmQ';

  Future<List<Song>> searchSongs(String query) async {
    try {
      print('Searching songs with query: $query');
      
      final url = '$_youtubeBaseUrl/search?part=snippet&type=video&videoCategoryId=10'
          '&maxResults=20&q=$query music&key=$_apiKey';
      
      final response = await http.get(Uri.parse(url));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['items'] == null) return [];

        return (data['items'] as List).map((item) {
          String title = item['snippet']['title']
              .replaceAll(RegExp(r'\(Official.*?\)'), '')
              .replaceAll(RegExp(r'\[Official.*?\]'), '')
              .replaceAll(RegExp(r'\(Lyric.*?\)'), '')
              .replaceAll(RegExp(r'\[Lyric.*?\]'), '')
              .replaceAll(RegExp(r'\(Audio.*?\)'), '')
              .replaceAll(RegExp(r'\[Audio.*?\]'), '')
              .replaceAll(RegExp(r'\(Music.*?\)'), '')
              .replaceAll(RegExp(r'\[Music.*?\]'), '')
              .trim();

          String artist = item['snippet']['channelTitle'];
          if (title.contains('-')) {
            final parts = title.split('-');
            if (parts.length == 2) {
              artist = parts[0].trim();
              title = parts[1].trim();
            }
          }

          return Song(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            artist: artist,
            image: item['snippet']['thumbnails']['high']['url'],
            albumArt: item['snippet']['thumbnails']['high']['url'],
            youtubeId: item['id']['videoId'],
            lyrics: '',
          );
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error searching songs: $e');
      return [];
    }
  }

  Future<String> getLyrics(String artist, String title) async {
    try {
      final encodedArtist = Uri.encodeComponent(artist);
      final encodedTitle = Uri.encodeComponent(title);
      
      // First try to get synced lyrics
      final syncedUrl = 'https://lrclib.net/api/get?artist_name=$encodedArtist&track_name=$encodedTitle';
      final response = await http.get(Uri.parse(syncedUrl));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null && data['syncedLyrics'] != null) {
          return data['syncedLyrics'];
        }
      }
      
      // Fallback to regular lyrics
      final geniusClient = genius.Genius(accessToken: "_DLFHwVQwXTmGGxDpxwEGB1sycE68wM8xwTKVdxYxKNQBMdPIBBlqpl1V2Jhis-O");

    try {
      // First try lyrics.ovh
      try {
        final encodedArtist = Uri.encodeComponent(artist.trim());
        final encodedTitle = Uri.encodeComponent(title.trim());
        final url = '$_lyricsBaseUrl/$encodedArtist/$encodedTitle';
        
        final response = await http.get(Uri.parse(url))
            .timeout(const Duration(seconds: 6));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final lyrics = data['lyrics'];
          if (lyrics != null && lyrics.toString().isNotEmpty) {
            return _convertToTimedFormat(lyrics);
          }
        }
      } catch (e) {
        print('lyrics.ovh failed: $e');
      }

      // Fallback to Genius
      try {
        final song = await geniusClient.searchSong(
          artist: artist, 
          title: title,
        );
        
        if (song != null && song.lyrics!.isNotEmpty) {
          return _convertToTimedFormat(song.lyrics!);
        }
      } catch (e) {
        print('Genius API failed: $e');
      }

      return 'No lyrics found for this song';
    } catch (e) {
      print('Error getting lyrics: $e');
      return 'Error fetching lyrics';
    }
    } catch (e) {
      print('Error getting lyrics: $e');
      return '';
    }
  }



   Future<String> getLyrics1(String artist, String title) async {
    final geniusClient = genius.Genius(accessToken: "_DLFHwVQwXTmGGxDpxwEGB1sycE68wM8xwTKVdxYxKNQBMdPIBBlqpl1V2Jhis-O");

    try {
      // First try lyrics.ovh
      try {
        final encodedArtist = Uri.encodeComponent(artist.trim());
        final encodedTitle = Uri.encodeComponent(title.trim());
        final url = '$_lyricsBaseUrl/$encodedArtist/$encodedTitle';
        
        final response = await http.get(Uri.parse(url))
            .timeout(const Duration(seconds: 6));
        
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final lyrics = data['lyrics'];
          if (lyrics != null && lyrics.toString().isNotEmpty) {
            return _convertToTimedFormat(lyrics);
          }
        }
      } catch (e) {
        print('lyrics.ovh failed: $e');
      }

      // Fallback to Genius
      try {
        final song = await geniusClient.searchSong(
          artist: artist, 
          title: title,
        );
        
        if (song != null && song.lyrics!.isNotEmpty) {
          return _convertToTimedFormat(song.lyrics!);
        }
      } catch (e) {
        print('Genius API failed: $e');
      }

      return 'No lyrics found for this song';
    } catch (e) {
      print('Error getting lyrics: $e');
      return 'Error fetching lyrics';
    }
  }


  String _convertToTimedFormat(String lyrics) {
    // Convert regular lyrics to LRC format with estimated timestamps
    final lines = lyrics.split('\n');
    final timedLyrics = <String>[];
    int timeInSeconds = 0;
    
    for (final line in lines) {
      if (line.trim().isNotEmpty) {
        final minutes = (timeInSeconds / 60).floor();
        final seconds = timeInSeconds % 60;
        final timestamp = '[${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.00]';
        timedLyrics.add('$timestamp$line');
        timeInSeconds += 3; // Estimate 3 seconds per line
      }
    }
    
    return timedLyrics.join('\n');
  }
} 