import 'package:flutter/material.dart';
import 'package:mewmail/widgets/login_background.dart';
import 'package:mewmail/widgets/login_form_section.dart';

import 'package:mewmail/widgets/theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.screenWidth(context);
    final screenHeight = AppTheme.screenHeight(context);
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return LoginBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: AppTheme.responsiveWidth(context, 0.06)),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: AppTheme.responsiveHeight(context, 0.025)),
                Text("Đăng nhập", style: textTheme.headlineLarge?.copyWith(fontSize: AppTheme.responsiveWidth(context, 0.08))),
                Text("Kết nối cộng đồng", style: textTheme.bodyLarge?.copyWith(fontSize: AppTheme.responsiveWidth(context, 0.045))),
                SizedBox(height: AppTheme.responsiveHeight(context, 0.02)),
                Image.asset('assets/images/logocat.png', width: AppTheme.responsiveWidth(context, 0.40)),
                SizedBox(height: AppTheme.responsiveHeight(context, 0.01)),
                const LoginFormSection(),
                SizedBox(height: AppTheme.responsiveHeight(context, 0.01)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
