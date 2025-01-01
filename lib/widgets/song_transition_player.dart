import 'package:flutter/material.dart';
import '../models/song.dart';

class SongTransitionPlayer extends StatefulWidget {
  final Song currentSong;
  final Song? nextSong;
  final Duration crossfadeDuration;
  final VoidCallback onTransitionComplete;

  const SongTransitionPlayer({
    super.key,
    required this.currentSong,
    this.nextSong,
    this.crossfadeDuration = const Duration(seconds: 3),
    required this.onTransitionComplete,
  });

  @override
  State<SongTransitionPlayer> createState() => _SongTransitionPlayerState();
}

class _SongTransitionPlayerState extends State<SongTransitionPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _currentSongFade;
  late Animation<double> _nextSongFade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.crossfadeDuration,
      vsync: this,
    );

    _currentSongFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    _nextSongFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    if (widget.nextSong != null) {
      _controller.forward().then((_) {
        widget.onTransitionComplete();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Current Song
        FadeTransition(
          opacity: _currentSongFade,
          child: _buildSongCard(widget.currentSong),
        ),
        
        // Next Song
        if (widget.nextSong != null)
          FadeTransition(
            opacity: _nextSongFade,
            child: _buildSongCard(widget.nextSong!),
          ),
      ],
    );
  }

  Widget _buildSongCard(Song song) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              song.albumArt,
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  song.artist,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 