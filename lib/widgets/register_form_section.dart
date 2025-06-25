import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/services/firebase_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/models/user/register_request.dart';
import 'package:mewmail/widgets/register/register_text_field.dart';
import 'package:mewmail/widgets/register/register_button.dart';
import 'package:mewmail/widgets/register/register_validator.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

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
  final _phoneController = TextEditingController();
  bool _obscure = true;
  bool _obscureRe = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();
  File? _avatarFile;

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
  }

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
                    const SizedBox(height: 12),
                    RegisterTextField(
                      controller: _phoneController,
                      label: "Số điện thoại:",
                      hint: "0123456789",
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _avatarFile != null
                            ? CircleAvatar(
                                backgroundImage: FileImage(_avatarFile!),
                                radius: 28,
                              )
                            : const CircleAvatar(
                                radius: 28,
                                child: Icon(Icons.person, size: 32),
                              ),
                        const SizedBox(width: 16),
                        ElevatedButton.icon(
                          onPressed: _pickAvatar,
                          icon: const Icon(Icons.image),
                          label: const Text('Chọn ảnh đại diện'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
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
    final phone = _phoneController.text.trim();

    final emailError = validateEmail(email);
    final nameError = validateFullName(name);
    final passwordError = validatePassword(password);
    final rePasswordError = validateRePassword(rePassword, password);
    final phoneError = phone.isEmpty ? 'Vui lòng nhập số điện thoại' : null;

    if (emailError != null || nameError != null || passwordError != null || rePasswordError != null || phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(emailError ?? nameError ?? passwordError ?? rePasswordError ?? phoneError!)),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.register(RegisterRequest(
        email: email,
        password: password,
        fullName: name,
        phone: phone,
        avatar: _avatarFile,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (route) => false,
      );
    } catch (e, stack) {
      print('Đăng ký thất bại: $e');
      print(stack);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
} 