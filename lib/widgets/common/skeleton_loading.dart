import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class SkeletonLoading extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const SkeletonLoading({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor,
    this.highlightColor,
  });

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = widget.baseColor ?? AppTheme.primaryBlack.withValues(alpha: 0.1);
    final highlightColor = widget.highlightColor ?? AppTheme.primaryYellow.withValues(alpha: 0.3);

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(8),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                baseColor,
                highlightColor,
                baseColor,
              ],
              stops: [
                (_animation.value - 1).clamp(0.0, 1.0),
                _animation.value.clamp(0.0, 1.0),
                (_animation.value + 1).clamp(0.0, 1.0),
              ],
            ),
          ),
        );
      },
    );
  }
}

class MailListSkeleton extends StatelessWidget {
  final int itemCount;

  const MailListSkeleton({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppTheme.responsivePadding(context, AppTheme.defaultPadding),
            vertical: AppTheme.responsivePadding(context, AppTheme.smallPadding),
          ),
          padding: EdgeInsets.all(
            AppTheme.responsivePadding(context, AppTheme.defaultPadding),
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryWhite,
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryBlack.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              // Avatar skeleton
              SkeletonLoading(
                width: AppTheme.responsiveWidth(context, 0.12),
                height: AppTheme.responsiveWidth(context, 0.12),
                borderRadius: BorderRadius.circular(
                  AppTheme.responsiveWidth(context, 0.06),
                ),
              ),
              SizedBox(width: AppTheme.responsivePadding(context, AppTheme.defaultPadding)),
              // Content skeleton
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title skeleton
                    SkeletonLoading(
                      width: AppTheme.responsiveWidth(context, 0.6),
                      height: AppTheme.responsiveFontSize(context, 16),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: AppTheme.responsivePadding(context, AppTheme.smallPadding)),
                    // Content skeleton
                    SkeletonLoading(
                      width: AppTheme.responsiveWidth(context, 0.8),
                      height: AppTheme.responsiveFontSize(context, 14),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    SizedBox(height: AppTheme.responsivePadding(context, AppTheme.smallPadding)),
                    // Time skeleton
                    SkeletonLoading(
                      width: AppTheme.responsiveWidth(context, 0.3),
                      height: AppTheme.responsiveFontSize(context, 12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(
        AppTheme.responsivePadding(context, AppTheme.defaultPadding),
      ),
      child: Column(
        children: [
          // Avatar skeleton
          SkeletonLoading(
            width: AppTheme.responsiveWidth(context, 0.25),
            height: AppTheme.responsiveWidth(context, 0.25),
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveWidth(context, 0.125),
            ),
          ),
          SizedBox(height: AppTheme.responsivePadding(context, AppTheme.defaultPadding)),
          // Name skeleton
          SkeletonLoading(
            width: AppTheme.responsiveWidth(context, 0.5),
            height: AppTheme.responsiveFontSize(context, 18),
            borderRadius: BorderRadius.circular(4),
          ),
          SizedBox(height: AppTheme.responsivePadding(context, AppTheme.smallPadding)),
          // Email skeleton
          SkeletonLoading(
            width: AppTheme.responsiveWidth(context, 0.7),
            height: AppTheme.responsiveFontSize(context, 14),
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }
}

class MessageDetailSkeleton extends StatelessWidget {
  final int messageCount;

  const MessageDetailSkeleton({super.key, this.messageCount = 3});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: messageCount,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(
            horizontal: AppTheme.responsivePadding(context, AppTheme.defaultPadding),
            vertical: AppTheme.responsivePadding(context, AppTheme.smallPadding),
          ),
          padding: EdgeInsets.all(
            AppTheme.responsivePadding(context, AppTheme.defaultPadding),
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryWhite,
            borderRadius: BorderRadius.circular(
              AppTheme.responsiveRadius(context, AppTheme.defaultRadius),
            ),
            border: Border.all(
              color: AppTheme.primaryBlack.withValues(alpha: 0.1),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header skeleton
              Row(
                children: [
                  SkeletonLoading(
                    width: AppTheme.responsiveWidth(context, 0.08),
                    height: AppTheme.responsiveWidth(context, 0.08),
                    borderRadius: BorderRadius.circular(
                      AppTheme.responsiveWidth(context, 0.04),
                    ),
                  ),
                  SizedBox(width: AppTheme.responsivePadding(context, AppTheme.smallPadding)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SkeletonLoading(
                          width: AppTheme.responsiveWidth(context, 0.4),
                          height: AppTheme.responsiveFontSize(context, 14),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        SizedBox(height: AppTheme.responsivePadding(context, 4)),
                        SkeletonLoading(
                          width: AppTheme.responsiveWidth(context, 0.3),
                          height: AppTheme.responsiveFontSize(context, 12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppTheme.responsivePadding(context, AppTheme.defaultPadding)),
              // Content skeleton
              SkeletonLoading(
                width: double.infinity,
                height: AppTheme.responsiveFontSize(context, 14) * 3,
                borderRadius: BorderRadius.circular(4),
              ),
            ],
          ),
        );
      },
    );
  }
}
