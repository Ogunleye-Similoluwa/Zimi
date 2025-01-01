import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/timed_lyrics.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class SynchronizedLyrics extends StatefulWidget {
  final List<LyricsLine> lyrics;
  final Duration currentTime;
  final bool isPlaying;
  final YoutubePlayerController? controller;

  const SynchronizedLyrics({
    super.key,
    required this.lyrics,
    required this.currentTime,
    required this.isPlaying,
    required this.controller,
  });

  @override
  State<SynchronizedLyrics> createState() => _SynchronizedLyricsState();
}

class _SynchronizedLyricsState extends State<SynchronizedLyrics> {
  final ScrollController _scrollController = ScrollController();
  int _currentLineIndex = 0;

  @override
  void didUpdateWidget(SynchronizedLyrics oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _updateCurrentLine();
    }
  }

  void _updateCurrentLine() {
    if (widget.lyrics.isEmpty) return;

    int newIndex = widget.lyrics.indexWhere((line) {
      return line.timestamp != null && line.timestamp! > widget.currentTime;
    });
    
    if (newIndex > 0) newIndex--;
    else if (newIndex == -1) {
      newIndex = widget.lyrics.length - 1;
    }

    if (newIndex != _currentLineIndex) {
      setState(() => _currentLineIndex = newIndex);
      // Use post-frame callback to ensure ListView is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToCurrentLine();
      });
    }
  }

  void _scrollToCurrentLine() {
    if (!_scrollController.hasClients) return;
    
    try {
      _scrollController.animateTo(
        _currentLineIndex * 60.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } catch (e) {
      print('Scroll error: $e');
    }
  }

  void _seekToLyric(LyricsLine line) {
    if (line.timestamp != null && widget.controller != null) {
      widget.controller!.seekTo(line.timestamp!);
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: widget.lyrics.length,
      itemBuilder: (context, index) {
        final line = widget.lyrics[index];
        final isCurrentLine = index == _currentLineIndex;
        
        return GestureDetector(
          onTap: () => _seekToLyric(line),
          child: Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isCurrentLine ? 20 : 16,
                  color: isCurrentLine ? Colors.white : Colors.white.withOpacity(0.7),
                  fontWeight: isCurrentLine ? FontWeight.bold : FontWeight.normal,
                ),
                child: Text(
                  line.text,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
} 