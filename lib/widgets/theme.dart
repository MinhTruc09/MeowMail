import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlack = Color(0xFF000000);
  static const Color primaryWhite = Color(0xFFFFFFFF);
  static const Color primaryYellow = Color(0xFFFFCC00);

  // Personalization constants for easy reuse
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultRadius = 12.0;
  static const double avatarRadius = 32.0;
  static const double iconSize = 24.0;
  static const double titleFontSize = 22.0;
  static const double bodyFontSize = 16.0;
  static const double labelFontSize = 14.0;

  // Responsive helpers
  static double screenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;
  static double screenHeight(BuildContext context) =>
      MediaQuery.of(context).size.height;
  static double responsiveWidth(BuildContext context, double percent) =>
      screenWidth(context) * percent;
  static double responsiveHeight(BuildContext context, double percent) =>
      screenHeight(context) * percent;

  // Responsive font sizes
  static double responsiveFontSize(BuildContext context, double baseFontSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseFontSize * 0.85;
    if (screenWidth < 400) return baseFontSize * 0.9;
    if (screenWidth > 600) return baseFontSize * 1.1;
    return baseFontSize;
  }

  // Responsive padding
  static double responsivePadding(BuildContext context, double basePadding) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return basePadding * 0.8;
    if (screenWidth > 600) return basePadding * 1.2;
    return basePadding;
  }

  // Responsive radius
  static double responsiveRadius(BuildContext context, double baseRadius) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth < 360) return baseRadius * 0.8;
    if (screenWidth > 600) return baseRadius * 1.2;
    return baseRadius;
  }

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
        labelLarge: TextStyle(fontSize: 14, color: primaryBlack),
      ),
      iconTheme: const IconThemeData(color: primaryYellow),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryYellow,
        foregroundColor: primaryBlack,
      ),
    );
  }
}
