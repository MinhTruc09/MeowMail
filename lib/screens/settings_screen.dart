import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/widgets/home_bottom_nav.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String username = '';
  String email = '';
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final accountsRaw = prefs.getString('accounts');
    if (accountsRaw != null) {
      final accounts = List<Map<String, dynamic>>.from(
        (accountsRaw.isNotEmpty) ? List<Map<String, dynamic>>.from(List<dynamic>.from(accountsRaw.codeUnits.map((e) => String.fromCharCode(e)).join() == '' ? [] : List<dynamic>.from(List<dynamic>.from(List<dynamic>.from(accountsRaw.codeUnits.map((e) => String.fromCharCode(e)).join() == '' ? [] : List<dynamic>.from([])))))) : []);
      if (accounts.isNotEmpty) {
        setState(() {
          username = accounts[0]['username'] ?? '';
          email = accounts[0]['email'] ?? '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            _ProfileHeader(username: username, email: email),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _SettingsSection(
                      title: 'Quản lý tài khoản',
                      children: [
                        _SettingsItem(title: 'Chỉnh sửa thông tin', icon: Icons.chevron_right, onTap: () {}),
                        _SettingsItem(title: 'Đổi mật khẩu', icon: Icons.chevron_right, onTap: () {}),
                        _SettingsItem(title: 'Chuyển đổi tài khoản', icon: Icons.add, onTap: () {}),
                        _SettingsSwitch(
                          title: 'Chế độ tối',
                          value: darkMode,
                          onChanged: (v) => setState(() => darkMode = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _SettingsSection(
                      title: 'Tìm hiểu thêm',
                      children: [
                        _SettingsItem(title: 'Tìm hiểu về chúng tôi', icon: Icons.chevron_right, onTap: () {}),
                        _SettingsItem(title: 'Chính sách', icon: Icons.chevron_right, onTap: () {}),
                        _SettingsItem(title: 'Điều khoản dịch vụ', icon: Icons.chevron_right, onTap: () {}),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const HomeBottomNav(currentIndex: 3),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  const _ProfileHeader({required this.username, required this.email});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: Colors.black,
          child: CircleAvatar(
            radius: 40,
            backgroundImage: AssetImage('assets/images/icon.png'), // Thay bằng avatar user nếu có
          ),
        ),
        const SizedBox(height: 12),
        Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Borel')),
        Text(email, style: const TextStyle(fontSize: 15, color: Colors.black54, fontFamily: 'Borel')),
      ],
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC00),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Borel')),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _SettingsItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  const _SettingsItem({required this.title, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title, style: const TextStyle(fontSize: 15, fontFamily: 'Borel')),
      trailing: Icon(icon, color: Colors.black),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SettingsSwitch({required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 15, fontFamily: 'Borel')),
        Switch(value: value, onChanged: onChanged, activeColor: Colors.black),
      ],
    );
  }
} 