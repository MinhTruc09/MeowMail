import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/send_mail_dialog.dart';

class HomeDrawer extends StatelessWidget {
  final String? userEmail;
  final VoidCallback? onRefresh;

  const HomeDrawer({
    super.key,
    this.userEmail,
    this.onRefresh,
  });

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    }
  }

  void _showSendMailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SendMailDialog(
        onSend: () {
          if (onRefresh != null) {
            onRefresh!();
          }
        },
      ),
    );
  }

  String _getInitials(String? email) {
    if (email == null || email.isEmpty) return 'U';
    return email.substring(0, 1).toUpperCase();
  }

  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'Người dùng';
    return email.split('@')[0];
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.primaryWhite,
      child: Column(
        children: [
          // Header với thông tin người dùng
          Container(
            width: double.infinity,
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 20,
              bottom: 20,
              left: 20,
              right: 20,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.primaryBlack,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 35,
                  backgroundColor: AppTheme.primaryYellow,
                  child: Text(
                    _getInitials(userEmail),
                    style: const TextStyle(
                      color: AppTheme.primaryBlack,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Borel',
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                // Tên người dùng
                Text(
                  _getDisplayName(userEmail),
                  style: const TextStyle(
                    color: AppTheme.primaryWhite,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Borel',
                  ),
                ),
                const SizedBox(height: 5),
                // Email
                Text(
                  userEmail ?? 'user@example.com',
                  style: const TextStyle(
                    color: AppTheme.primaryYellow,
                    fontSize: 14,
                    fontFamily: 'Borel',
                  ),
                ),
              ],
            ),
          ),
          
          // Menu items
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                const SizedBox(height: 10),
                
                // Soạn tin
                ListTile(
                  leading: const Icon(
                    Icons.edit,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                  title: const Text(
                    'Soạn tin',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
                      fontSize: 16,
                      fontFamily: 'Borel',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showSendMailDialog(context);
                  },
                ),
                
                const Divider(color: Colors.grey),
                
                // Hộp thư đến
                ListTile(
                  leading: const Icon(
                    Icons.inbox,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                  title: const Text(
                    'Hộp thư đến',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
                      fontSize: 16,
                      fontFamily: 'Borel',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    // Đã ở trang chủ rồi
                  },
                ),
                
                // Lịch sử
                ListTile(
                  leading: const Icon(
                    Icons.history,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                  title: const Text(
                    'Lịch sử',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
                      fontSize: 16,
                      fontFamily: 'Borel',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/history');
                  },
                ),
                
                // Cài đặt
                ListTile(
                  leading: const Icon(
                    Icons.settings,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                  title: const Text(
                    'Cài đặt',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
                      fontSize: 16,
                      fontFamily: 'Borel',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
                
                const Divider(color: Colors.grey),
                
                // Đăng xuất
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Colors.red,
                    size: 24,
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontFamily: 'Borel',
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  onTap: () => _logout(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
