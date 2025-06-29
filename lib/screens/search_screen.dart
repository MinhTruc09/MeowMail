import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:mewmail/screens/gmail_detail_screen.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/widgets/common/skeleton_loading.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<InboxThread> _results = [];
  bool _isLoading = false;
  String? _error;
  String? myEmail;

  @override
  void initState() {
    super.initState();
    _loadMyEmail();
  }

  Future<void> _loadMyEmail() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      myEmail = prefs.getString('email');
    });
  }

  Future<void> _search(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _error = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        throw Exception('Please log in again');
      }

      // Get all inbox threads and filter by keyword
      final allThreads = await MailService.getInbox(
        token,
        page: 1,
        limit: 1000, // Get more results for better search
      );

      // No need to filter - API handles deleted threads
      final activeThreads = allThreads;

      // Filter threads based on search query
      final keyword = query.trim().toLowerCase();
      final filteredThreads =
          activeThreads.where((thread) {
            return (thread.subject?.toLowerCase().contains(keyword) ?? false) ||
                (thread.lastContent?.toLowerCase().contains(keyword) ??
                    false) ||
                (thread.lastSenderEmail?.toLowerCase().contains(keyword) ??
                    false) ||
                (thread.lastReceiverEmail?.toLowerCase().contains(keyword) ??
                    false);
          }).toList();

      setState(() {
        _results = filteredThreads;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      // If session expired, navigate to login
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        elevation: 0,
        title: const Text(
          'Tìm kiếm email',
          style: TextStyle(
            color: AppTheme.primaryWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Borel',
          ),
        ),
      ),
      body: Column(
        children: [
          // Search input
          Container(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Nhập từ khóa để tìm kiếm email...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            _searchController.clear();
                            _search('');
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: AppTheme.primaryBlack.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppTheme.primaryYellow),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Update UI for clear button
                // Debounce search
                Future.delayed(const Duration(milliseconds: 500), () {
                  if (_searchController.text == value) {
                    _search(value);
                  }
                });
              },
              onSubmitted: _search,
            ),
          ),

          // Results
          Expanded(
            child:
                _isLoading
                    ? const MailListSkeleton(itemCount: 6)
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
                            onPressed: () => _search(_searchController.text),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryYellow,
                              foregroundColor: AppTheme.primaryBlack,
                            ),
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    )
                    : _results.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search,
                            size: 64,
                            color: AppTheme.primaryBlack.withValues(alpha: 0.4),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Nhập từ khóa để bắt đầu tìm kiếm email'
                                : 'Không tìm thấy email nào phù hợp',
                            style: TextStyle(
                              color: AppTheme.primaryBlack.withValues(
                                alpha: 0.6,
                              ),
                              fontSize: 16,
                              fontFamily: 'Borel',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _results.length,
                      itemBuilder: (context, index) {
                        final thread = _results[index];
                        return SlideInAnimation(
                          delay: Duration(milliseconds: index * 50),
                          begin: const Offset(1.0, 0.0),
                          child: FadeInAnimation(
                            delay: Duration(milliseconds: index * 50),
                            child: MailListTile(
                              thread: thread,
                              myEmail: myEmail,
                              isStarred: false,
                              onTap: () {
                                if (thread.threadId > 0) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => GmailDetailScreen(
                                            threadId: thread.threadId,
                                          ),
                                    ),
                                  );
                                }
                              },
                              onMarkAsRead: null, // No mark as read in search
                              onSpam: null, // No spam action in search
                              onDelete: null, // No delete action in search
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
