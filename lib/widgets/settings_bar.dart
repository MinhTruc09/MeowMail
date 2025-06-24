import 'package:flutter/material.dart';
import 'theme.dart';

class SettingsBar extends StatelessWidget {
  final String username;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onEditProfile;
  final VoidCallback? onChangePassword;
  final VoidCallback? onSwitchAccount;
  final VoidCallback? onLogout;
  final bool darkMode;
  final ValueChanged<bool>? onDarkModeChanged;
  final VoidCallback? onAbout;
  final VoidCallback? onPolicy;
  final VoidCallback? onTerms;

  const SettingsBar({
    super.key,
    required this.username,
    required this.email,
    this.avatarUrl,
    this.onEditProfile,
    this.onChangePassword,
    this.onSwitchAccount,
    this.onLogout,
    this.darkMode = false,
    this.onDarkModeChanged,
    this.onAbout,
    this.onPolicy,
    this.onTerms,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 24),
        _ProfileHeader(username: username, email: email, avatarUrl: avatarUrl),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                _SettingsSection(
                  title: 'Quản lý tài khoản',
                  children: [
                    _SettingsItem(title: 'Chỉnh sửa thông tin', icon: Icons.chevron_right, onTap: onEditProfile),
                    _SettingsItem(title: 'Đổi mật khẩu', icon: Icons.chevron_right, onTap: onChangePassword),
                    _SettingsItem(title: 'Chuyển đổi tài khoản', icon: Icons.add, onTap: onSwitchAccount),
                    _SettingsSwitch(
                      title: 'Chế độ tối',
                      value: darkMode,
                      onChanged: onDarkModeChanged ?? (_) {},
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _SettingsSection(
                  title: 'Tìm hiểu thêm',
                  children: [
                    _SettingsItem(title: 'Tìm hiểu về chúng tôi', icon: Icons.chevron_right, onTap: onAbout),
                    _SettingsItem(title: 'Chính sách', icon: Icons.chevron_right, onTap: onPolicy),
                    _SettingsItem(title: 'Điều khoản dịch vụ', icon: Icons.chevron_right, onTap: onTerms),
                  ],
                ),
                const SizedBox(height: 8),
                _SettingsSection(
                  title: 'Tài khoản',
                  children: [
                    _SettingsItem(title: 'Đăng xuất', icon: Icons.logout, onTap: onLogout),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final String username;
  final String email;
  final String? avatarUrl;
  const _ProfileHeader({required this.username, required this.email, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 44,
          backgroundColor: AppTheme.primaryBlack,
          child: CircleAvatar(
            radius: 40,
            backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                ? NetworkImage(avatarUrl!)
                : const AssetImage('assets/images/icon.png') as ImageProvider,
          ),
        ),
        const SizedBox(height: 12),
        Text(username, style: Theme.of(context).textTheme.bodyMedium),
        Text(email, style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.black54)),
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
        color: AppTheme.primaryYellow,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
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
      title: Text(title, style: Theme.of(context).textTheme.labelLarge),
      trailing: Icon(icon, color: AppTheme.primaryBlack),
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
        Text(title, style: Theme.of(context).textTheme.labelLarge),
        Switch(value: value, onChanged: onChanged, activeColor: AppTheme.primaryBlack),
      ],
    );
  }
} 