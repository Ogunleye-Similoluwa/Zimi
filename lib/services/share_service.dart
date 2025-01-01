import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/song.dart';

class ShareService {
  Future<void> shareSong(Song song) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/album_art.jpg');
      
      // Download and save album art
      final response = await http.get(Uri.parse(song.albumArt));
      await file.writeAsBytes(response.bodyBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Check out "${song.title}" by ${song.artist}!',
        subject: 'Sharing a song from Lyrics Sync',
      );
    } catch (e) {
      // Fallback to text-only sharing
      await Share.share(
        'Check out "${song.title}" by ${song.artist}!',
        subject: 'Sharing a song from Lyrics Sync',
      );
    }
  }

  Future<void> sharePlaylist(String playlistName, List<Song> songs) async {
    final songList = songs.map((s) => '${s.title} - ${s.artist}').join('\n');
    await Share.share(
      'Check out my playlist "$playlistName":\n\n$songList',
      subject: 'Sharing a playlist from Lyrics Sync',
    );
  }
} 