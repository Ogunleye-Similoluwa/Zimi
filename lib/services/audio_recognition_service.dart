import 'package:speech_to_text/speech_to_text.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class AudioRecognitionService {
  final SpeechToText _speechToText = SpeechToText();
  String _currentWords = '';
  bool _isListening = false;

  Future<void> initialize() async {
    await _speechToText.initialize();
  }

  void startListening(YoutubePlayerController controller) {
    if (!_isListening) {
      _speechToText.listen(
        onResult: (result) {
          _currentWords = result.recognizedWords;
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
      _isListening = true;
    }
  }

  void stopListening() {
    _speechToText.stop();
    _isListening = false;
  }

  String getCurrentWords() => _currentWords;
} 