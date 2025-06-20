import 'package:flutter/material.dart';
import 'package:mewmail/widgets/login_background.dart';
import 'package:mewmail/widgets/login_form_section.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final textTheme = Theme.of(context).textTheme;
    final theme = Theme.of(context);

    return LoginBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.06),
          child: Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.025),
                Text("Đăng nhập", style: textTheme.headlineLarge?.copyWith(fontSize: screenWidth * 0.08)),
                Text("Kết nối cộng đồng", style: textTheme.bodyLarge?.copyWith(fontSize: screenWidth * 0.045)),
                SizedBox(height: screenHeight * 0.02),
                Image.asset('assets/images/logocat.png', width: screenWidth * 0.40),
                SizedBox(height: screenHeight * 0.01),
                const LoginFormSection(),
                SizedBox(height: screenHeight * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
