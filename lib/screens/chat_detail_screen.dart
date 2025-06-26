import 'package:flutter/material.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/models/mail/mail_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatDetailScreen extends StatefulWidget {
  final int threadId;
  const ChatDetailScreen({super.key, required this.threadId});

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen> {
  List<MailItem> mails = [];
  bool isLoading = true;
  String? error;
  final _replyController = TextEditingController();
  bool _isSending = false;
  String? myEmail;

  @override
  void initState() {
    super.initState();
    _loadUserAndThread();
  }

  Future<void> _loadUserAndThread() async {
    final prefs = await SharedPreferences.getInstance();
    myEmail = prefs.getString('email');
    await _loadThread();
  }

  Future<void> _loadThread() async {
    setState(() {
      isLoading = true;
      error = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');
      final data = await MailService.getThreadDetail(token, widget.threadId);
      data.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      setState(() {
        mails = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _reply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');
      await MailService.replyMail(token: token, threadId: widget.threadId, content: content);
      _replyController.clear();
      await _loadThread();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi gửi tin nhắn: $e')),
        );
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          bottom: 0,
          right: 0,
          child: Opacity(
            opacity: 0.08,
            child: Image.asset('assets/images/paw.png', width: 180),
          ),
        ),
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text('Chi tiết hội thoại'),
            backgroundColor: Colors.yellow[700],
            foregroundColor: Colors.black,
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : error != null
                  ? Center(child: Text(error!, style: const TextStyle(color: Colors.red)))
                  : Column(
                      children: [
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: mails.length,
                            itemBuilder: (context, index) {
                              final mail = mails[index];
                              final isMe = myEmail != null && mail.senderEmail == myEmail;
                              final avatarText = (mail.senderName.isNotEmpty
                                  ? mail.senderName[0].toUpperCase()
                                  : (mail.senderEmail.isNotEmpty ? mail.senderEmail[0].toUpperCase() : '?'));
                              return Row(
                                mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (!isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 4, bottom: 4),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.yellow[700],
                                        child: Text(avatarText, style: const TextStyle(color: Colors.black)),
                                        radius: 18,
                                      ),
                                    ),
                                  Flexible(
                                    child: Container(
                                      margin: EdgeInsets.only(
                                        top: 8,
                                        bottom: 8,
                                        left: isMe ? 40 : 0,
                                        right: isMe ? 0 : 40,
                                      ),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: isMe ? Colors.yellow[100] : Colors.white,
                                        borderRadius: BorderRadius.only(
                                          topLeft: const Radius.circular(16),
                                          topRight: const Radius.circular(16),
                                          bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
                                          bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.04),
                                            blurRadius: 4,
                                            offset: const Offset(2, 2),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            mail.senderName,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: isMe ? Colors.orange[900] : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(mail.content),
                                          if (mail.attachments.isNotEmpty)
                                            ...mail.attachments.map((a) => Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: InkWell(
                                                onTap: () {
                                                  // TODO: mở file
                                                },
                                                child: Text('📎 ${a.fileName}', style: const TextStyle(color: Colors.blue)),
                                              ),
                                            )),
                                          const SizedBox(height: 4),
                                          Text(
                                            mail.createdAt.toString(),
                                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isMe)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8, left: 4, bottom: 4),
                                      child: CircleAvatar(
                                        backgroundColor: Colors.black,
                                        child: Text(avatarText, style: const TextStyle(color: Colors.white)),
                                        radius: 18,
                                      ),
                                    ),
                                ],
                              );
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _replyController,
                                  decoration: const InputDecoration(
                                    hintText: 'Nhập tin nhắn...',
                                    border: OutlineInputBorder(),
                                  ),
                                  minLines: 1,
                                  maxLines: 3,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: _isSending ? null : _reply,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.yellow[700],
                                  foregroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: _isSending
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                                    : const Icon(Icons.send),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
        ),
      ],
    );
  }
} 