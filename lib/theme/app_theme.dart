import 'package:flutter/material.dart';

class AppTheme {
  // Spotify renk paleti
  static const Color primaryGreen = Color(0xFF1DB954);
  static const Color primaryGreenLight = Color(0xFF1ED760);
  static const Color backgroundBlack = Color(0xFF121212);
  static const Color surfaceBlack = Color(0xFF282828);
  static const Color surfaceLight = Color(0xFF3E3E3E);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB3B3B3);
  static const Color dividerGrey = Color(0xFF404040);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: backgroundBlack,
      
      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        secondary: primaryGreenLight,
        surface: surfaceBlack,
        error: Colors.redAccent,
        onPrimary: Colors.black,
        onSecondary: Colors.black,
        onSurface: textWhite,
      ),
      
      // AppBar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundBlack,
        foregroundColor: textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: surfaceBlack,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      
      // FloatingActionButton theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryGreen,
        foregroundColor: Colors.black,
      ),
      
      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBlack,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        hintStyle: const TextStyle(color: textGrey),
        prefixIconColor: textGrey,
      ),
      
      // Bottom navigation bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: backgroundBlack,
        selectedItemColor: primaryGreen,
        unselectedItemColor: textGrey,
        type: BottomNavigationBarType.fixed,
      ),
      
      // Icon theme
      iconTheme: const IconThemeData(
        color: textWhite,
      ),
      
      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: textWhite,
          fontSize: 32,
          fontWeight: FontWeight.bold,
        ),
        headlineMedium: TextStyle(
          color: textWhite,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        titleLarge: TextStyle(
          color: textWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: textWhite,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: textWhite,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: textGrey,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: textGrey,
          fontSize: 12,
        ),
      ),
      
      // Slider theme for music player
      sliderTheme: const SliderThemeData(
        activeTrackColor: primaryGreen,
        inactiveTrackColor: surfaceLight,
        thumbColor: primaryGreen,
        overlayColor: Color(0x291DB954),
      ),
      
      // List tile theme
      listTileTheme: const ListTileThemeData(
        iconColor: textWhite,
        textColor: textWhite,
      ),
      
      // Dialog theme
      dialogTheme: DialogTheme(
        backgroundColor: surfaceBlack,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Snackbar theme
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceBlack,
        contentTextStyle: const TextStyle(color: textWhite),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
