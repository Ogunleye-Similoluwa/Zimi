import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class YoutubeCaptionService {
  final _speech = stt.SpeechToText();
  bool _isListening = false;

  Future<void> listenToVideo(YoutubePlayerController controller) async {
    try {
      final available = await _speech.initialize();
      
      if (available) {
        controller.addListener(() {
          if (controller.value.isPlaying && !_isListening) {
            _startListening();
          } else if (!controller.value.isPlaying && _isListening) {
            _stopListening();
          }
        });
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _startListening() async {
    if (_isListening) return;
    
    _isListening = true;
    await _speech.listen(
      onResult: (result) {
        print('Recognized Text: ${result.recognizedWords}');
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
    );
  }

  void _stopListening() {
    _speech.stop();
    _isListening = false;
  }

  void dispose() {
    _stopListening();
  }
} 