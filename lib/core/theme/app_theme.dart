import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryLightColor = Color(0xFF4A90E2);
  static const Color primaryDarkColor = Color(0xFF2E5C9E);
  static const Color accentLightColor = Color(0xFFFF9500);
  static const Color accentDarkColor = Color(0xFFFFC107);
  static const Color backgroundLightColor = Color(0xFFF5F5F5);
  static const Color backgroundDarkColor = Color(0xFF121212);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: primaryLightColor,
      colorScheme: ColorScheme.light(
        primary: primaryLightColor,
        secondary: accentLightColor,
        background: backgroundLightColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: primaryLightColor,
        foregroundColor: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLightColor,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: primaryDarkColor,
      colorScheme: ColorScheme.dark(
        primary: primaryDarkColor,
        secondary: accentDarkColor,
        background: backgroundDarkColor,
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: backgroundDarkColor,
      ),
      scaffoldBackgroundColor: backgroundDarkColor,
      cardTheme: CardTheme(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      useMaterial3: true,
    );
  }
}