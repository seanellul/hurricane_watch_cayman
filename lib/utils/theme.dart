import 'package:flutter/material.dart';

class AppTheme {
  // Color Palette
  static const Color navy = Color(0xFF002B49);
  static const Color stormCyan = Color(0xFF00A8C8);
  static const Color alertOrange = Color(0xFFFF6F00);
  static const Color lightGray = Color(0xFFF5F5F5);
  static const Color darkGray = Color(0xFF333333);
  static const Color white = Color(0xFFFFFFFF);

  // Hurricane Category Colors
  static const Color category1 = Color(0xFF90EE90);
  static const Color category2 = Color(0xFFFFFF00);
  static const Color category3 = Color(0xFFFFA500);
  static const Color category4 = Color(0xFFFF4500);
  static const Color category5 = Color(0xFF8B0000);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Inter',

      // Color Scheme
      colorScheme: const ColorScheme.light(
        primary: navy,
        secondary: stormCyan,
        tertiary: alertOrange,
        surface: white,
        onPrimary: white,
        onSecondary: white,
        onTertiary: white,
        onSurface: darkGray,
      ),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: white,
        ),
      ),

      // Bottom Navigation Bar Theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: white,
        selectedItemColor: navy,
        unselectedItemColor: darkGray,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card Theme
      cardTheme: CardTheme(
        color: white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          foregroundColor: white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),

      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: navy,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkGray),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: darkGray),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: navy, width: 2),
        ),
        filled: true,
        fillColor: white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),

      // Text Theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: darkGray,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: darkGray,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        titleSmall: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: darkGray,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: darkGray,
        ),
      ),
    );
  }

  static Color getHurricaneCategoryColor(int category) {
    switch (category) {
      case 1:
        return category1;
      case 2:
        return category2;
      case 3:
        return category3;
      case 4:
        return category4;
      case 5:
        return category5;
      default:
        return stormCyan;
    }
  }

  static String getHurricaneCategoryText(int category) {
    switch (category) {
      case 1:
        return 'Category 1';
      case 2:
        return 'Category 2';
      case 3:
        return 'Category 3';
      case 4:
        return 'Category 4';
      case 5:
        return 'Category 5';
      default:
        return 'Tropical Storm';
    }
  }
}
