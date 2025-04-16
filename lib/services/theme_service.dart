import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const String _themeKey = 'theme_mode';
  static SharedPreferences? _prefs;
  
  // Initialize once for better performance
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }
  
  static Future<ThemeMode> getThemeMode() async {
    await init();
    final isDark = _prefs!.getBool(_themeKey) ?? false;
    return isDark ? ThemeMode.dark : ThemeMode.light;
  }
  
  static Future<bool> saveThemeMode(bool isDark) async {
    await init();
    // Update status bar color based on theme
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
    ));
    return await _prefs!.setBool(_themeKey, isDark);
  }
  
  static ThemeData getLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      primaryColor: Color(0xFF1E88E5),
      colorScheme: ColorScheme.light(
        primary: Color(0xFF1E88E5),
        secondary: Color(0xFF26A69A),
        error: Color(0xFFE53935),
        background: Colors.white,
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF1E88E5),
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
  
  static ThemeData getDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      primaryColor: Color(0xFF1A237E),
      colorScheme: ColorScheme.dark(
        primary: Color(0xFF3949AB),
        secondary: Color(0xFF00897B),
        error: Color(0xFFE57373),
        background: Color(0xFF121212),
        surface: Color(0xFF1E1E1E),
      ),
      scaffoldBackgroundColor: Color(0xFF121212),
      appBarTheme: AppBarTheme(
        backgroundColor: Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF3949AB),
          foregroundColor: Colors.white,
        ),
      ),
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
