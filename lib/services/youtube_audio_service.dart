import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class YoutubeAudioService {
  final _yt = YoutubeExplode();
  final _speech = stt.SpeechToText();

  Future<void> listenToVideoAudio(String videoId) async {
    try {
      // Get audio stream URL
      final manifest = await _yt.videos.streamsClient.getManifest(videoId);
      final audioStream = manifest.audioOnly.withHighestBitrate();
      print('Audio URL: ${audioStream.url}');

      // Initialize speech recognition for audio stream
      final available = await _speech.initialize();
      if (available) {
        await _speech.listen(
          onResult: (result) {
            print('\nLyrics from song: ${result.recognizedWords}');
          },
          partialResults: true,
          listenFor: const Duration(minutes: 5),
          // soundLevel: audioStream.bitrate.bitsPerSecond / 1000, // Adjust based on audio bitrate
        );
      }
    } catch (e) {
      print('Error capturing audio: $e');
    }
  }

  void dispose() {
    _speech.stop();
    _yt.close();
  }
} 