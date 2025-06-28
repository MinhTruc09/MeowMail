import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/screens/chat_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  List<InboxThread> _allThreads = [];
  List<InboxThread> _deletedThreads = [];
  List<InboxThread> _spamThreads = [];
  bool _isLoading = false;
  String? _error;
  String? myEmail;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadMyEmail();
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myEmail = prefs.getString('email');
    });
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }

      // Try to load spam and deleted emails using separate API endpoints
      // If they don't exist, fall back to filtering from inbox
      List<InboxThread> spamThreads = [];
      List<InboxThread> deletedThreads = [];

      // Get spam emails (now uses fallback automatically)
      spamThreads = await MailService.getSpamEmails(
        token,
        page: 1,
        limit: 1000,
      );

      // Get deleted emails (now uses local storage automatically)
      deletedThreads = await MailService.getDeletedEmails(
        token,
        page: 1,
        limit: 1000,
      );

      // No need for fallback anymore since the methods handle it internally

      if (mounted) {
        setState(() {
          _spamThreads = spamThreads;
          _deletedThreads = deletedThreads;
          _allThreads = [...spamThreads, ...deletedThreads];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }

      if (e.toString().contains('Session expired') ||
          e.toString().contains('401') ||
          e.toString().contains('403')) {
        if (mounted) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    }
  }

  Future<void> _restoreFromSpam(List<int> threadIds) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng khôi phục từ spam chưa được hỗ trợ'),
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

  Future<void> _restoreFromDeleted(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Remove from local deleted threads list to restore them
      final deletedThreads = prefs.getStringList('deleted_threads') ?? [];
      for (int threadId in threadIds) {
        deletedThreads.remove(threadId.toString());
      }
      await prefs.setStringList('deleted_threads', deletedThreads);

      // Refresh data after restore
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã khôi phục email từ thùng rác'),
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

  Future<void> _permanentDelete(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      await MailService.deleteThreads(token: token, threadIds: threadIds);

      // Remove from local deleted threads list since they're permanently deleted
      final deletedThreads = prefs.getStringList('deleted_threads') ?? [];
      for (int threadId in threadIds) {
        deletedThreads.remove(threadId.toString());
      }
      await prefs.setStringList('deleted_threads', deletedThreads);

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa vĩnh viễn'),
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
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        elevation: 0,
        title: const Text(
          'Lịch sử',
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Borel',
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.primaryYellow,
          labelColor: AppTheme.primaryYellow,
          unselectedLabelColor: Colors.grey[400],
          tabs: const [
            Tab(icon: Icon(Icons.report), text: 'Spam'),
            Tab(icon: Icon(Icons.delete), text: 'Đã xóa'),
          ],
        ),
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryYellow),
              )
              : _error != null
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: TextStyle(color: Colors.red[600], fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadData,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryYellow,
                        foregroundColor: AppTheme.primaryBlack,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              )
              : TabBarView(
                controller: _tabController,
                children: [
                  // Spam tab
                  _buildEmailList(
                    _spamThreads,
                    emptyMessage: 'Không có email spam',
                    onRestore: _restoreFromSpam,
                    onDelete: _permanentDelete,
                    isSpamTab: true,
                  ),
                  // Deleted tab
                  _buildEmailList(
                    _deletedThreads,
                    emptyMessage: 'Không có email đã xóa',
                    onRestore: _restoreFromDeleted, // Add restore for deleted
                    onDelete: _permanentDelete,
                    isSpamTab: false,
                  ),
                ],
              ),
    );
  }

  Widget _buildEmailList(
    List<InboxThread> threads, {
    required String emptyMessage,
    required Function(List<int>)? onRestore,
    required Function(List<int>) onDelete,
    required bool isSpamTab,
  }) {
    if (threads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSpamTab ? Icons.report_off : Icons.delete_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: threads.length,
      itemBuilder: (context, index) {
        final thread = threads[index];
        return MailListTile(
          thread: thread,
          myEmail: myEmail,
          isStarred: false,
          onTap: () {
            if (thread.threadId > 0) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatDetailScreen(threadId: thread.threadId),
                ),
              );
            }
          },
          onMarkAsRead:
              onRestore != null ? () => onRestore([thread.threadId]) : null,
          onSpam: null, // No spam action in history
          onDelete: () => onDelete([thread.threadId]),
        );
      },
    );
  }
}
