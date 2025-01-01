import 'dart:ui';

import 'package:animated_background/animated_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:zimi/widgets/ripple_animation.dart';
import '../blocs/song_bloc.dart';
import '../widgets/wave_animation.dart';
import '../widgets/recent_searches.dart';
import '../screens/lyrics_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isListening = false;
  late AnimationController _micController;
  late AnimationController _waveController;

  @override
  void initState() {
    super.initState();
    _micController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SongBloc, SongState>(
      listener: (context, state) {
        if (state is SongRecognized) {
          setState(() => _isListening = false);
          _micController.reverse();
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => LyricsScreen(song: state.song),
            ),
          );
        } else if (state is SongError) {
          // Stop animation and listening when error occurs
          setState(() => _isListening = false);
          _micController.reverse();
          
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red.withOpacity(0.8),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      },
      builder: (context, state) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.purple.shade900,
                Colors.black,
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated particles in background
              AnimatedBackground(
                behaviour: RandomParticleBehaviour(
                  options: ParticleOptions(
                    baseColor: Colors.white,
                    spawnOpacity: 0.0,
                    opacityChangeRate: 0.25,
                    minOpacity: 0.1,
                    maxOpacity: 0.3,
                    particleCount: 70,
                    spawnMaxRadius: 15.0,
                    spawnMaxSpeed: 100.0,
                    spawnMinSpeed: 30,
                    spawnMinRadius: 7.0,
                  ),
                ),
                vsync: this,
                child: const SizedBox.expand(),
              ),

              // Main content
              SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                    // Mic button with glass effect and Lottie
                    GestureDetector(
                      onTap: () {
                        if (!_isListening) {
                          setState(() => _isListening = true);
                          _micController.repeat();
                          context.read<SongBloc>().add(RecognizeSong());
                        }
                      },
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.purple.withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: _isListening
                                  ? Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        RippleAnimation(
                                          controller: _micController,
                                          color: Colors.white.withOpacity(0.3),
                                          size: 200,
                                        ),
                                        Lottie.network(
                                          'https://assets10.lottiefiles.com/packages/lf20_g7zx4ni5.json',
                                          width: 120,
                                          height: 120,
                                          repeat: true,
                                          animate: _isListening,
                                        ),
                                      ],
                                    )
                                  : Icon(
                                      Icons.mic,
                                      size: 50,
                                      color: Colors.white.withOpacity(0.9),
                                    ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),
                    // Recent searches with glass effect
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: const RecentSearches(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _micController.dispose();
    _waveController.dispose();
    super.dispose();
  }
} 