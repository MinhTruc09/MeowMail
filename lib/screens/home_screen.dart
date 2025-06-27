import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/screens/chat_detail_screen.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/home_drawer.dart';
import 'package:mewmail/widgets/send_mail_dialog.dart';

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

      if (mounted) {
        setState(() {
          inboxThreads = threads;
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
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications, color: AppTheme.primaryWhite),
                // Badge hiển thị số tin chưa đọc
                if (inboxThreads
                    .where(
                      (thread) => thread.read == false || thread.read == null,
                    )
                    .isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryYellow,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${inboxThreads.where((thread) => thread.read == false || thread.read == null).length}',
                        style: const TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.pushNamed(context, '/history');
            },
          ),
          IconButton(
            icon: CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryYellow,
              child: Text(
                myEmail?.substring(0, 1).toUpperCase() ?? 'A',
                style: const TextStyle(
                  color: AppTheme.primaryBlack,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
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
