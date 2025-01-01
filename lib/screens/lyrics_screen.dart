import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:zimi/main.dart';
import 'package:zimi/widgets/add_to_playlist_dialog.dart';
import 'package:zimi/widgets/synchronized_lyrics.dart';
import '../models/song.dart';
import '../models/timed_lyrics.dart';
import '../blocs/song_bloc.dart';
import '../services/theme_service.dart';
import '../utils/gradient_generator.dart';

class LyricsScreen extends StatefulWidget {
  final Song song;
  const LyricsScreen({super.key, required this.song});

  @override
  State<LyricsScreen> createState() => _LyricsScreenState();
}

class _LyricsScreenState extends State<LyricsScreen> {
  YoutubePlayerController? _controller;
  final ScrollController _scrollController = ScrollController();
  Duration _currentPosition = Duration.zero;
  List<LyricsLine> _syncedLyrics = [];
  bool _isVideoReady = false;
  int _activeLyricIndex = 0;
  bool get isPlayingFromPlaylist => context.read<SongBloc>().queue.length > 1;
  late LinearGradient _currentGradient;
  Timer? _gradientTimer;

  @override
  void initState() {
    super.initState();
    _initYoutubePlayer();
    _loadSyncedLyrics();
    _controller?.addListener(() {
      if (_controller?.value.playerState == PlayerState.ended) {
        context.read<SongBloc>().playNext();
      }
    });
    _currentGradient = GradientGenerator.getRandomGradient();
    _startGradientAnimation();
  }

  void _initYoutubePlayer() async {
    if (widget.song.youtubeId.isNotEmpty) {
      _controller = YoutubePlayerController(
        initialVideoId: widget.song.youtubeId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );

      // Add listeners separately
      _controller!.addListener(_onPositionChanged);
      _controller!.addListener(_onVideoEnd);

      setState(() => _isVideoReady = true);
    }
  }

  void _onPositionChanged() {
    if (!mounted) return;
    
    setState(() {
      _currentPosition = _controller?.value.position ?? Duration.zero;
      _updateActiveLyric();
    });
  }

  void _updateActiveLyric() {
    if (_syncedLyrics.isEmpty) return;
    
    final currentTime = _currentPosition;
    int newIndex = _syncedLyrics.indexWhere((lyric) {
      return lyric.timestamp != null && lyric.timestamp! > currentTime;
    });
    
    if (newIndex == -1) {
      newIndex = _syncedLyrics.length - 1;
    } else if (newIndex > 0) {
      newIndex--;
    }
    
    if (newIndex != _activeLyricIndex) {
      setState(() => _activeLyricIndex = newIndex);
      _scrollToActiveLyric();
    }
  }

  void _scrollToActiveLyric() {
    if (_activeLyricIndex < 0) return;
    
    _scrollController.animateTo(
      _activeLyricIndex * 60.0, // Approximate height of each lyric line
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _loadSyncedLyrics() {
    if (widget.song.lyrics.isEmpty) {
      _syncedLyrics = [];
      return;
    }

    _syncedLyrics = widget.song.lyrics
        .split('\n')
        .where((line) => line.trim().isNotEmpty)
        .map((line) => LyricsLine.fromLRC(line))
        .toList();

    // Sort by timestamp
    _syncedLyrics.sort((a, b) {
      if (a.timestamp == null) return 1;
      if (b.timestamp == null) return -1;
      return a.timestamp!.compareTo(b.timestamp!);
    });
  }

  void _onVideoEnd() {
    if (_controller?.value.playerState == PlayerState.ended) {
      _controller!.seekTo(Duration.zero);
      _controller!.play();
      setState(() {
        _currentPosition = Duration.zero;
        _activeLyricIndex = 0;
      });
    }
  }

  void _startGradientAnimation() {
    _gradientTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (mounted) {
        setState(() {
          _currentGradient = GradientGenerator.getRandomGradient();
        });
      }
    });
  }

  @override
  void dispose() {
    // First cancel timers and animations
    _gradientTimer?.cancel();
    _scrollController.dispose();

    // Handle YouTube player disposal properly
    if (_controller != null) {
      // First remove all listeners to prevent callbacks after disposal
      _controller!.removeListener(_onPositionChanged);
      _controller!.removeListener(_onVideoEnd);
      
      // Pause the video
      _controller!.pause();
      
      // Use a delayed disposal for iOS
      if (Platform.isIOS) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            _controller?.dispose();
          }
        });
      } else {
        _controller?.dispose();
      }
    }

    super.dispose();
  }

  @override
  void deactivate() {
    // Pause video when navigating away
    if (Platform.isIOS) {
      _controller?.pause();
    }
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 1500),
        decoration: BoxDecoration(
          gradient: _currentGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // App Bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'PLAYING FROM YOUTUBE',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 12,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.song.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showOptionsMenu(context),
                    ),
                    if (isPlayingFromPlaylist) ...[
                      IconButton(
                        icon: const Icon(Icons.skip_previous, color: Colors.white),
                        onPressed: () => context.read<SongBloc>().playPrevious(),
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.white),
                        onPressed: () => context.read<SongBloc>().playNext(),
                      ),
                    ],
                  ],
                ),
              ),

              // YouTube Player with styling
              if (_isVideoReady && _controller != null)
                Container(
                  height: 220,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: YoutubePlayer(
                      controller: _controller!,
                      showVideoProgressIndicator: true,
                      progressColors: const ProgressBarColors(
                        playedColor: Colors.white,
                        handleColor: Colors.white,
                        bufferedColor: Colors.white24,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                ),

              // Add a small gap between video and lyrics
              const SizedBox(height: 16),

              // Lyrics section
              Expanded(
                child: SynchronizedLyrics(
                  lyrics: _syncedLyrics,
                  currentTime: _currentPosition,
                  isPlaying: _controller?.value.isPlaying ?? false,
                  controller: _controller,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => BlocBuilder<SongBloc, SongState>(
        builder: (context, state) {
          return FutureBuilder<bool>(
            future: context.read<SongBloc>().isFavorite(widget.song),
            builder: (context, snapshot) {
              final isFavorite = snapshot.data ?? false;
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
                    title: Text(isFavorite ? 'Remove from Favorites' : 'Add to Favorites'),
                    onTap: () {
                      context.read<SongBloc>().add(ToggleFavorite(widget.song));
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.playlist_add),
                    title: const Text('Add to Playlist'),
                    onTap: () {
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) => AddToPlaylistDialog(song: widget.song),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.share),
                    title: const Text('Share'),
                    onTap: () {
                      context.read<SongBloc>().add(ShareSong(widget.song));
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}