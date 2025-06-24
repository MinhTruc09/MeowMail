import 'package:flutter/material.dart';
import 'package:mewmail/widgets/settings_bar.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/models/user/profile_response.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'about_screen.dart';
import 'policy_screen.dart';
import 'terms_screen.dart';
import 'edit_profile_screen.dart';
import 'login_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ProfileResponseDto? user;
  bool isLoading = true;
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDarkMode();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() { isLoading = false; });
      return;
    }
    try {
      final res = await UserService.myProfile(token);
      setState(() {
        user = res.data;
        isLoading = false;
      });
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Không lấy được thông tin tài khoản!')),
      );
    }
  }

  Future<void> _loadDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    setState(() { darkMode = value; });
  }

  void _onLogout() async {
    await AuthService.logout();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cài đặt')),
        body: const Center(child: Text('Không có thông tin tài khoản!')),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Cài đặt')),
      body: SettingsBar(
        username: user!.fullname,
        email: user!.email,
        avatarUrl: user!.avatar,
        darkMode: darkMode,
        onDarkModeChanged: _setDarkMode,
        onEditProfile: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const EditProfileScreen()),
        ),
        onChangePassword: () {
          // TODO: Thêm màn hình đổi mật khẩu nếu có
        },
        onSwitchAccount: () {
          // TODO: Thêm chức năng chuyển đổi tài khoản nếu có
        },
        onAbout: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutScreen()),
        ),
        onPolicy: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PolicyScreen()),
        ),
        onTerms: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TermsScreen()),
        ),
        onLogout: _onLogout,
      ),
    );
  }
} 