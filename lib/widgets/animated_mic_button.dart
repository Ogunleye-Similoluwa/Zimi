import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'music_visualizer.dart';

class AnimatedMicButton extends StatelessWidget {
  final bool isListening;
  final VoidCallback onTap;
  final AnimationController controller;

  const AnimatedMicButton({
    super.key,
    required this.isListening,
    required this.onTap,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (isListening)
              MusicVisualizer(
                isPlaying: true,
                color: Colors.white,
                barCount: 4,
              ),
            Lottie.network(
              'https://assets9.lottiefiles.com/packages/lf20_k086qctg.json',
              controller: controller,
              width: 80,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
} 