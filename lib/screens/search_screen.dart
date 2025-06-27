import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
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

  Future<void> _search() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) {
      setState(() {
        _isLoading = false;
        _error = 'Vui lòng đăng nhập lại';
      });
      return;
    }
    try {
      // Get all inbox threads and filter locally since there's no search API
      final searchQuery = _searchController.text.trim().toLowerCase();
      if (searchQuery.isEmpty) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
        return;
      }

      // Get inbox threads with a larger limit to search through more emails
      final allThreads = await MailService.getInbox(token, page: 1, limit: 100);

      // Filter threads based on search query
      final filteredResults =
          allThreads.where((thread) {
            final subject = thread.subject?.toLowerCase() ?? '';
            final senderEmail = thread.lastSenderEmail?.toLowerCase() ?? '';
            final content = thread.lastContent?.toLowerCase() ?? '';

            return subject.contains(searchQuery) ||
                senderEmail.contains(searchQuery) ||
                content.contains(searchQuery);
          }).toList();

      setState(() {
        _results = filteredResults;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tìm kiếm')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Từ khóa tìm kiếm',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _search,
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (!_isLoading && _results.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, index) {
                    final thread = _results[index];
                    return MailListTile(thread: thread);
                  },
                ),
              ),
            if (!_isLoading && _results.isEmpty && _error == null)
              const Text('Không có kết quả'),
          ],
        ),
      ),
    );
  }
}
