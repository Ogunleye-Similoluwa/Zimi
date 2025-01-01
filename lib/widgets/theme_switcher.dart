// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:lottie/lottie.dart';
// import '../services/theme_service.dart';

// class ThemeSwitcher extends StatefulWidget {
//   final ThemeService themeService;

//   const ThemeSwitcher({
//     super.key,
//     required this.themeService,
//   });

//   @override
//   State<ThemeSwitcher> createState() => _ThemeSwitcherState();
// }

// class _ThemeSwitcherState extends State<ThemeSwitcher>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 500),
//     );
//     if (!widget.themeService.isDarkMode) {
//       _controller.forward();
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () async {
//         HapticFeedback.mediumImpact();
//         if (widget.themeService.isDarkMode) {
//           _controller.forward();
//         } else {
//           _controller.reverse();
//         }
//         widget.themeService.toggleTheme();
//       },
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           color: Theme.of(context).colorScheme.surface.withOpacity(0.1),
//           borderRadius: BorderRadius.circular(30),
//         ),
//         child: Lottie.network(
//           'https://assets5.lottiefiles.com/packages/lf20_theme_switch.json',
//           controller: _controller,
//           fit: BoxFit.cover,
//         ),
//       ),
//     );
//   }
// } 