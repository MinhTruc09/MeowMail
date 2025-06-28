import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/custom_text_field.dart';
import 'package:mewmail/widgets/common/custom_button.dart' as custom;
import 'package:mewmail/widgets/common/custom_widgets.dart';
import 'package:mewmail/widgets/common/custom_card.dart';

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
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: CustomAppBar(
        title: 'Đổi mật khẩu',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.primaryBlack),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ResponsiveContainer(
        padding: EdgeInsets.all(
          AppTheme.responsivePadding(context, AppTheme.defaultPadding),
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: AppTheme.responsivePadding(
                    context,
                    AppTheme.largePadding,
                  ),
                ),

                // Header
                CustomCard(
                  backgroundColor: AppTheme.primaryYellow.withValues(
                    alpha: 0.1,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.lock_outline,
                        size: AppTheme.responsiveWidth(context, 0.12),
                        color: AppTheme.primaryBlack,
                      ),
                      SizedBox(
                        height: AppTheme.responsivePadding(
                          context,
                          AppTheme.smallPadding,
                        ),
                      ),
                      Text(
                        'Thay đổi mật khẩu của bạn',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFontSize(context, 18),
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Borel',
                          color: AppTheme.primaryBlack,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: AppTheme.responsivePadding(
                          context,
                          AppTheme.smallPadding,
                        ),
                      ),
                      Text(
                        'Vui lòng nhập mật khẩu cũ và mật khẩu mới để thay đổi',
                        style: TextStyle(
                          fontSize: AppTheme.responsiveFontSize(context, 14),
                          fontFamily: 'Borel',
                          color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: AppTheme.responsivePadding(
                    context,
                    AppTheme.largePadding,
                  ),
                ),

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

                SizedBox(
                  height: AppTheme.responsivePadding(
                    context,
                    AppTheme.defaultPadding,
                  ),
                ),

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

                SizedBox(
                  height: AppTheme.responsivePadding(
                    context,
                    AppTheme.defaultPadding,
                  ),
                ),

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

                SizedBox(
                  height: AppTheme.responsivePadding(
                    context,
                    AppTheme.largePadding * 2,
                  ),
                ),

                // Change Password Button
                custom.CustomButton(
                  text: 'Đổi mật khẩu',
                  onPressed: _changePassword,
                  isLoading: _isLoading,
                  type: custom.ButtonType.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
