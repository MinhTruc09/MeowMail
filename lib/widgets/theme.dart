import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryYellow = Color(0xFFFFCC00);

  static ThemeData get theme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: primaryWhite,
      primaryColor: primaryBlack,
      hintColor: primaryYellow,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlack,
        foregroundColor: primaryYellow,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Borel',
          fontSize: 40,
          // do the spacing more
          letterSpacing: 4,
          fontWeight: FontWeight.bold,
          // do the underline
          decoration: TextDecoration.underline,
          decorationColor: primaryBlack,
          decorationThickness: 1.5,
          color: primaryBlack,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Borel',
          fontSize: 25,
          fontWeight: FontWeight.w400,
          color: primaryYellow,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Borel',
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: primaryBlack,
        ),
      ),
      fontFamily: 'Borel',
      iconTheme: const IconThemeData(color: primaryYellow),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: primaryBlack,
        border: OutlineInputBorder(),
        hintStyle: TextStyle(color: primaryWhite),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryYellow,
          foregroundColor: primaryBlack,
          textStyle: const TextStyle(fontFamily: 'Borel'),
        ),
      ),
    );
  }
}