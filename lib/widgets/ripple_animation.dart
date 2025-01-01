import 'package:flutter/material.dart';

class RippleAnimation extends StatelessWidget {
  final Color color;
  final double size;
  final AnimationController controller;

  const RippleAnimation({
    super.key,
    required this.color,
    required this.size,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withOpacity(1 - controller.value),
              width: 10 * (1 - controller.value),
            ),
          ),
        );
      },
    );
  }
} 