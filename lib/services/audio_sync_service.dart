import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:fftea/fftea.dart';

class AudioSyncService extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<String> _lyrics = [];
  int _currentIndex = -1;
  final int _sampleRate = 44100;
  final int _fftSize = 2048;
  
  // Audio processing
  late FFT _fft;
  List<double> _audioBuffer = [];
  
  void startSync(String audioUrl, List<String> lyrics) async {
    _lyrics = lyrics;
    _fft = FFT(_fftSize);
    await _audioPlayer.setUrl(audioUrl);
    await _audioPlayer.play();

    // Listen to position updates
    _audioPlayer.positionStream.listen((position) {
      _processAudioPosition(position);
    });
  }

  void _processAudioPosition(Duration position) {
    final progress = position.inMilliseconds / 
                    (_audioPlayer.duration?.inMilliseconds ?? 1);
    final estimatedIndex = (progress * _lyrics.length).floor();
    
    if (estimatedIndex != _currentIndex) {
      _currentIndex = estimatedIndex.clamp(0, _lyrics.length - 1);
      notifyListeners();
    }
  }

  int get currentLineIndex => _currentIndex;

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
} 