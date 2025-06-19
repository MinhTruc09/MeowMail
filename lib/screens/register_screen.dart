import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/register_form_section.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  bool _obscure = true;
  bool _obscureRe = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.03),
                Text("Đăng ký", style: theme.textTheme.headlineLarge?.copyWith(fontFamily: 'Borel', fontSize: screenWidth * 0.08)),
                Text("Tạo tài khoản tại đây", style: theme.textTheme.bodyLarge?.copyWith(fontSize: screenWidth * 0.045, color: AppTheme.primaryYellow)),
                SizedBox(height: screenHeight * 0.02),
                Image.asset('assets/images/letter.png', width: screenWidth * 0.35),
                SizedBox(height: screenHeight * 0.01),
                const RegisterFormSection(),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Đã có tài khoản? ", style: theme.textTheme.bodyMedium?.copyWith(fontSize: screenWidth * 0.045, fontFamily: 'Borel')),
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        "Đăng nhập",
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppTheme.primaryYellow,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth * 0.045,
                          decoration: TextDecoration.none,
                          fontFamily: 'Borel',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenHeight * 0.04),
                Image.asset('assets/images/middlecat.png', width: screenWidth * 0.35),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
