import 'package:flutter/material.dart';

const Color nudgePrimary = Color(0xFF5E60CE);

class AppTheme {
  static ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: nudgePrimary,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF7F7FB),
  );

  static ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF767AF5),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF101014),
  );

  // Splash themes (kept exactly the same)
  static ThemeData splashLight = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    useMaterial3: true,
  );

  static ThemeData splashDark = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF171A1F),
    useMaterial3: true,
  );
}