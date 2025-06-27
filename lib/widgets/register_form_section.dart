import 'package:flutter/material.dart';
import 'package:mewmail/widgets/register/register_validator.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/models/user/register_request.dart';
import 'package:mewmail/models/user/login_request.dart';
import 'package:mewmail/screens/main_screen.dart';
import 'package:mewmail/widgets/common/custom_text_field.dart';
import 'package:mewmail/widgets/common/custom_button.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class RegisterFormSection extends StatefulWidget {
  const RegisterFormSection({super.key});

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _loading = false;
  File? _avatarFile;

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _passwordController.dispose();
    _rePasswordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null && mounted) {
      setState(() {
        _avatarFile = File(picked.path);
      });
    }
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

    if (emailError != null ||
        nameError != null ||
        passwordError != null ||
        rePasswordError != null ||
        phoneError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            emailError ??
                nameError ??
                passwordError ??
                rePasswordError ??
                phoneError!,
          ),
        ),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await AuthService.register(
        RegisterRequest(
          email: email,
          password: password,
          fullName: name,
          phone: phone,
          avatar: _avatarFile,
        ),
      );
      // Đăng ký thành công, tự động đăng nhập
      try {
        await AuthService.login(LoginRequest(email: email, password: password));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đăng ký và đăng nhập thành công!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đăng ký thành công, nhưng đăng nhập thất bại: $e'),
          ),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    } catch (e, stack) {
      print('Đăng ký thất bại: $e');
      print(stack);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Đăng ký thất bại: $e')));
    } finally {
      setState(() => _loading = false);
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
                    CustomTextField(
                      label: 'Email',
                      hintText: 'abc@gmail.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      validator: validateEmail,
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Họ và tên',
                      hintText: 'Nguyễn Văn A',
                      controller: _nameController,
                      prefixIcon: Icons.person,
                      validator: validateFullName,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      label: 'Mật khẩu',
                      hintText: '************',
                      controller: _passwordController,
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 16),
                    PasswordTextField(
                      label: 'Nhập lại mật khẩu',
                      hintText: '************',
                      controller: _rePasswordController,
                      validator:
                          (value) => validateRePassword(
                            value,
                            _passwordController.text,
                          ),
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      label: 'Số điện thoại',
                      hintText: '0123456789',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Vui lòng nhập số điện thoại'
                                  : null,
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
                    const SizedBox(height: 20),
                    CustomButton(
                      text: 'Đăng ký',
                      onPressed: _loading ? null : _submitRegister,
                      isLoading: _loading,
                      type: ButtonType.primary,
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
}
