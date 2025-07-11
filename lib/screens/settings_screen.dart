import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/user_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/services/avatar_service.dart';
import 'package:mewmail/models/user/profile_response.dart';
import 'package:mewmail/screens/change_password_screen.dart';
import 'package:mewmail/widgets/common/custom_widgets.dart';
import 'package:mewmail/widgets/common/custom_card.dart';
import 'package:mewmail/widgets/common/skeleton_loading.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  ProfileResponseDto? profile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile({bool force = false}) async {
    if (!force && !isLoading) {
      setState(() => isLoading = true);
    }

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    try {
      final res = await UserService.myProfile(token);
      if (mounted) {
        setState(() {
          profile = res.data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi lấy thông tin: $e')));
      }
    }
  }

  void _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Đăng xuất'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      await AuthService.logout();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã đăng xuất thành công!')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: AppTheme.primaryWhite,
        body: LoadingWidget(message: 'Đang tải thông tin...'),
      );
    }

    if (profile == null) {
      return Scaffold(
        backgroundColor: AppTheme.primaryWhite,
        body: EmptyStateWidget(
          title: 'Không thể tải thông tin',
          subtitle: 'Vui lòng thử lại sau',
          icon: Icons.error_outline,
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      body: RefreshIndicator(
        onRefresh: () => _loadProfile(force: true),
        child:
            isLoading
                ? SingleChildScrollView(
                  child: Column(
                    children: [
                      const ProfileSkeleton(),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.6,
                        child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: AppTheme.responsivePadding(
                                  context,
                                  AppTheme.defaultPadding,
                                ),
                                vertical: AppTheme.responsivePadding(
                                  context,
                                  AppTheme.smallPadding,
                                ),
                              ),
                              child: SkeletonLoading(
                                height: 60,
                                borderRadius: BorderRadius.circular(12),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                )
                : FadeInAnimation(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Profile Section
                        SlideInAnimation(
                          begin: const Offset(0.0, -0.5),
                          child: Container(
                            padding: EdgeInsets.all(
                              AppTheme.responsivePadding(
                                context,
                                AppTheme.defaultPadding,
                              ),
                            ),
                            child: ProfileCard(
                              name: profile!.fullname,
                              email: profile!.email,
                              avatarUrl: profile!.avatar,
                            ),
                          ),
                        ),

                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: AppTheme.responsivePadding(
                              context,
                              AppTheme.defaultPadding,
                            ),
                          ),
                          child: StaggeredListAnimation(
                            staggerDelay: const Duration(milliseconds: 100),
                            children: [
                              InfoCard(
                                title: 'Chỉnh sửa thông tin',
                                icon: Icons.edit,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () async {
                                  final result = await Navigator.pushNamed(
                                    context,
                                    '/edit_profile',
                                  );
                                  if (result == true) {
                                    // Clear avatar cache and reload profile
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    final myEmail = prefs.getString('email');
                                    if (myEmail != null) {
                                      AvatarService.clearAvatarCache(myEmail);
                                    }
                                    _loadProfile(); // Reload profile after successful edit
                                  }
                                },
                              ),

                              InfoCard(
                                title: 'Đổi mật khẩu',
                                icon: Icons.lock,
                                trailing: const Icon(Icons.chevron_right),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const ChangePasswordScreen(),
                                    ),
                                  );
                                },
                              ),

                              InfoCard(
                                title: 'Chuyển đổi tài khoản',
                                icon: Icons.switch_account,
                                trailing: const Icon(Icons.add),
                                onTap: () {
                                  // TODO: Chuyển đổi tài khoản
                                },
                              ),

                              InfoCard(
                                title: 'Chế độ tối',
                                icon: Icons.dark_mode,
                                trailing: Switch(
                                  value:
                                      false, // TODO: Thay bằng biến trạng thái dark mode
                                  onChanged: (val) {
                                    // TODO: Xử lý chuyển dark mode
                                  },
                                ),
                              ),

                              InfoCard(
                                title: 'Tìm hiểu về chúng tôi',
                                icon: Icons.info_outline,
                                trailing: const Icon(Icons.chevron_right),
                                backgroundColor: AppTheme.primaryYellow
                                    .withValues(alpha: 0.7),
                                onTap:
                                    () =>
                                        Navigator.pushNamed(context, '/about'),
                              ),

                              InfoCard(
                                title: 'Chính sách',
                                icon: Icons.policy,
                                trailing: const Icon(Icons.chevron_right),
                                backgroundColor: AppTheme.primaryYellow
                                    .withValues(alpha: 0.7),
                                onTap:
                                    () =>
                                        Navigator.pushNamed(context, '/policy'),
                              ),

                              InfoCard(
                                title: 'Điều khoản dịch vụ',
                                icon: Icons.rule,
                                trailing: const Icon(Icons.chevron_right),
                                backgroundColor: AppTheme.primaryYellow
                                    .withValues(alpha: 0.7),
                                onTap:
                                    () =>
                                        Navigator.pushNamed(context, '/terms'),
                              ),

                              InfoCard(
                                title: 'Đăng xuất',
                                icon: Icons.logout,
                                backgroundColor: AppTheme.primaryWhite,
                                onTap: _logout,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }
}
