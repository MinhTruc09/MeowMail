import 'package:flutter/material.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/widgets/mail_list_tile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/models/mail/send_mail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List inboxThreads = [];
  String? token;
  bool isLoading = true;
  String? _error;
  bool _loadedOnce = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({bool force = false}) async {
    if (_loadedOnce && !force) return;
    setState(() { isLoading = true; _error = null; });
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    if (token == null || token!.isEmpty) {
      setState(() {
        isLoading = false;
        _error = 'Không tìm thấy token đăng nhập!';
      });
      debugPrint('Token null hoặc rỗng khi load inbox');
      return;
    }
    try {
      final data = await MailService.getInbox(token!).timeout(const Duration(seconds: 10));
      setState(() {
        inboxThreads = data;
        isLoading = false;
        _loadedOnce = true;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        _error = 'Lỗi kết nối mạng hoặc máy chủ phản hồi chậm!';
      });
      debugPrint('Lỗi khi load inbox: $e');
    }
  }

  void _onTapThread(Map thread) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MailThreadScreen(threadId: thread['threadId']),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        title: SizedBox(
          height: height * 0.05,
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Tìm kiếm...',
              fillColor: Colors.yellow[700],
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: width * 0.04),
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(force: true),
          ),
        ],
      ),
      body: isLoading
          ? SkeletonMailList(width: width, height: height)
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        onPressed: () => _loadData(force: true),
                      )
                    ],
                  ),
                )
              : inboxThreads.isEmpty
                  ? Center(
                      child: Text(
                        'Chưa có bạn bè',
                        style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w500),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => _loadData(force: true),
                      child: ListView.separated(
                        padding: EdgeInsets.symmetric(horizontal: width * 0.03, vertical: height * 0.01),
                        itemCount: inboxThreads.length,
                        separatorBuilder: (_, __) => Divider(height: height * 0.01),
                        itemBuilder: (context, index) => LayoutBuilder(
                          builder: (context, constraints) => MailListTile(
                            thread: inboxThreads[index],
                            width: constraints.maxWidth,
                            height: constraints.maxHeight,
                            onTap: () => _onTapThread(inboxThreads[index]),
                          ),
                        ),
                      ),
                    ),
      floatingActionButton: token == null ? null : FloatingActionButton(
        onPressed: () => _showSendMailDialog(context),
        child: const Icon(Icons.edit),
        tooltip: 'Gửi tin nhắn',
      ),
    );
  }

  void _showSendMailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => SendMailDialog(
        token: token!,
        onSent: () {
          Navigator.of(context).pop();
          _loadData();
        },
      ),
    );
  }
}

class MailThreadScreen extends StatelessWidget {
  final int threadId;
  const MailThreadScreen({super.key, required this.threadId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết tin nhắn')),
      body: Center(child: Text('Thread ID: $threadId')),
    );
  }
}

class SendMailDialog extends StatefulWidget {
  final String token;
  final VoidCallback onSent;
  const SendMailDialog({super.key, required this.token, required this.onSent});

  @override
  State<SendMailDialog> createState() => _SendMailDialogState();
}

class _SendMailDialogState extends State<SendMailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: const Color(0xFFFFF8E1),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit, color: Color(0xFFFFCC00), size: 28),
                  const SizedBox(width: 8),
                  Text('Gửi tin nhắn mới', style: theme.textTheme.headlineLarge?.copyWith(fontSize: 26, color: Colors.black, fontFamily: 'Borel', decoration: TextDecoration.none)),
                ],
              ),
              const SizedBox(height: 18),
              TextFormField(
                controller: _receiverController,
                style: const TextStyle(fontFamily: 'Borel', color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Email người nhận',
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Color(0xFFFFCC00)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.email, color: Color(0xFFFFCC00)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nhập email người nhận' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _subjectController,
                style: const TextStyle(fontFamily: 'Borel', color: Colors.black),
                decoration: InputDecoration(
                  labelText: 'Tiêu đề',
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Color(0xFFFFCC00)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.title, color: Color(0xFFFFCC00)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nhập tiêu đề' : null,
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _contentController,
                style: const TextStyle(fontFamily: 'Borel', color: Colors.black),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Nội dung',
                  labelStyle: theme.textTheme.bodyMedium?.copyWith(color: Color(0xFFFFCC00)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFFFCC00), width: 2),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.black, width: 2),
                  ),
                  prefixIcon: const Icon(Icons.message, color: Color(0xFFFFCC00)),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (v) => v == null || v.isEmpty ? 'Nhập nội dung' : null,
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(_error!, style: const TextStyle(color: Colors.red, fontFamily: 'Borel')),
                ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _loading ? null : () => Navigator.of(context).pop(),
                    child: Text('Hủy', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black)),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _loading ? null : _sendMail,
                    icon: _loading ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.send, color: Colors.white),
                    label: Text('Gửi', style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      textStyle: const TextStyle(fontFamily: 'Borel', fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _loading = true; _error = null; });
    try {
      await MailService.sendMail(
        SendMailRequest(
          token: widget.token,
          receiverEmail: _receiverController.text.trim(),
          subject: _subjectController.text.trim(),
          content: _contentController.text.trim(),
          file: null, // Có thể bổ sung file đính kèm sau
        ),
      );
      widget.onSent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('📬 Gửi thành công!'), backgroundColor: Colors.green),
      );
    } catch (e) {
      setState(() { _error = 'Gửi thất bại: $e'; });
    } finally {
      setState(() { _loading = false; });
    }
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
