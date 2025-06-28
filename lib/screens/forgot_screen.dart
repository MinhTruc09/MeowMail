import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/custom_text_field.dart';
import 'package:mewmail/widgets/common/custom_button.dart' as custom;

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});
  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  int step = 1;
  final emailController = TextEditingController();
  final captchaController = TextEditingController();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  String captcha = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    // Giả lập captcha
    captcha = 'qG9phJD7';
    setState(() {});
  }

  void _onContinue() async {
    if (emailController.text.isEmpty || captchaController.text != captcha) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email hoặc Captcha không đúng!')),
      );
      return;
    }
    setState(() {
      step = 2;
    });
  }

  void _onChangePassword() async {
    if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')),
      );
      return;
    }
    setState(() {
      isLoading = true;
    });
    await Future.delayed(const Duration(seconds: 1)); // Giả lập gọi API
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = AppTheme.screenWidth(context);
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text(
                'Quên mật khẩu',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  fontFamily: 'Borel',
                  fontSize: AppTheme.responsiveWidth(context, 0.08),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Xác nhận lại thông tin',
                style: TextStyle(
                  color: AppTheme.primaryYellow,
                  fontFamily: 'Borel',
                  fontSize: AppTheme.responsiveWidth(context, 0.045),
                ),
              ),
              const SizedBox(height: 16),
              Image.asset(
                'assets/images/questionmark.png',
                width: AppTheme.responsiveWidth(context, 0.3),
              ),
              const SizedBox(height: 8),
              if (step == 1) ...[
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomTextField(
                        label: 'Email',
                        hintText: 'abc@gmail.com',
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email,
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: 'Nhập Captcha',
                        hintText: 'Nhập mã captcha',
                        controller: captchaController,
                        prefixIcon: Icons.security,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            captcha,
                            style: const TextStyle(
                              fontFamily: 'Borel',
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _generateCaptcha,
                            icon: const Icon(Icons.refresh, size: 20),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: AppTheme.responsiveWidth(context, 0.7),
                  child: custom.CustomButton(
                    text: 'Tiếp tục',
                    onPressed: _onContinue,
                    type: custom.ButtonType.primary,
                  ),
                ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      PasswordTextField(
                        label: 'Mật khẩu cũ',
                        hintText: 'Nhập mật khẩu cũ',
                        controller: oldPassController,
                      ),
                      const SizedBox(height: 16),
                      PasswordTextField(
                        label: 'Mật khẩu mới',
                        hintText: 'Nhập mật khẩu mới',
                        controller: newPassController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: AppTheme.responsiveWidth(context, 0.7),
                  child: custom.CustomButton(
                    text: 'Đổi mật khẩu',
                    onPressed: isLoading ? null : _onChangePassword,
                    isLoading: isLoading,
                    type: custom.ButtonType.primary,
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Image.asset(
                'assets/images/middlecat.png',
                width: AppTheme.responsiveWidth(context, 0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
