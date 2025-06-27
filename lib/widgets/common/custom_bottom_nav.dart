import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppTheme.responsiveHeight(
        context,
        0.07,
      ), // Giảm từ 0.1 xuống 0.07
      decoration: const BoxDecoration(
        color: AppTheme.primaryBlack,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15), // Giảm từ 20 xuống 15
          topRight: Radius.circular(15),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(
            context: context,
            icon: Icons.home,
            label: 'Trang chủ',
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.search,
            label: 'Tìm kiếm',
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.history,
            label: 'Lịch sử',
            index: 2,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            context: context,
            icon: Icons.settings,
            label: 'Cài đặt',
            index: 3,
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: AppTheme.responsivePadding(context, 4), // Giảm từ 8 xuống 4
          horizontal: AppTheme.responsivePadding(
            context,
            8,
          ), // Giảm từ 12 xuống 8
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isActive ? AppTheme.primaryYellow : AppTheme.primaryWhite,
              size: AppTheme.responsiveFontSize(
                context,
                20,
              ), // Giảm từ 24 xuống 20
            ),
            const SizedBox(height: 2), // Giảm từ 4 xuống 2
            Text(
              label,
              style: TextStyle(
                color:
                    isActive ? AppTheme.primaryYellow : AppTheme.primaryWhite,
                fontSize: AppTheme.responsiveFontSize(
                  context,
                  10,
                ), // Giảm từ 12 xuống 10
                fontFamily: 'Borel',
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
