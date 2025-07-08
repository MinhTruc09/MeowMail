import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/custom_text_field.dart';
import 'package:mewmail/widgets/common/custom_button.dart' as custom;
import 'package:mewmail/widgets/login_background.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      debugPrint('🔄 Attempting to change password...');
      await UserService.changePass(
        token: token,
        oldPassword: _oldPasswordController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      debugPrint('✅ Password changed successfully');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đổi mật khẩu thành công!'),
            backgroundColor: AppTheme.primaryYellow,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      debugPrint('❌ Change password error: $e');

      if (mounted) {
        // Check if session expired and redirect to login
        if (AuthService.shouldRedirectToLogin(e.toString())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đổi mật khẩu: $e'),
              backgroundColor: AppTheme.primaryBlack,
            ),
          );
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = AppTheme.screenWidth(context);
    final screenHeight = AppTheme.screenHeight(context);

    return LoginBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppTheme.primaryWhite),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Đổi mật khẩu',
            style: TextStyle(
              color: AppTheme.primaryWhite,
              fontFamily: 'Borel',
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.responsiveWidth(context, 0.06),
            ),
            child: FadeInAnimation(
              delay: const Duration(milliseconds: 200),
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.02),

                  // Header Section
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 400),
                    begin: const Offset(0, -0.5),
                    child: Column(
                      children: [
                        // Logo/Icon
                        Container(
                          width: screenWidth * 0.25,
                          height: screenWidth * 0.25,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryYellow.withValues(
                              alpha: 0.9,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryYellow.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.lock_reset,
                            size: screenWidth * 0.12,
                            color: AppTheme.primaryBlack,
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),

                        // Title
                        Text(
                          'Đổi mật khẩu',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveWidth(context, 0.07),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Borel',
                            color: AppTheme.primaryWhite,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: screenHeight * 0.01),

                        // Subtitle
                        Text(
                          'Bảo mật tài khoản của bạn',
                          style: TextStyle(
                            fontSize: AppTheme.responsiveWidth(context, 0.04),
                            fontFamily: 'Borel',
                            color: AppTheme.primaryWhite.withValues(alpha: 0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.04),

                  // Form Section
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 600),
                    begin: const Offset(0, 0.5),
                    child: Container(
                      padding: EdgeInsets.all(screenWidth * 0.06),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryWhite.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // Info Card
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryYellow.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppTheme.primaryYellow.withValues(
                                    alpha: 0.3,
                                  ),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppTheme.primaryYellow,
                                    size: screenWidth * 0.05,
                                  ),
                                  SizedBox(width: screenWidth * 0.03),
                                  Expanded(
                                    child: Text(
                                      'Nhập mật khẩu cũ và mật khẩu mới để thay đổi',
                                      style: TextStyle(
                                        fontSize: AppTheme.responsiveWidth(
                                          context,
                                          0.035,
                                        ),
                                        fontFamily: 'Borel',
                                        color: AppTheme.primaryBlack.withValues(
                                          alpha: 0.7,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.03),

                            // Old Password Field
                            PasswordTextField(
                              label: 'Mật khẩu cũ',
                              controller: _oldPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu cũ';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // New Password Field
                            PasswordTextField(
                              label: 'Mật khẩu mới',
                              controller: _newPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng nhập mật khẩu mới';
                                }
                                if (value.length < 6) {
                                  return 'Mật khẩu phải có ít nhất 6 ký tự';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Confirm Password Field
                            PasswordTextField(
                              label: 'Xác nhận mật khẩu mới',
                              controller: _confirmPasswordController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Vui lòng xác nhận mật khẩu mới';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Mật khẩu xác nhận không khớp';
                                }
                                return null;
                              },
                            ),

                            SizedBox(height: screenHeight * 0.04),

                            // Change Password Button
                            SizedBox(
                              width: double.infinity,
                              child: custom.CustomButton(
                                text: 'Đổi mật khẩu',
                                onPressed: _changePassword,
                                isLoading: _isLoading,
                                type: custom.ButtonType.primary,
                              ),
                            ),

                            SizedBox(height: screenHeight * 0.02),

                            // Security Tips
                            Container(
                              padding: EdgeInsets.all(screenWidth * 0.04),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlack.withValues(
                                  alpha: 0.05,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.security,
                                        color: AppTheme.primaryBlack.withValues(
                                          alpha: 0.6,
                                        ),
                                        size: screenWidth * 0.04,
                                      ),
                                      SizedBox(width: screenWidth * 0.02),
                                      Text(
                                        'Mẹo bảo mật:',
                                        style: TextStyle(
                                          fontSize: AppTheme.responsiveWidth(
                                            context,
                                            0.035,
                                          ),
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Borel',
                                          color: AppTheme.primaryBlack
                                              .withValues(alpha: 0.7),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: screenHeight * 0.01),
                                  Text(
                                    '• Sử dụng ít nhất 8 ký tự\n'
                                    '• Kết hợp chữ hoa, chữ thường và số\n'
                                    '• Không sử dụng thông tin cá nhân',
                                    style: TextStyle(
                                      fontSize: AppTheme.responsiveWidth(
                                        context,
                                        0.03,
                                      ),
                                      fontFamily: 'Borel',
                                      color: AppTheme.primaryBlack.withValues(
                                        alpha: 0.6,
                                      ),
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: screenHeight * 0.03),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
