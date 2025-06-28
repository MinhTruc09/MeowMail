import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

enum ButtonType { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonType type;
  final double? width;
  final double? height;
  final IconData? icon;
  final bool fullWidth;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.type = ButtonType.primary,
    this.width,
    this.height,
    this.icon,
    this.fullWidth = true,
  });

  Color _getBackgroundColor() {
    switch (type) {
      case ButtonType.primary:
        return AppTheme.primaryBlack;
      case ButtonType.secondary:
        return AppTheme.primaryYellow;
      case ButtonType.outline:
        return AppTheme.primaryWhite;
      case ButtonType.danger:
        return AppTheme
            .primaryBlack; // Use black instead of red to follow theme
    }
  }

  Color _getTextColor() {
    switch (type) {
      case ButtonType.primary:
        return AppTheme.primaryWhite;
      case ButtonType.secondary:
        return AppTheme.primaryBlack;
      case ButtonType.outline:
        return AppTheme.primaryBlack;
      case ButtonType.danger:
        return AppTheme.primaryWhite;
    }
  }

  BorderSide? _getBorderSide() {
    if (type == ButtonType.outline) {
      return const BorderSide(color: AppTheme.primaryBlack, width: 2);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final buttonHeight = height ?? AppTheme.responsiveHeight(context, 0.06);
    final buttonWidth =
        fullWidth
            ? double.infinity
            : width ?? AppTheme.responsiveWidth(context, 0.4);

    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _getBackgroundColor(),
          foregroundColor: _getTextColor(),
          side: _getBorderSide(),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
            ),
          ),
          elevation: type == ButtonType.outline ? 0 : 2,
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.responsivePadding(
              context,
              AppTheme.defaultPadding,
            ),
            vertical: AppTheme.responsivePadding(
              context,
              AppTheme.smallPadding,
            ),
          ),
        ),
        child:
            isLoading
                ? SizedBox(
                  height: AppTheme.responsiveFontSize(context, 20),
                  width: AppTheme.responsiveFontSize(context, 20),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(_getTextColor()),
                  ),
                )
                : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(
                        icon,
                        size: AppTheme.responsiveFontSize(
                          context,
                          AppTheme.iconSize,
                        ),
                      ),
                      SizedBox(
                        width: AppTheme.responsivePadding(
                          context,
                          AppTheme.smallPadding,
                        ),
                      ),
                    ],
                    Text(
                      text,
                      style: TextStyle(
                        fontSize: AppTheme.responsiveFontSize(
                          context,
                          AppTheme.bodyFontSize,
                        ),
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Borel',
                      ),
                    ),
                  ],
                ),
      ),
    );
  }
}

class IconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double? size;
  final String? tooltip;

  const IconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? AppTheme.responsiveWidth(context, 0.12);

    return Tooltip(
      message: tooltip ?? '',
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          width: buttonSize,
          height: buttonSize,
          decoration: BoxDecoration(
            color: backgroundColor ?? AppTheme.primaryBlack,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: iconColor ?? AppTheme.primaryWhite,
            size: AppTheme.responsiveFontSize(context, AppTheme.iconSize),
          ),
        ),
      ),
    );
  }
}
