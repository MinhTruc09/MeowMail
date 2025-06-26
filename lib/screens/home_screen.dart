import 'package:flutter/material.dart';
import 'package:mewmail/widgets/register/register_validator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/screens/chat_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';


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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập lại')),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
      return;
    }

    try {
      debugPrint('🔄 Đang load inbox với token: ${token!.substring(0, 10)}...');
      final threads = await MailService.getInbox(token!, page: _currentPage, limit: _limit)
          .timeout(const Duration(seconds: 15));
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
          _error = 'Lỗi tải dữ liệu: ${e.toString().replaceAll('Exception: ', '')}';
          _isLoadingData = false;
        });
        if (e.toString().contains('Session expired')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phiên đăng nhập hết hạn, vui lòng đăng nhập lại')),
          );
          Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
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
      builder: (context) => SendMailDialog(
        onSend: () => _loadData(force: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mewmail'),
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove('token');
              await prefs.remove('refreshToken');
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
          : RefreshIndicator(
        onRefresh: _refresh,
        child: inboxThreads.isEmpty
            ? const Center(child: Text('Hộp thư trống'))
            : ListView.builder(
          itemCount: inboxThreads.length,
          itemBuilder: (context, index) {
            final thread = inboxThreads[index];
            return MailListTile(
              thread: thread,
              myEmail: myEmail,
              isStarred: false, // TODO: truyền trạng thái star nếu có
              onTap: () {
                if (thread.threadId > 0) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatDetailScreen(threadId: thread.threadId),
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Không tìm thấy hội thoại!')),
                  );
                }
              },
            );
          },
        ),
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

class SendMailDialog extends StatefulWidget {
  final VoidCallback onSend;
  const SendMailDialog({super.key, required this.onSend});

  @override
  State<SendMailDialog> createState() => _SendMailDialogState();
}

class _SendMailDialogState extends State<SendMailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }
      await MailService.sendMail(
        token: token,
        receiver: _receiverController.text.trim(),
        subject: _subjectController.text.trim(),
        content: _contentController.text.trim(),
      );
      debugPrint('✅ Gửi mail thành công');
      if (mounted) {
        Navigator.pop(context);
        widget.onSend();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi mail: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Soạn thư'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _receiverController,
                decoration: const InputDecoration(
                  labelText: 'Email người nhận',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator: (value) => value!.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendMail,
          child: _isSending
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text('Gửi'),
        ),
      ],
    );
  }
}