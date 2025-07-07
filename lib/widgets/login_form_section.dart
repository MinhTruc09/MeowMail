import 'package:flutter/material.dart';
import 'package:mewmail/models/user/login_request.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/screens/forgot_screen.dart';
import 'package:mewmail/screens/main_screen.dart';
import 'package:mewmail/widgets/common/custom_text_field.dart';
import 'package:mewmail/widgets/common/custom_button.dart';
import 'package:mewmail/widgets/theme.dart';

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  Future<void> _submitLogin() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập đầy đủ email và mật khẩu!'),
        ),
      );
      setState(() => _loading = false);
      return;
    }

    try {
      final userEmail = await AuthService.login(
        LoginRequest(email: email, password: password),
      );
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Chào $userEmail!')));
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đăng nhập thất bại: ${e.toString().replaceAll('Exception: ', '')}',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.025,
          ),
          decoration: BoxDecoration(
            color: AppTheme.primaryYellow,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: "Email",
                hintText: "abc@gmail.com",
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.email,
              ),
              SizedBox(height: screenHeight * 0.02),
              PasswordTextField(
                label: "Mật khẩu",
                hintText: "************",
                controller: _passwordController,
              ),
              SizedBox(height: screenHeight * 0.01),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ForgotScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Quên mật khẩu?",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.primaryBlack,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                      fontSize: AppTheme.responsiveWidth(context, 0.035),
                      fontFamily: 'Borel',
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              CustomButton(
                text: "ĐĂNG NHẬP",
                onPressed: _loading ? null : _submitLogin,
                isLoading: _loading,
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Chưa có tài khoản? ",
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: screenWidth * 0.045,
                fontFamily: 'Borel',
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                "Đăng ký",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFFCC00),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  decoration: TextDecoration.none,
                  fontFamily: 'Borel',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
