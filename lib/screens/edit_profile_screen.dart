import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/custom_widgets.dart';
import 'package:mewmail/widgets/common/custom_text_field.dart';
import 'package:mewmail/widgets/common/custom_button.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/services/avatar_service.dart';
import 'package:mewmail/models/user/profile_response.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  ProfileResponseDto? _profile;
  File? _selectedImage;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
        return;
      }

      final response = await UserService.myProfile(token);

      // Debug: Print actual API response
      debugPrint('🔍 Profile API Response:');
      debugPrint('  - Email: ${response.data?.email}');
      debugPrint('  - Fullname: ${response.data?.fullname}');
      debugPrint('  - Phone: ${response.data?.phone}');
      debugPrint('  - Avatar: ${response.data?.avatar}');

      setState(() {
        _profile = response.data;
        _fullNameController.text = _profile?.fullname ?? '';
        _phoneController.text = _profile?.phone ?? '';

        // Validate email field - if it's a URL, don't use it
        final emailValue = _profile?.email ?? '';
        if (emailValue.startsWith('http://') ||
            emailValue.startsWith('https://')) {
          debugPrint('⚠️ Email field contains URL: $emailValue');
          _emailController.text = ''; // Leave empty if it's a URL
        } else {
          _emailController.text = emailValue;
        }

        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
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
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi tải thông tin: $e')));
        }
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi chọn ảnh: $e')));
      }
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
        return;
      }

      await UserService.updateProfile(
        token: token,
        fullName: _fullNameController.text.trim(),
        phone: _phoneController.text.trim(),
        avatarPath: _selectedImage?.path,
      );

      // Clear avatar cache to force refresh
      final myEmail = prefs.getString('email');
      if (myEmail != null) {
        AvatarService.clearAvatarCache(myEmail);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thông tin thành công!'),
            backgroundColor: AppTheme.primaryYellow,
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi cập nhật: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  String? _validateFullName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập họ tên';
    }
    if (value.trim().length < 2) {
      return 'Họ tên phải có ít nhất 2 ký tự';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Vui lòng nhập số điện thoại';
    }
    final phoneRegex = RegExp(r'^[0-9]{10,11}$');
    if (!phoneRegex.hasMatch(value.trim())) {
      return 'Số điện thoại không hợp lệ';
    }
    return null;
  }

  Widget _buildAvatarSection() {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: AppTheme.responsiveWidth(context, 0.15),
            backgroundColor: AppTheme.primaryYellow.withValues(alpha: 0.3),
            backgroundImage:
                _selectedImage != null
                    ? FileImage(_selectedImage!)
                    : (_profile?.avatar != null && _profile!.avatar.isNotEmpty)
                    ? NetworkImage(_profile!.avatar)
                    : null,
            child:
                (_selectedImage == null &&
                        (_profile?.avatar == null || _profile!.avatar.isEmpty))
                    ? Icon(
                      Icons.person,
                      size: AppTheme.responsiveWidth(context, 0.15),
                      color: AppTheme.primaryBlack,
                    )
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: AppTheme.responsiveWidth(context, 0.08),
                height: AppTheme.responsiveWidth(context, 0.08),
                decoration: BoxDecoration(
                  color: AppTheme.primaryBlack,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryBlack.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt,
                  color: AppTheme.primaryWhite,
                  size: AppTheme.responsiveWidth(context, 0.04),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryWhite,
        appBar: AppBar(
          title: const Text(
            'Chỉnh sửa thông tin',
            style: TextStyle(
              color: AppTheme.primaryWhite,
              fontFamily: 'Borel',
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: AppTheme.primaryBlack,
          foregroundColor: AppTheme.primaryWhite,
          elevation: 0,
          centerTitle: false,
        ),
        body: const LoadingWidget(message: 'Đang tải thông tin...'),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Chỉnh sửa thông tin',
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontFamily: 'Borel',
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        elevation: 0,
        centerTitle: false,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(
            AppTheme.responsivePadding(context, AppTheme.defaultPadding),
          ),
          child: Column(
            children: [
              SizedBox(
                height: AppTheme.responsivePadding(
                  context,
                  AppTheme.largePadding,
                ),
              ),
              _buildAvatarSection(),
              SizedBox(
                height: AppTheme.responsivePadding(
                  context,
                  AppTheme.largePadding,
                ),
              ),
              CustomTextField(
                label: 'Họ và tên',
                controller: _fullNameController,
                prefixIcon: Icons.person,
                validator: _validateFullName,
                keyboardType: TextInputType.name,
              ),
              SizedBox(
                height: AppTheme.responsivePadding(
                  context,
                  AppTheme.defaultPadding,
                ),
              ),
              CustomTextField(
                label: 'Số điện thoại',
                controller: _phoneController,
                prefixIcon: Icons.phone,
                validator: _validatePhone,
                keyboardType: TextInputType.phone,
              ),
              SizedBox(
                height: AppTheme.responsivePadding(
                  context,
                  AppTheme.defaultPadding,
                ),
              ),
              CustomTextField(
                label: 'Email',
                controller: _emailController,
                prefixIcon: Icons.email,
                enabled: false,
                readOnly: true,
              ),
              SizedBox(
                height: AppTheme.responsivePadding(
                  context,
                  AppTheme.largePadding,
                ),
              ),
              CustomButton(
                text: 'Lưu thay đổi',
                onPressed: _isSaving ? null : _saveProfile,
                isLoading: _isSaving,
                type: ButtonType.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
