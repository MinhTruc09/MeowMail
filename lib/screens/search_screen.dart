import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:mewmail/screens/chat_detail_screen.dart';
import 'package:mewmail/widgets/theme.dart';

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

      // Filter out deleted threads from local storage
      final deletedThreadIds = prefs.getStringList('deleted_threads') ?? [];
      final deletedIds =
          deletedThreadIds
              .map((id) => int.tryParse(id))
              .where((id) => id != null)
              .cast<int>()
              .toSet();

      final activeThreads =
          allThreads
              .where((thread) => !deletedIds.contains(thread.threadId))
              .toList();

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
                  borderSide: BorderSide(color: Colors.grey[300]!),
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
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryYellow,
                      ),
                    )
                    : _error != null
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 64,
                            color: Colors.red[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _error!,
                            style: TextStyle(
                              color: Colors.red[600],
                              fontSize: 16,
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
                          Icon(Icons.search, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _searchController.text.isEmpty
                                ? 'Nhập từ khóa để bắt đầu tìm kiếm email'
                                : 'Không tìm thấy email nào phù hợp',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
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
                        return MailListTile(
                          thread: thread,
                          myEmail: myEmail,
                          isStarred: false,
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
                            }
                          },
                          onMarkAsRead: null, // No mark as read in search
                          onSpam: null, // No spam action in search
                          onDelete: null, // No delete action in search
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
