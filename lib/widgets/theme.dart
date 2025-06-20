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
      colorScheme: ColorScheme.fromSwatch().copyWith(
        primary: primaryBlack,
      ),
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
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: primaryYellow,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlack, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlack, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: primaryBlack, width: 2.5),
        ),
        hintStyle: TextStyle(
          color: primaryBlack,
          fontSize: 14,
        ),
        labelStyle: TextStyle(
          color: primaryBlack,
          fontSize: 16,
        ),
        prefixIconColor: primaryBlack,
        iconColor: primaryBlack,
        focusColor: primaryBlack,
        floatingLabelStyle: TextStyle(color: primaryBlack),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlack,
          foregroundColor: primaryYellow,
          textStyle: const TextStyle(
            fontFamily: 'Borel',
            fontSize: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }
}
