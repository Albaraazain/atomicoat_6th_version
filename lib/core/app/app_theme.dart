// lib/core/app/app_theme.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: Color(0xFF2C2C2C),
        secondary: Color(0xFF4A4A4A),
        surface: Color(0xFF1E1E1E),
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: const Color(0xFF121212),
      fontFamily: GoogleFonts.roboto().fontFamily,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      drawerTheme: _buildDrawerTheme(),
      iconTheme: _buildIconTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      dividerTheme: _buildDividerTheme(),
    );
  }

  // ... [Keep all your existing theme building methods, just move them here]
  static TextTheme _buildTextTheme() { /* ... */ }
  static AppBarTheme _buildAppBarTheme() { /* ... */ }
  static CardTheme _buildCardTheme() { /* ... */ }
  static ElevatedButtonThemeData _buildElevatedButtonTheme() { /* ... */ }
  static DrawerThemeData _buildDrawerTheme() { /* ... */ }
  static IconThemeData _buildIconTheme() { /* ... */ }
  static InputDecorationTheme _buildInputDecorationTheme() { /* ... */ }
  static DividerThemeData _buildDividerTheme() { /* ... */ }
}