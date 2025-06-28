import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? initialValue;
  final bool enabled;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final int? maxLines;
  final bool readOnly;

  const CustomTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.initialValue,
    this.enabled = true,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.onTap,
    this.maxLines = 1,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      initialValue: controller == null ? initialValue : null,
      enabled: enabled,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onTap: onTap,
      maxLines: maxLines,
      readOnly: readOnly,
      style: TextStyle(
        fontFamily: 'Borel',
        color:
            enabled
                ? AppTheme.primaryBlack
                : AppTheme.primaryBlack.withValues(alpha: 0.5),
        fontSize: AppTheme.responsiveFontSize(context, AppTheme.bodyFontSize),
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        labelStyle: TextStyle(
          fontFamily: 'Borel',
          color: AppTheme.primaryBlack.withValues(alpha: 0.6),
          fontSize: AppTheme.responsiveFontSize(
            context,
            AppTheme.labelFontSize,
          ),
        ),
        hintStyle: TextStyle(
          fontFamily: 'Borel',
          color: AppTheme.primaryBlack.withValues(alpha: 0.4),
          fontSize: AppTheme.responsiveFontSize(context, AppTheme.bodyFontSize),
        ),
        prefixIcon:
            prefixIcon != null
                ? Icon(
                  prefixIcon,
                  color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                  size: AppTheme.responsiveFontSize(context, AppTheme.iconSize),
                )
                : null,
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
          ),
          borderSide: BorderSide(
            color: AppTheme.primaryBlack.withValues(alpha: 0.3),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
          ),
          borderSide: BorderSide(
            color: AppTheme.primaryBlack.withValues(alpha: 0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
          ),
          borderSide: const BorderSide(color: AppTheme.primaryBlack, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
          ),
          borderSide: const BorderSide(color: AppTheme.primaryBlack),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
          ),
          borderSide: const BorderSide(color: AppTheme.primaryBlack, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
          ),
          borderSide: BorderSide(
            color: AppTheme.primaryBlack.withValues(alpha: 0.2),
          ),
        ),
        filled: true,
        fillColor:
            enabled
                ? AppTheme.primaryWhite
                : AppTheme.primaryBlack.withValues(alpha: 0.05),
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppTheme.responsivePadding(
            context,
            AppTheme.defaultPadding,
          ),
          vertical: AppTheme.responsivePadding(
            context,
            AppTheme.defaultPadding,
          ),
        ),
      ),
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final String label;
  final String? hintText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  const PasswordTextField({
    super.key,
    required this.label,
    this.hintText,
    this.controller,
    this.validator,
    this.onChanged,
  });

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: widget.label,
      hintText: widget.hintText,
      controller: widget.controller,
      obscureText: _obscureText,
      prefixIcon: Icons.lock,
      suffixIcon: IconButton(
        icon: Icon(
          _obscureText ? Icons.visibility : Icons.visibility_off,
          color: AppTheme.primaryBlack.withValues(alpha: 0.6),
          size: AppTheme.responsiveFontSize(context, AppTheme.iconSize),
        ),
        onPressed: () => setState(() => _obscureText = !_obscureText),
      ),
      validator: widget.validator,
      onChanged: widget.onChanged,
    );
  }
}
