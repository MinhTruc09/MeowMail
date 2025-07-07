import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/services/avatar_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/screens/gmail_detail_screen.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/home_drawer.dart';
import 'package:mewmail/widgets/send_mail_dialog.dart';
import 'package:mewmail/widgets/create_group_dialog.dart';
import 'package:mewmail/widgets/common/skeleton_loading.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<InboxThread> inboxThreads = [];
  bool isLoading = true;
  bool _isLoadingData = false;
  bool _loadedOnce = false;
  String? _error;
  String? token;
  int _currentPage = 1;
  final int _limit = 10;
  String? myEmail;

  @override
  void initState() {
    super.initState();
    _loadMyEmail();
    _loadData();
  }

  Future<void> _loadMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myEmail = prefs.getString('email');
    });
  }

  /// Build user avatar for app bar
  Widget _buildUserAvatar() {
    if (myEmail == null) {
      return CircleAvatar(
        radius: 16,
        backgroundColor: AppTheme.primaryYellow,
        child: const Text(
          'A',
          style: TextStyle(
            color: AppTheme.primaryBlack,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return FutureBuilder<String?>(
      future: AvatarService.getUserAvatar(myEmail!),
      builder: (context, snapshot) {
        final avatarUrl = snapshot.data;
        return CircleAvatar(
          radius: 16,
          backgroundColor: AvatarService.getAvatarColor(myEmail!),
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
          child:
              avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                    AvatarService.getAvatarInitials(myEmail!),
                    style: const TextStyle(
                      color: AppTheme.primaryWhite,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  )
                  : null,
        );
      },
    );
  }

  Future<void> _loadData({bool force = false}) async {
    if (_loadedOnce && !force || _isLoadingData) return;
    setState(() {
      isLoading = true;
      _error = null;
      _isLoadingData = true;
    });

    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');

    if (token == null || token!.isEmpty) {
      setState(() {
        isLoading = false;
        _isLoadingData = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Vui lòng đăng nhập lại')));
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    try {
      debugPrint('🔄 Đang load inbox với token: ${token!.substring(0, 10)}...');
      final threads = await MailService.getInbox(
        token!,
        page: _currentPage,
        limit: _limit,
      ).timeout(const Duration(seconds: 15));
      debugPrint('✅ Đã nhận được ${threads.length} threads từ API');

      // Sắp xếp theo thời gian mới nhất trước
      threads.sort((a, b) {
        final aTime = a.lastCreatedAt ?? DateTime.now();
        final bTime = b.lastCreatedAt ?? DateTime.now();
        return bTime.compareTo(aTime); // Mới nhất trước
      });

      final filteredThreads = threads;

      debugPrint('✅ Hiển thị ${filteredThreads.length} threads từ API');

      if (mounted) {
        setState(() {
          inboxThreads = filteredThreads;
          isLoading = false;
          _loadedOnce = true;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
          _error =
              'Lỗi tải dữ liệu: ${e.toString().replaceAll('Exception: ', '')}';
          _isLoadingData = false;
        });
        if (e.toString().contains('Session expired')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại'),
            ),
          );
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
      debugPrint('❌ Lỗi khi load inbox: $e');
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _currentPage = 1;
      inboxThreads = [];
    });
    await _loadData(force: true);
  }

  Widget _buildEmailSections() {
    if (inboxThreads.isEmpty) {
      return FadeInAnimation(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: AppTheme.primaryBlack.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hộp thư trống',
                style: TextStyle(
                  color: AppTheme.primaryBlack,
                  fontSize: 16,
                  fontFamily: 'Borel',
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Chia email thành 2 nhóm
    final unreadThreads =
        inboxThreads
            .where((thread) => thread.read == false || thread.read == null)
            .toList();
    final readThreads =
        inboxThreads.where((thread) => thread.read == true).toList();

    return CustomScrollView(
      slivers: [
        // Header thống kê
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppTheme.primaryYellow.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.mail_outline,
                  color: AppTheme.primaryBlack,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Bạn có ${unreadThreads.length} email chưa đọc',
                  style: const TextStyle(
                    color: AppTheme.primaryBlack,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Borel',
                  ),
                ),
              ],
            ),
          ),
        ),

        // Section Email chưa đọc
        if (unreadThreads.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Email chưa đọc',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryBlack,
                      fontFamily: 'Borel',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${unreadThreads.length}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildEmailTile(unreadThreads[index], index, true),
              childCount: unreadThreads.length,
            ),
          ),
        ],

        // Section Email đã đọc
        if (readThreads.isNotEmpty) ...[
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlack.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Email đã đọc',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryBlack.withValues(alpha: 0.7),
                      fontFamily: 'Borel',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${readThreads.length}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryBlack.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  _buildEmailTile(readThreads[index], index, false),
              childCount: readThreads.length,
            ),
          ),
        ],

        // Padding cuối
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }

  Widget _buildEmailTile(InboxThread thread, int index, bool isUnread) {
    return SlideInAnimation(
      delay: Duration(milliseconds: index * 50),
      begin: const Offset(1.0, 0.0),
      child: FadeInAnimation(
        delay: Duration(milliseconds: index * 50),
        child: Dismissible(
          key: Key('email_${thread.threadId}'),
          background: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 20),
            child: const Row(
              children: [
                Icon(Icons.report, color: Colors.white, size: 24),
                SizedBox(width: 8),
                Text(
                  'Spam',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          secondaryBackground: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Xóa',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.delete, color: Colors.white, size: 24),
              ],
            ),
          ),
          onDismissed: (direction) {
            if (direction == DismissDirection.startToEnd) {
              // Swipe right - Mark as spam
              _markAsSpam([thread.threadId]);
            } else if (direction == DismissDirection.endToStart) {
              // Swipe left - Delete
              _deleteThreads([thread.threadId]);
            }
          },
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color:
                  isUnread
                      ? AppTheme.primaryYellow.withValues(alpha: 0.05)
                      : AppTheme.primaryWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color:
                    isUnread
                        ? AppTheme.primaryYellow.withValues(alpha: 0.2)
                        : AppTheme.primaryBlack.withValues(alpha: 0.1),
                width: isUnread ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryBlack.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _navigateToEmailDetail(thread),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header với avatar và thông tin người gửi
                      Row(
                        children: [
                          // Avatar người gửi
                          CircleAvatar(
                            radius: 20,
                            backgroundColor: AvatarService.getAvatarColor(
                              thread.lastSenderEmail ?? 'unknown',
                            ),
                            child: Text(
                              AvatarService.getAvatarInitials(
                                thread.lastSenderEmail ?? 'U',
                              ),
                              style: const TextStyle(
                                color: AppTheme.primaryWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Thông tin người gửi và thời gian
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        thread.lastSenderEmail ?? 'Không rõ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight:
                                              isUnread
                                                  ? FontWeight.bold
                                                  : FontWeight.w500,
                                          color: AppTheme.primaryBlack,
                                          fontFamily: 'Borel',
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    if (isUnread)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppTheme.primaryYellow,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                Text(
                                  _formatTime(thread.lastCreatedAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.primaryBlack.withValues(
                                      alpha: 0.6,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Tiêu đề email
                      Text(
                        thread.subject ?? 'Không có tiêu đề',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                              isUnread ? FontWeight.bold : FontWeight.w600,
                          color: AppTheme.primaryBlack,
                          fontFamily: 'Borel',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      // Nội dung preview
                      Text(
                        thread.lastContent ?? 'Không có nội dung',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryBlack.withValues(alpha: 0.7),
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (isUnread)
                            _buildActionButton(
                              icon: Icons.mark_email_read,
                              label: 'Đánh dấu đã đọc',
                              onTap: () => _markAsRead([thread.threadId]),
                            ),
                          const SizedBox(width: 8),
                          _buildActionButton(
                            icon: Icons.reply,
                            label: 'Trả lời',
                            onTap: () => _navigateToEmailDetail(thread),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.primaryYellow.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppTheme.primaryYellow.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.primaryBlack),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppTheme.primaryBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime? dateTime) {
    if (dateTime == null) return 'Không rõ';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  void _navigateToEmailDetail(InboxThread thread) {
    if (thread.threadId > 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => GmailDetailScreen(threadId: thread.threadId),
        ),
      ).then((_) {
        // Refresh data khi quay lại từ detail screen
        _loadData(force: true);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy hội thoại!')),
      );
    }
  }

  void _showSendMailDialog() {
    showDialog(
      context: context,
      builder:
          (context) => SendMailDialog(onSend: () => _loadData(force: true)),
    );
  }

  Future<void> _markAllAsRead() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      // Get all unread thread IDs
      final unreadThreadIds =
          inboxThreads
              .where((thread) => thread.read == false || thread.read == null)
              .map((thread) => thread.threadId)
              .toList();

      if (unreadThreadIds.isEmpty) return;

      await MailService.readMail(token: token, threadIds: unreadThreadIds);

      // Refresh data
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu tất cả email là đã đọc'),
            backgroundColor: AppTheme.primaryYellow,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppTheme.primaryBlack,
          ),
        );
      }
    }
  }

  void _showCreateGroupDialog() {
    showDialog(
      context: context,
      builder:
          (context) => CreateGroupDialog(
            onGroupCreated: () {
              _loadData(force: true);
            },
          ),
    );
  }

  Future<void> _markAsRead(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      debugPrint('📖 Gửi yêu cầu readMail: threadIds=$threadIds');
      await MailService.readMail(token: token, threadIds: threadIds);

      // Refresh data
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu email là đã đọc'),
            backgroundColor: AppTheme.primaryYellow,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Lỗi _markAsRead: $e');

      if (mounted) {
        // If session expired, logout and redirect to login
        if (AuthService.shouldRedirectToLogin(e.toString())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
          await AuthService.logout();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đánh dấu đã đọc: $e'),
              backgroundColor: AppTheme.primaryBlack,
            ),
          );
        }
      }
    }
  }

  Future<void> _markAsSpam(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      // Mark as spam via API only - no local storage
      await MailService.spamMail(token: token, threadIds: threadIds);

      debugPrint('✅ Đã đánh dấu ${threadIds.length} threads là spam qua API');

      // Refresh data to get updated list from server
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu email là spam'),
            backgroundColor: AppTheme.primaryYellow,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Lỗi _markAsSpam: $e');

      if (mounted) {
        // If session expired, logout and redirect to login
        if (AuthService.shouldRedirectToLogin(e.toString())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
          await AuthService.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi đánh dấu spam: $e'),
              backgroundColor: AppTheme.primaryBlack,
            ),
          );
        }
      }
    }
  }

  Future<void> _deleteThreads(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      // Delete via API only - no local storage
      await MailService.deleteThreads(token: token, threadIds: threadIds);

      debugPrint('✅ Đã xóa ${threadIds.length} threads qua API');

      // Refresh data to get updated list from server
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa email'),
            backgroundColor: AppTheme.primaryBlack,
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Lỗi _deleteThreads: $e');

      if (mounted) {
        // If session expired, logout and redirect to login
        if (AuthService.shouldRedirectToLogin(e.toString())) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại'),
              backgroundColor: AppTheme.primaryYellow,
            ),
          );
          await AuthService.logout();
          if (mounted) {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi xóa email: $e'),
              backgroundColor: AppTheme.primaryBlack,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      drawer: HomeDrawer(
        userEmail: myEmail,
        onRefresh: () => _loadData(force: true),
        key: ValueKey(myEmail), // Force rebuild when email changes
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: Builder(
          builder:
              (context) => IconButton(
                icon: const Icon(Icons.menu, color: AppTheme.primaryWhite),
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
        ),
        title: const Text(
          'Hộp thư đến',
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            fontFamily: 'Borel',
          ),
        ),
        actions: [
          // Search button
          IconButton(
            icon: const Icon(Icons.search, color: AppTheme.primaryWhite),
            onPressed: () {
              Navigator.pushNamed(context, '/search');
            },
            tooltip: 'Tìm kiếm email',
          ),
          // Mark all as read button
          if (inboxThreads
              .where((thread) => thread.read == false || thread.read == null)
              .isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.mark_email_read,
                color: AppTheme.primaryWhite,
              ),
              onPressed: _markAllAsRead,
              tooltip: 'Đánh dấu tất cả đã đọc',
            ),
          // More options menu
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppTheme.primaryWhite),
            onSelected: (value) {
              switch (value) {
                case 'create_group':
                  _showCreateGroupDialog();
                  break;
                case 'history':
                  Navigator.pushNamed(context, '/history');
                  break;
                case 'settings':
                  Navigator.pushNamed(context, '/settings');
                  break;
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'create_group',
                    child: Row(
                      children: [
                        Icon(Icons.group_add, color: AppTheme.primaryBlack),
                        SizedBox(width: 8),
                        Text('Tạo nhóm email'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'history',
                    child: Row(
                      children: [
                        Icon(Icons.history, color: AppTheme.primaryBlack),
                        SizedBox(width: 8),
                        Text('Lịch sử'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'settings',
                    child: Row(
                      children: [
                        Icon(Icons.settings, color: AppTheme.primaryBlack),
                        SizedBox(width: 8),
                        Text('Cài đặt'),
                      ],
                    ),
                  ),
                ],
          ),
          IconButton(
            icon: _buildUserAvatar(),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const MailListSkeleton(itemCount: 8)
              : _error != null
              ? FadeInAnimation(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: AppTheme.primaryBlack.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: AppTheme.primaryBlack),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _loadData(force: true),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                ),
              )
              : RefreshIndicator(
                onRefresh: _refresh,
                child: _buildEmailSections(),
              ),
      floatingActionButton: ScaleInAnimation(
        delay: const Duration(milliseconds: 800),
        child: BouncyButton(
          onTap: _showSendMailDialog,
          child: FloatingActionButton(
            onPressed: null, // Handled by BouncyButton
            backgroundColor: AppTheme.primaryYellow,
            foregroundColor: AppTheme.primaryBlack,
            child: const Icon(Icons.create),
          ),
        ),
      ),
    );
  }
}
