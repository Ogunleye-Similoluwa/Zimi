import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class ThemeService extends ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isDarkMode = true;
  final Color _accentColor = Colors.pinkAccent;
  final Color _lightPrimary = const Color(0xFF2196F3); // Material Blue

  bool get isDarkMode => _isDarkMode;

  ThemeService() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    _prefs = await SharedPreferences.getInstance();
    _isDarkMode = _prefs.getBool('darkMode') ?? true;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _prefs.setBool('darkMode', _isDarkMode);
    notifyListeners();
  }

  ThemeData get theme => ThemeData(
    useMaterial3: true,
    brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _isDarkMode ? _accentColor : _lightPrimary,
      brightness: _isDarkMode ? Brightness.dark : Brightness.light,
    ).copyWith(
      background: _isDarkMode ? const Color(0xFF121212) : Colors.white,
      surface: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      primary: _isDarkMode ? _accentColor : _lightPrimary,
      secondary: _isDarkMode ? _accentColor : _lightPrimary,
    ),
    scaffoldBackgroundColor: _isDarkMode ? const Color(0xFF121212) : Colors.white,
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      selectedItemColor: _isDarkMode ? _accentColor : _lightPrimary,
      unselectedItemColor: _isDarkMode ? Colors.white60 : Colors.black54,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(
        color: _isDarkMode ? Colors.white : Colors.black,
      ),
      titleTextStyle: GoogleFonts.poppins(
        color: _isDarkMode ? Colors.white : Colors.black,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardTheme(
      color: _isDarkMode ? const Color(0xFF2D2D2D) : Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    textTheme: GoogleFonts.poppinsTextTheme(
      _isDarkMode ? ThemeData.dark().textTheme : ThemeData.light().textTheme,
    ),
    iconTheme: IconThemeData(
      color: _isDarkMode ? Colors.white : Colors.black87,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return _isDarkMode ? _accentColor : _lightPrimary;
        }
        return null;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return (_isDarkMode ? _accentColor : _lightPrimary).withOpacity(0.5);
        }
        return null;
      }),
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: _isDarkMode ? _accentColor : _lightPrimary,
      thumbColor: _isDarkMode ? _accentColor : _lightPrimary,
      inactiveTrackColor: (_isDarkMode ? _accentColor : _lightPrimary).withOpacity(0.2),
    ),
    dividerTheme: DividerThemeData(
      color: _isDarkMode ? Colors.white12 : Colors.black12,
    ),
    listTileTheme: ListTileThemeData(
      iconColor: _isDarkMode ? Colors.white70 : Colors.black87,
      textColor: _isDarkMode ? Colors.white : Colors.black,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: _isDarkMode ? const Color(0xFF1E1E1E) : Colors.white,
      indicatorColor: (_isDarkMode ? _accentColor : _lightPrimary).withOpacity(0.1),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: _isDarkMode ? _accentColor : _lightPrimary);
        }
        return IconThemeData(
          color: _isDarkMode ? Colors.white60 : Colors.black54,
        );
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return TextStyle(color: _isDarkMode ? _accentColor : _lightPrimary);
        }
        return TextStyle(
          color: _isDarkMode ? Colors.white60 : Colors.black54,
        );
      }),
    ),
  );

  LinearGradient get backgroundGradient => _isDarkMode 
    ? const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2D0036),  // Dark purple
          Color(0xFF1A1A1A),  // Dark background
        ],
      )
    : const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF2196F3),  // Material Blue
          Color(0xFF64B5F6),  // Lighter Blue
        ],
      );

  Color get bottomNavColor => _isDarkMode 
    ? const Color(0xFF1A1A1A)
    : const Color(0xFF1565C0);  // Darker Blue
} 