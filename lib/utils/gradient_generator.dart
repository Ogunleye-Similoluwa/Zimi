import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientGenerator {
  static final List<LinearGradient> allGradients = [
    // Vibrant Gradients
    _createGradient([const Color(0xFF8A2387), const Color(0xFFE94057), const Color(0xFFF27121)]),
    _createGradient([const Color(0xFF4158D0), const Color(0xFFC850C0), const Color(0xFFFFCC70)]),
    _createGradient([const Color(0xFFFA8BFF), const Color(0xFF2BD2FF), const Color(0xFF2BFF88)]),
    _createGradient([const Color(0xFFFF3CAC), const Color(0xFF784BA0), const Color(0xFF2B86C5)]),
    
    // Elegant Gradients
    _createGradient([const Color(0xFF0B486B), const Color(0xFFF56217)]),
    _createGradient([const Color(0xFFCC2B5E), const Color(0xFF753A88)]),
    _createGradient([const Color(0xFF1A2980), const Color(0xFF26D0CE)]),
    _createGradient([const Color(0xFF4B6CB7), const Color(0xFF182848)]),
    
    // Neon Gradients
    _createGradient([const Color(0xFF00F5A0), const Color(0xFF00D9F5)]),
    _createGradient([const Color(0xFFFF00CC), const Color(0xFF333399)]),
    _createGradient([const Color(0xFF08AEEA), const Color(0xFF2AF598)]),
    _createGradient([const Color(0xFFFBDA61), const Color(0xFFFF5ACD)]),
    
    // Dark Gradients
    _createGradient([const Color(0xFF434343), const Color(0xFF000000)]),
    _createGradient([const Color(0xFF093028), const Color(0xFF237A57)]),
    _createGradient([const Color(0xFF16222A), const Color(0xFF3A6073)]),
    _createGradient([const Color(0xFF1F1C2C), const Color(0xFF928DAB)]),
  ];

  static LinearGradient _createGradient(List<Color> colors) {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  static LinearGradient getRandomGradient() {
    final random = math.Random();
    return allGradients[random.nextInt(allGradients.length)];
  }

  static LinearGradient generateFromImage(ImageProvider image) {
    // TODO: Implement palette generation from image
    return getRandomGradient();
  }
} 