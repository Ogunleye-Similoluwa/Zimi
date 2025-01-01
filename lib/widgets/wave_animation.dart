import 'package:flutter/material.dart';
import 'package:wave/wave.dart';
import 'package:wave/config.dart';

class WaveAnimation extends StatelessWidget {
  final AnimationController controller;
  final bool isActive;

  const WaveAnimation({
    super.key,
    required this.controller,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.0,
      child: WaveWidget(
        config: CustomConfig(
          gradients: [
            [
              Colors.white.withOpacity(0.1),
              Colors.white.withOpacity(0.2),
            ],
            [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.2),
            ],
            [
              Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              Theme.of(context).colorScheme.secondary.withOpacity(0.2),
            ],
          ],
          durations: [35000, 19440, 10800],
          heightPercentages: [0.20, 0.23, 0.25],
          gradientBegin: Alignment.bottomLeft,
          gradientEnd: Alignment.topRight,
        ),
        backgroundColor: Colors.transparent,
        size: const Size(double.infinity, double.infinity),
        waveAmplitude: 20,
      ),
    );
  }
} 