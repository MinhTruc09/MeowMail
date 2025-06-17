import 'package:flutter/material.dart';
import 'package:mewmail/widgets/login_background.dart';
import 'package:mewmail/widgets/login_form_section.dart'; // 💡 thêm dòng này

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return LoginBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Text("Đăng nhập", style: textTheme.headlineLarge),
                Text("Kết nối cộng đồng", style: textTheme.bodyLarge),
                const SizedBox(height: 20),
                Image.asset('assets/images/logocat.png', width: screenWidth * 0.45),
                const SizedBox(height: 10),

                // 👉 Login Form được gọi ở đây:
                const LoginFormSection(),

                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Chưa có tài khoản? ", style: textTheme.bodyMedium),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "Đăng ký",
                        style: textTheme.bodyMedium?.copyWith(
                          color: theme.hintColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                // Google login
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: Image.asset('assets/images/google.png', height: 16),
                  label: const Text("ĐĂNG NHẬP BẰNG GOOGLE"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
