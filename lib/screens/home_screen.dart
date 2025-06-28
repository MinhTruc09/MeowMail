import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/services/avatar_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/screens/chat_detail_screen.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/home_drawer.dart';
import 'package:mewmail/widgets/send_mail_dialog.dart';
import 'package:mewmail/widgets/create_group_dialog.dart';

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
                      color: Colors.white,
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

      // Filter out deleted threads from local storage
      final deletedThreadIds = prefs.getStringList('deleted_threads') ?? [];
      final deletedIds =
          deletedThreadIds
              .map((id) => int.tryParse(id))
              .where((id) => id != null)
              .cast<int>()
              .toSet();

      final filteredThreads =
          threads
              .where((thread) => !deletedIds.contains(thread.threadId))
              .toList();
      debugPrint(
        '✅ Sau khi filter: ${filteredThreads.length} threads (đã loại bỏ ${threads.length - filteredThreads.length} threads đã xóa)',
      );

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
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
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

      await MailService.readMail(token: token, threadIds: threadIds);

      // Refresh data
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu email là đã đọc'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _markAsSpam(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      await MailService.spamMail(token: token, threadIds: threadIds);

      // Refresh data
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã đánh dấu email là spam'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteThreads(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      await MailService.deleteThreads(token: token, threadIds: threadIds);

      // Store deleted thread IDs locally for history tracking
      final deletedThreads = prefs.getStringList('deleted_threads') ?? [];
      for (int threadId in threadIds) {
        if (!deletedThreads.contains(threadId.toString())) {
          deletedThreads.add(threadId.toString());
        }
      }
      await prefs.setStringList('deleted_threads', deletedThreads);

      // Refresh data
      await _loadData(force: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa email'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.red),
        );
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
      body: Column(
        children: [
          // Unread count info
          if (inboxThreads
              .where((thread) => thread.read == false || thread.read == null)
              .isNotEmpty)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryYellow.withOpacity(0.3),
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
                    'Bạn có ${inboxThreads.where((thread) => thread.read == false || thread.read == null).length} email chưa đọc',
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
          // Email list
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _error != null
                    ? Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _refresh,
                      child:
                          inboxThreads.isEmpty
                              ? const Center(child: Text('Hộp thư trống'))
                              : ListView.builder(
                                itemCount: inboxThreads.length,
                                itemBuilder: (context, index) {
                                  final thread = inboxThreads[index];
                                  return MailListTile(
                                    thread: thread,
                                    myEmail: myEmail,
                                    isStarred:
                                        false, // TODO: truyền trạng thái star nếu có
                                    onTap: () {
                                      if (thread.threadId > 0) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => ChatDetailScreen(
                                                  threadId: thread.threadId,
                                                ),
                                          ),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Không tìm thấy hội thoại!',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    onMarkAsRead:
                                        () => _markAsRead([thread.threadId]),
                                    onSpam:
                                        () => _markAsSpam([thread.threadId]),
                                    onDelete:
                                        () => _deleteThreads([thread.threadId]),
                                  );
                                },
                              ),
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showSendMailDialog,
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        child: const Icon(Icons.create),
      ),
    );
  }
}
