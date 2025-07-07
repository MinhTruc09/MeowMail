import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/send_mail_dialog.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/models/user/profile_response.dart';

class HomeDrawer extends StatefulWidget {
  final String? userEmail;
  final VoidCallback? onRefresh;

  const HomeDrawer({super.key, this.userEmail, this.onRefresh});

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  ProfileResponseDto? _userProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Method to refresh user profile (call this when user updates profile)
  void refreshProfile() {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token != null) {
        final response = await UserService.myProfile(token);
        if (mounted) {
          setState(() {
            _userProfile = response.data;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('❌ Lỗi load user profile trong drawer: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    if (context.mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _showSendMailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => SendMailDialog(
            onSend: () {
              if (widget.onRefresh != null) {
                widget.onRefresh!();
              }
            },
          ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.isEmpty) return 'U';
    return name.substring(0, 1).toUpperCase();
  }

  String _getDisplayName() {
    if (_userProfile?.fullname != null && _userProfile!.fullname!.isNotEmpty) {
      return _userProfile!.fullname!;
    }
    if (widget.userEmail != null && widget.userEmail!.isNotEmpty) {
      return widget.userEmail!.split('@')[0];
    }
    return 'Người dùng';
  }

  String _getUserEmail() {
    return _userProfile?.email ?? widget.userEmail ?? 'Không có email';
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
            decoration: const BoxDecoration(color: AppTheme.primaryBlack),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar
                _isLoading
                    ? const CircularProgressIndicator(
                      color: AppTheme.primaryYellow,
                    )
                    : CircleAvatar(
                      radius: 35,
                      backgroundColor: AppTheme.primaryYellow,
                      backgroundImage:
                          _userProfile?.avatar != null &&
                                  _userProfile!.avatar!.isNotEmpty
                              ? NetworkImage(_userProfile!.avatar!)
                              : null,
                      child:
                          _userProfile?.avatar == null ||
                                  _userProfile!.avatar!.isEmpty
                              ? Text(
                                _getInitials(_getDisplayName()),
                                style: const TextStyle(
                                  color: AppTheme.primaryBlack,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Borel',
                                ),
                              )
                              : null,
                    ),
                const SizedBox(height: 15),
                // Tên người dùng
                Text(
                  _getDisplayName(),
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
                  _getUserEmail(),
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

                Divider(color: AppTheme.primaryBlack.withValues(alpha: 0.2)),

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

                Divider(color: AppTheme.primaryBlack.withValues(alpha: 0.2)),

                // Đăng xuất
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: AppTheme.primaryBlack,
                    size: 24,
                  ),
                  title: const Text(
                    'Đăng xuất',
                    style: TextStyle(
                      color: AppTheme.primaryBlack,
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
