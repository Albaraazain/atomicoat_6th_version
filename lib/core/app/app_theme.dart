import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Tesla-inspired color palette
  static const Color _primaryDark = Color(0xFF171A20);    // Tesla Black
  static const Color _secondaryDark = Color(0xFF333333);  // Dark Gray
  static const Color _accentRed = Color(0xFFE31937);      // Tesla Red
  static const Color _surfaceDark = Color(0xFF1F2229);    // Dark Surface
  static const Color _textLight = Color(0xFFF5F5F5);      // Light Text
  static const Color _textGray = Color(0xFFAAAAAA);       // Gray Text

  static ThemeData buildTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: _primaryDark,
        secondary: _secondaryDark,
        surface: _surfaceDark,
        onSurface: _textLight,
        error: _accentRed,
        onError: _textLight,
        background: _primaryDark,
        onBackground: _textLight,
      ),
      scaffoldBackgroundColor: _primaryDark,
      fontFamily: GoogleFonts.roboto().fontFamily,
      textTheme: _buildTextTheme(),
      appBarTheme: _buildAppBarTheme(),
      cardTheme: _buildCardTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      drawerTheme: _buildDrawerTheme(),
      iconTheme: _buildIconTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
      dividerTheme: _buildDividerTheme(),
      snackBarTheme: _buildSnackBarTheme(),
      dialogTheme: _buildDialogTheme(),
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.roboto(
        fontSize: 57,
        fontWeight: FontWeight.bold,
        color: _textLight,
      ),
      displayMedium: GoogleFonts.roboto(
        fontSize: 45,
        fontWeight: FontWeight.bold,
        color: _textLight,
      ),
      displaySmall: GoogleFonts.roboto(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: _textLight,
      ),
      headlineLarge: GoogleFonts.roboto(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: _textLight,
      ),
      headlineMedium: GoogleFonts.roboto(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: _textLight,
      ),
      headlineSmall: GoogleFonts.roboto(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: _textLight,
      ),
      bodyLarge: GoogleFonts.roboto(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: _textLight,
      ),
      bodyMedium: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.normal,
        color: _textGray,
      ),
      labelLarge: GoogleFonts.roboto(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: _textLight,
      ),
    );
  }

  static AppBarTheme _buildAppBarTheme() {
    return const AppBarTheme(
      backgroundColor: _primaryDark,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: _textLight),
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: _textLight,
      ),
    );
  }

  static CardTheme _buildCardTheme() {
    return CardTheme(
      color: _surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: _secondaryDark.withOpacity(0.2), width: 1),
      ),
      margin: const EdgeInsets.all(8),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _accentRed,
        foregroundColor: _textLight,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 16,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  static DrawerThemeData _buildDrawerTheme() {
    return const DrawerThemeData(
      backgroundColor: _surfaceDark,
      elevation: 0,
      scrimColor: Colors.black54,
    );
  }

  static IconThemeData _buildIconTheme() {
    return const IconThemeData(
      color: _textLight,
      size: 24,
    );
  }

  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: _secondaryDark.withOpacity(0.1),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accentRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accentRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: _accentRed, width: 2),
      ),
      labelStyle: TextStyle(color: _textGray),
      hintStyle: TextStyle(color: _textGray.withOpacity(0.7)),
    );
  }

  static DividerThemeData _buildDividerTheme() {
    return DividerThemeData(
      color: _secondaryDark.withOpacity(0.2),
      thickness: 1,
      space: 24,
    );
  }

  static SnackBarThemeData _buildSnackBarTheme() {
    return SnackBarThemeData(
      backgroundColor: _surfaceDark,
      contentTextStyle: const TextStyle(color: _textLight),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    );
  }

  static DialogTheme _buildDialogTheme() {
    return DialogTheme(
      backgroundColor: _surfaceDark,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      titleTextStyle: const TextStyle(
        color: _textLight,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
      contentTextStyle: const TextStyle(
        color: _textGray,
        fontSize: 16,
      ),
    );
  }
}