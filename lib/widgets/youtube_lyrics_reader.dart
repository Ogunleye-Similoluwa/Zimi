import 'package:flutter/material.dart';
import 'package:flutter_lyric/lyrics_reader.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeLyricsReader extends StatefulWidget {
  final String lyrics;
  final YoutubePlayerController controller;

  const YoutubeLyricsReader({
    super.key,
    required this.lyrics,
    required this.controller,
  });

  @override
  State<YoutubeLyricsReader> createState() => _YoutubeLyricsReaderState();
}

class _YoutubeLyricsReaderState extends State<YoutubeLyricsReader> {
  late var lyricModel;
  final lyricUI = UINetease();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _initLyrics();
    widget.controller.addListener(_onPositionChanged);
  }

  void _initLyrics() {
    // Preserve all line breaks and spaces
    lyricModel = LyricsModelBuilder.create()
        .bindLyricToMain(widget.lyrics)
        .getModel();

    lyricUI
      ..defaultSize = 20
      ..defaultExtSize = 16
      ..lineGap = 24
      ..inlineGap = 12
      ..lyricAlign = LyricAlign.CENTER
      ..highlightDirection = HighlightDirection.LTR;
  }

  void _onPositionChanged() {
    if (!_initialized && widget.controller.value.isPlaying) {
      _initialized = true;
      // Add small delay to sync with video start
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) setState(() {});
      });
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LyricsReader(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      model: lyricModel,
      // Add offset to account for video buffering
      position: widget.controller.value.position.inMilliseconds - 500,
      lyricUi: lyricUI,
      playing: widget.controller.value.isPlaying,
      size: Size(double.infinity, MediaQuery.of(context).size.height / 2),
      emptyBuilder: () => Center(
        child: Text(
          "No lyrics",
          style: lyricUI.getOtherMainTextStyle(),
        ),
      ),
      selectLineBuilder: (progress, confirm) {
        return const SizedBox.shrink(); // Hide selection UI
      },
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onPositionChanged);
    super.dispose();
  }
} 