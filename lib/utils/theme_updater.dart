// Theme Updater Utility
// This file contains constants and helpers to ensure consistent theme usage

import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class ThemeUpdater {
  // Standard SnackBar styles following app theme
  static SnackBar successSnackBar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: AppTheme.primaryBlack,
          fontFamily: 'Borel',
        ),
      ),
      backgroundColor: AppTheme.primaryYellow,
      behavior: SnackBarBehavior.floating,
    );
  }

  static SnackBar errorSnackBar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: AppTheme.primaryWhite,
          fontFamily: 'Borel',
        ),
      ),
      backgroundColor: AppTheme.primaryBlack,
      behavior: SnackBarBehavior.floating,
    );
  }

  static SnackBar infoSnackBar(String message) {
    return SnackBar(
      content: Text(
        message,
        style: const TextStyle(
          color: AppTheme.primaryBlack,
          fontFamily: 'Borel',
        ),
      ),
      backgroundColor: AppTheme.primaryYellow,
      behavior: SnackBarBehavior.floating,
    );
  }

  // Standard AppBar style
  static AppBar standardAppBar({
    required String title,
    List<Widget>? actions,
    Widget? leading,
    bool automaticallyImplyLeading = true,
  }) {
    return AppBar(
      backgroundColor: AppTheme.primaryBlack,
      foregroundColor: AppTheme.primaryWhite,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: AppTheme.primaryWhite,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Borel',
        ),
      ),
      actions: actions,
      leading: leading,
      automaticallyImplyLeading: automaticallyImplyLeading,
    );
  }

  // Standard FloatingActionButton style
  static FloatingActionButton standardFAB({
    required VoidCallback onPressed,
    required Widget child,
    String? tooltip,
  }) {
    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: AppTheme.primaryYellow,
      foregroundColor: AppTheme.primaryBlack,
      tooltip: tooltip,
      child: child,
    );
  }

  // Standard Card style
  static BoxDecoration standardCard({
    double borderRadius = 12.0,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: AppTheme.primaryWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(
        color: AppTheme.primaryBlack.withOpacity(0.1),
        width: 1,
      ),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppTheme.primaryBlack.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }

  // Standard form container style
  static BoxDecoration formContainer({
    double borderRadius = 20.0,
  }) {
    return BoxDecoration(
      color: AppTheme.primaryYellow,
      borderRadius: BorderRadius.circular(borderRadius),
    );
  }

  // Standard text styles
  static TextStyle headingStyle({
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTheme.primaryBlack,
      fontFamily: 'Borel',
    );
  }

  static TextStyle bodyStyle({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTheme.primaryBlack,
      fontFamily: 'Borel',
    );
  }

  static TextStyle labelStyle({
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
  }) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppTheme.primaryBlack,
      fontFamily: 'Borel',
    );
  }

  // Standard button styles
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryBlack,
      foregroundColor: AppTheme.primaryWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  static ButtonStyle secondaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryYellow,
      foregroundColor: AppTheme.primaryBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  static ButtonStyle outlineButtonStyle() {
    return OutlinedButton.styleFrom(
      backgroundColor: AppTheme.primaryWhite,
      foregroundColor: AppTheme.primaryBlack,
      side: const BorderSide(color: AppTheme.primaryBlack, width: 2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    );
  }

  // Standard input decoration
  static InputDecoration standardInputDecoration({
    required String labelText,
    String? hintText,
    Widget? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryBlack),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppTheme.primaryBlack.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppTheme.primaryBlack, width: 2),
      ),
      labelStyle: const TextStyle(
        color: AppTheme.primaryBlack,
        fontFamily: 'Borel',
      ),
      hintStyle: TextStyle(
        color: AppTheme.primaryBlack.withOpacity(0.6),
        fontFamily: 'Borel',
      ),
    );
  }

  // Standard loading indicator
  static Widget loadingIndicator({Color? color}) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(
        color ?? AppTheme.primaryYellow,
      ),
    );
  }

  // Standard divider
  static Widget standardDivider() {
    return Divider(
      color: AppTheme.primaryBlack.withOpacity(0.1),
      thickness: 1,
    );
  }
}
