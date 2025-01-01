import 'package:flutter/material.dart';
import 'dart:math' as math;

class MusicVisualizer extends StatefulWidget {
  final bool isPlaying;
  final Color color;
  final double barCount;

  const MusicVisualizer({
    super.key,
    required this.isPlaying,
    this.color = Colors.purple,
    this.barCount = 7,
  });

  @override
  State<MusicVisualizer> createState() => _MusicVisualizerState();
}

class _MusicVisualizerState extends State<MusicVisualizer>
    with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  final _random = math.Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      widget.barCount.toInt(),
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: 300 + _random.nextInt(1000)),
      ),
    );
    _startAnimation();
  }

  void _startAnimation() {
    for (var controller in _controllers) {
      controller.repeat(reverse: true);
    }
  }

  void _stopAnimation() {
    for (var controller in _controllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(MusicVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying) {
      _startAnimation();
    } else {
      _stopAnimation();
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        _controllers.length,
        (index) => AnimatedBuilder(
          animation: _controllers[index],
          builder: (context, child) {
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              width: 4,
              height: 30 * _controllers[index].value,
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(5),
              ),
            );
          },
        ),
      ),
    );
  }
} 