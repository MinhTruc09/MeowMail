import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: color ?? AppTheme.primaryBlack,
            strokeWidth: 3,
          ),
          if (message != null) ...[
            SizedBox(height: AppTheme.responsivePadding(context, AppTheme.defaultPadding)),
            Text(
              message!,
              style: TextStyle(
                fontFamily: 'Borel',
                fontSize: AppTheme.responsiveFontSize(context, AppTheme.bodyFontSize),
                color: AppTheme.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? titleColor;
  final double? elevation;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.centerTitle = true,
    this.backgroundColor,
    this.titleColor,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? AppTheme.primaryWhite,
      elevation: elevation ?? 0,
      centerTitle: centerTitle,
      leading: leading,
      title: Text(
        title,
        style: TextStyle(
          color: titleColor ?? AppTheme.primaryBlack,
          fontFamily: 'Borel',
          fontWeight: FontWeight.bold,
          fontSize: AppTheme.responsiveFontSize(context, AppTheme.titleFontSize),
        ),
      ),
      actions: actions,
      iconTheme: IconThemeData(
        color: titleColor ?? AppTheme.primaryBlack,
        size: AppTheme.responsiveFontSize(context, AppTheme.iconSize),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? action;

  const EmptyStateWidget({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppTheme.responsivePadding(context, AppTheme.largePadding)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppTheme.responsiveWidth(context, 0.2),
                color: Colors.grey[400],
              ),
              SizedBox(height: AppTheme.responsivePadding(context, AppTheme.defaultPadding)),
            ],
            Text(
              title,
              style: TextStyle(
                fontSize: AppTheme.responsiveFontSize(context, AppTheme.titleFontSize),
                fontWeight: FontWeight.bold,
                fontFamily: 'Borel',
                color: AppTheme.primaryBlack,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: AppTheme.responsivePadding(context, AppTheme.smallPadding)),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: AppTheme.responsiveFontSize(context, AppTheme.bodyFontSize),
                  fontFamily: 'Borel',
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (action != null) ...[
              SizedBox(height: AppTheme.responsivePadding(context, AppTheme.largePadding)),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? action;
  final EdgeInsetsGeometry? padding;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.action,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.symmetric(
        horizontal: AppTheme.responsivePadding(context, AppTheme.defaultPadding),
        vertical: AppTheme.responsivePadding(context, AppTheme.smallPadding),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: AppTheme.responsiveFontSize(context, AppTheme.titleFontSize),
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Borel',
                    color: AppTheme.primaryBlack,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppTheme.responsivePadding(context, 4)),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: AppTheme.responsiveFontSize(context, AppTheme.labelFontSize),
                      fontFamily: 'Borel',
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

class ResponsiveContainer extends StatelessWidget {
  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;

  const ResponsiveContainer({
    super.key,
    required this.child,
    this.maxWidth,
    this.padding,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.screenWidth(context);
    final containerMaxWidth = maxWidth ?? (screenWidth > 600 ? 600 : screenWidth);
    
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      constraints: BoxConstraints(maxWidth: containerMaxWidth),
      child: child,
    );
  }
}
