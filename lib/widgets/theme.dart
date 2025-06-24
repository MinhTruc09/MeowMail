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
      fontFamily: 'Borel',
      colorScheme: ColorScheme.fromSwatch().copyWith(primary: primaryBlack),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 40,
          letterSpacing: 4,
          fontWeight: FontWeight.bold,
          decoration: TextDecoration.underline,
          decorationColor: primaryBlack,
          decorationThickness: 1.5,
          color: primaryBlack,
        ),
        bodyLarge: TextStyle(
          fontSize: 25,
          fontWeight: FontWeight.w400,
          color: primaryYellow,
        ),
        bodyMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: primaryBlack,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          color: primaryBlack,
        ),
      ),
      iconTheme: const IconThemeData(color: primaryYellow),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
      ),
    );
  }
}