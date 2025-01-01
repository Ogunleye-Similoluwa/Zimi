import 'package:flutter/material.dart';

class LoadingWave extends StatefulWidget {
  final Color color;
  final double size;

  const LoadingWave({
    super.key,
    this.color = Colors.white,
    this.size = 50.0,
  });

  @override
  State<LoadingWave> createState() => _LoadingWaveState();
}

class _LoadingWaveState extends State<LoadingWave>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _animations;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _animations = List.generate(
      3,
      (index) => Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            index * 0.2,
            0.7 + index * 0.2,
            curve: Curves.easeInOut,
          ),
        ),
      ),
    );

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => AnimatedBuilder(
          animation: _animations[index],
          builder: (context, child) {
            return Container(
              width: widget.size * 0.3,
              height: widget.size * _animations[index].value,
              margin: EdgeInsets.symmetric(horizontal: widget.size * 0.05),
              decoration: BoxDecoration(
                color: widget.color,
                borderRadius: BorderRadius.circular(widget.size * 0.15),
              ),
            );
          },
        ),
      ),
    );
  }
} 