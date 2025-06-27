import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final double? elevation;
  final VoidCallback? onTap;
  final BorderRadius? borderRadius;

  const CustomCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.backgroundColor,
    this.elevation,
    this.onTap,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final cardPadding = padding ?? EdgeInsets.all(
      AppTheme.responsivePadding(context, AppTheme.defaultPadding),
    );
    final cardMargin = margin ?? EdgeInsets.symmetric(
      horizontal: AppTheme.responsivePadding(context, AppTheme.defaultPadding),
      vertical: AppTheme.responsivePadding(context, AppTheme.smallPadding),
    );
    final cardBorderRadius = borderRadius ?? BorderRadius.circular(
      AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
    );

    return Container(
      margin: cardMargin,
      child: Material(
        color: backgroundColor ?? AppTheme.primaryYellow,
        borderRadius: cardBorderRadius,
        elevation: elevation ?? 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: cardBorderRadius,
          child: Padding(
            padding: cardPadding,
            child: child,
          ),
        ),
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const InfoCard({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: backgroundColor,
      onTap: onTap,
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              color: AppTheme.primaryBlack,
              size: AppTheme.responsiveFontSize(context, AppTheme.iconSize),
            ),
            SizedBox(width: AppTheme.responsivePadding(context, AppTheme.defaultPadding)),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: 'Borel',
                    fontSize: AppTheme.responsiveFontSize(context, AppTheme.bodyFontSize),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primaryBlack,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: AppTheme.responsivePadding(context, 4)),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontFamily: 'Borel',
                      fontSize: AppTheme.responsiveFontSize(context, AppTheme.labelFontSize),
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class ProfileCard extends StatelessWidget {
  final String name;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onTap;

  const ProfileCard({
    super.key,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CustomCard(
      backgroundColor: AppTheme.primaryWhite,
      onTap: onTap,
      padding: EdgeInsets.all(AppTheme.responsivePadding(context, AppTheme.largePadding)),
      child: Column(
        children: [
          CircleAvatar(
            radius: AppTheme.responsiveWidth(context, 0.12),
            backgroundColor: AppTheme.primaryYellow.withValues(alpha: 0.3),
            backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : null,
            child: avatarUrl == null || avatarUrl!.isEmpty
                ? Icon(
                    Icons.person,
                    size: AppTheme.responsiveWidth(context, 0.12),
                    color: AppTheme.primaryBlack,
                  )
                : null,
          ),
          SizedBox(height: AppTheme.responsivePadding(context, AppTheme.smallPadding)),
          Text(
            name,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.responsiveFontSize(context, AppTheme.titleFontSize),
              fontFamily: 'Borel',
              color: AppTheme.primaryBlack,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppTheme.responsivePadding(context, 4)),
          Text(
            email,
            style: TextStyle(
              color: Colors.black87,
              fontFamily: 'Borel',
              fontSize: AppTheme.responsiveFontSize(context, AppTheme.bodyFontSize),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
