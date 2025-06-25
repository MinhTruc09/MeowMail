import 'package:flutter/material.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/inbox.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<InboxThread> _threads = [];
  List<InboxThread> _filtered = [];
  bool _loading = true;
  String _query = '';
  String? _error;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadThreads();
  }

  Future<void> _loadThreads({bool force = false}) async {
    if (_loadedOnce && !force) return; // Đã load rồi, không load lại nếu không bấm refresh
    setState(() { _loading = true; _error = null; });
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      try {
        final threads = await MailService.getInbox(token)
            .timeout(const Duration(seconds: 10));
        setState(() {
          _threads = threads;
          _filtered = _query.isEmpty ? threads : threads.where((t) {
            final q = _query.toLowerCase();
            return t.title.toLowerCase().contains(q) ||
                   t.lastSenderEmail.toLowerCase().contains(q) ||
                   t.lastReceiverEmail.toLowerCase().contains(q) ||
                   t.subject.toLowerCase().contains(q);
          }).toList();
          _loading = false;
          _loadedOnce = true;
        });
      } catch (e) {
        setState(() {
          _loading = false;
          _error = 'Lỗi tải dữ liệu hoặc kết nối quá chậm!';
        });
      }
    } else {
      setState(() {
        _loading = false;
        _error = 'Không tìm thấy token đăng nhập!';
      });
    }
  }

  void _onSearch(String value) {
    setState(() {
      _query = value;
      _filtered = _threads.where((t) {
        final q = value.toLowerCase();
        return t.title.toLowerCase().contains(q) ||
               t.lastSenderEmail.toLowerCase().contains(q) ||
               t.lastReceiverEmail.toLowerCase().contains(q) ||
               t.subject.toLowerCase().contains(q);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm kiếm người đã nhắn tin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadThreads(force: true),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _loading
          ? SkeletonMailList(width: width, height: height)
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: width * 0.05, vertical: height * 0.02),
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Nhập tên, email hoặc tiêu đề...'
                        ),
                        onChanged: _onSearch,
                      ),
                    ),
                    Expanded(
                      child: _filtered.isEmpty
                          ? const Center(child: Text('Không tìm thấy kết quả'))
                          : ListView.separated(
                              itemCount: _filtered.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (context, index) {
                                final t = _filtered[index];
                                return ListTile(
                                  leading: CircleAvatar(child: Text(t.title.isNotEmpty ? t.title[0].toUpperCase() : '?')),
                                  title: Text(t.title),
                                  subtitle: Text('${t.lastSenderEmail} - ${t.subject}'),
                                  trailing: t.read ? null : const Icon(Icons.mark_email_unread, color: Colors.blueAccent),
                                  onTap: () {
                                    // TODO: mở chi tiết thread
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Thread ID: ${t.threadId}')));
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}

class SkeletonMailList extends StatelessWidget {
  final double width;
  final double height;
  const SkeletonMailList({super.key, required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
      itemCount: 8,
      separatorBuilder: (_, __) => Divider(height: height * 0.01),
      itemBuilder: (context, index) => Row(
        children: [
          Container(
            width: width * 0.12,
            height: width * 0.12,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: width * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width * 0.4,
                  height: 18,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Container(
                  width: width * 0.6,
                  height: 14,
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
                Container(
                  width: width * 0.3,
                  height: 12,
                  color: Colors.grey[200],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 