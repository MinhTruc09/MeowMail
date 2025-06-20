import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/services/firebase_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/models/user/register_request.dart';
import 'package:mewmail/widgets/register/register_text_field.dart';
import 'package:mewmail/widgets/register/register_button.dart';
import 'package:mewmail/widgets/register/register_validator.dart';

class RegisterFormSection extends StatefulWidget {
  const RegisterFormSection({super.key});

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  bool _obscure = true;
  bool _obscureRe = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;
        final containerWidth = isMobile ? constraints.maxWidth * 0.95 : 400.0;
        return Center(
          child: SingleChildScrollView(
            child: Container(
              width: containerWidth,
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 16 : 32,
                vertical: isMobile ? 16 : 32,
              ),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RegisterTextField(
                      controller: _emailController,
                      label: "Email:",
                      hint: "abc@gmail.com",
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    RegisterTextField(
                      controller: _nameController,
                      label: "Họ và tên:",
                      hint: "Nguyễn Văn A",
                    ),
                    const SizedBox(height: 12),
                    RegisterTextField(
                      controller: _passwordController,
                      label: "Mật khẩu:",
                      hint: "************",
                      obscure: _obscure,
                      onToggleObscure: () => setState(() => _obscure = !_obscure),
                    ),
                    const SizedBox(height: 12),
                    RegisterTextField(
                      controller: _rePasswordController,
                      label: "Nhập lại mật khẩu:",
                      hint: "************",
                      obscure: _obscureRe,
                      onToggleObscure: () => setState(() => _obscureRe = !_obscureRe),
                    ),
                    const SizedBox(height: 16),
                    RegisterButton(
                      onPressed: _loading ? null : _submitRegister,
                      loading: _loading,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _submitRegister() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final rePassword = _rePasswordController.text.trim();

    final emailError = validateEmail(email);
    final nameError = validateFullName(name);
    final passwordError = validatePassword(password);
    final rePasswordError = validateRePassword(rePassword, password);

    if (emailError != null || nameError != null || passwordError != null || rePasswordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError ?? nameError ?? passwordError ?? rePasswordError!)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuthService.registerWithEmail(email: email, password: password, name: name);
      await AuthService.register(RegisterRequest(
        email: email,
        password: password,
        fullName: name,
        phone: '',
        avatar: null,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
} 