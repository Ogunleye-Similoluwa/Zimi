import 'package:flutter/foundation.dart';
import '../models/song.dart';
import 'package:flutter_acrcloud/flutter_acrcloud.dart';
import '../services/lyrics_service.dart';
import '../services/storage_service.dart';

class SongMatchingService {
  final LyricsService _lyricsService;
  final StorageService _storageService;

  SongMatchingService(this._lyricsService, this._storageService) {
    // _initializeAcrCloud();
  }

  void _initializeAcrCloud() {
    ACRCloud.setUp(
      ACRCloudConfig(
        "5b79a16696a611d361f263bdfd6968d4",
        "6gY72eAQDuvwH1ahnypDUq3sSdj5f7xZlfWmad76",
        "identify-eu-west-1.acrcloud.com"
      )
    );
  }

  Future<Song?> startRecognition() async {
    try {
      debugPrint("🎵 Starting ACRCloud recognition...");
      final session = ACRCloud.startSession();
      final result = await session.result;

      // Check if no song was found
      if (result?.metadata?.music == null || result!.metadata!.music.isEmpty) {
        debugPrint("🎵 No song found in ACRCloud result");
        session.cancel(); // Cancel the session
        return null;
      }

      final music = result.metadata!.music.first;
      
      // Get English title and artist
      String title = music.title;
      String artist = music.artists.first.name;

      final song = Song(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        artist: artist,
        albumArt: music.album.name,
        youtubeId: '',
        lyrics: '',
      );

      // Search with English title and artist
      final songs = await _lyricsService.searchSongs('${song.title} ${song.artist}');
      if (songs.isNotEmpty) {
        song.youtubeId = songs.first.youtubeId;
        song.image = songs.first.image;
        // Get lyrics using artist and title
        song.lyrics = await _lyricsService.getLyrics(song.artist, song.title);
      } else {
        debugPrint("🎵 No matching YouTube video found");
        return null; 
      }

      await _storageService.addRecentSearch(song);
      return song;
    } catch (e, stack) {
      debugPrint("🎵 Error in song recognition: $e");
      debugPrint("🎵 Stack trace: $stack");
    }
    return null;
  }

  bool get isRecording => false;
} 