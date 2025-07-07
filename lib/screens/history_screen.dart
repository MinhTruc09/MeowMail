import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/screens/gmail_detail_screen.dart';

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
      debugPrint('📡 Loading spam emails...');
      spamThreads = await MailService.getSpamEmails(
        token,
        page: 1,
        limit: 1000,
      );
      debugPrint('✅ Loaded ${spamThreads.length} spam emails');

      // Get deleted emails (now uses local storage automatically)
      debugPrint('📡 Loading deleted emails...');
      deletedThreads = await MailService.getDeletedEmails(
        token,
        page: 1,
        limit: 1000,
      );
      debugPrint('✅ Loaded ${deletedThreads.length} deleted emails');

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

  Future<void> _restoreFromDeleted(List<int> threadIds) async {
    try {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tính năng khôi phục chưa được hỗ trợ'),
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

  Future<void> _permanentDelete(List<int> threadIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');

      // Delete via API only - no local storage
      await MailService.deleteThreads(token: token, threadIds: threadIds);

      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa vĩnh viễn'),
            backgroundColor: AppTheme.primaryBlack,
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
          unselectedLabelColor: AppTheme.primaryBlack.withValues(alpha: 0.4),
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
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.primaryBlack,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: const TextStyle(
                        color: AppTheme.primaryBlack,
                        fontSize: 16,
                        fontFamily: 'Borel',
                      ),
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
              color: AppTheme.primaryBlack.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              emptyMessage,
              style: TextStyle(
                color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                fontSize: 16,
                fontFamily: 'Borel',
              ),
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
                  builder: (_) => GmailDetailScreen(threadId: thread.threadId),
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
