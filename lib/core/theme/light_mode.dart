import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF4451AF),
    onPrimary: Color(0xFF1A1C2E),
    primaryContainer: Color(0xFFEEF0FA),
    onPrimaryContainer: Color(0xFF5B6480),
    secondary: Color(0xFF7986CB),
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFEFF1F9),
    onSecondaryContainer: Color(0xFF8E97B0),
    tertiary: Color(0xFFDDE1F0),
    onTertiary: Color(0xFF5B6480),
    error: Color(0xFFE53935),
    onError: Colors.white,
    background: Color(0xFFF8F9FF),
    onBackground: Color(0xFF1A1C2E),
    surface: Color(0xFFF8F9FF),
    onSurface: Color(0xFF1A1C2E),
    outline: Color(0xFFDDE1F0),
  ),

  textTheme: const TextTheme(
    headlineMedium: TextStyle(
      color: Color(0xFF1A1C2E),
      fontWeight: FontWeight.bold,
      fontFamily: 'Inter',
    ),
    bodyMedium: TextStyle(color: Color(0xFF5B6480), fontFamily: 'Inter'),
  ),
);
