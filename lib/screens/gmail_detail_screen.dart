import 'package:flutter/material.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/services/avatar_service.dart';
import 'package:mewmail/models/mail/mail_detail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:mewmail/widgets/common/skeleton_loading.dart';
import 'package:mewmail/widgets/common/animated_widgets.dart';

class GmailDetailScreen extends StatefulWidget {
  final int threadId;
  const GmailDetailScreen({super.key, required this.threadId});

  @override
  State<GmailDetailScreen> createState() => _GmailDetailScreenState();
}

class _GmailDetailScreenState extends State<GmailDetailScreen> {
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
      // Sort by newest first (reverse chronological order)
      data.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      setState(() {
        mails = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
      // Nếu lỗi liên quan đến token, chuyển về màn hình đăng nhập
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

  Future<void> _reply() async {
    final content = _replyController.text.trim();
    if (content.isEmpty) return;
    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) throw Exception('Vui lòng đăng nhập lại');
      await MailService.replyMail(
        token: token,
        threadId: widget.threadId,
        content: content,
      );
      _replyController.clear();
      await _loadThread();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi gửi tin nhắn: $e')));
        // Nếu lỗi liên quan đến token, chuyển về màn hình đăng nhập
        if (e.toString().contains('Session expired') ||
            e.toString().contains('401') ||
            e.toString().contains('403')) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/login',
            (route) => false,
          );
        }
      }
    } finally {
      setState(() => _isSending = false);
    }
  }

  /// Parse HTML content to plain text
  String _parseHtmlContent(String htmlContent) {
    try {
      final document = html_parser.parse(htmlContent);
      return document.body?.text ?? htmlContent;
    } catch (e) {
      debugPrint('Error parsing HTML: $e');
      return htmlContent;
    }
  }

  /// Build avatar widget with user image or fallback to initials
  Widget _buildAvatar(String email, Color fallbackColor, String fallbackText) {
    return FutureBuilder<String?>(
      future: AvatarService.getUserAvatar(email),
      builder: (context, snapshot) {
        final avatarUrl = snapshot.data;
        return CircleAvatar(
          radius: 20,
          backgroundColor: AvatarService.getAvatarColor(email),
          backgroundImage:
              avatarUrl != null && avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
          child:
              avatarUrl == null || avatarUrl.isEmpty
                  ? Text(
                    AvatarService.getAvatarInitials(email),
                    style: const TextStyle(
                      color: AppTheme.primaryWhite,
                      fontWeight: FontWeight.w500,
                    ),
                  )
                  : null,
        );
      },
    );
  }

  String _getDisplayName(String? email, String? name) {
    if (name != null && name.isNotEmpty && name != '(không xác định)')
      return name;
    if (email == null || email.isEmpty || email == '(không xác định)')
      return 'Unknown';

    // Handle URLs (like cloudinary URLs) - extract meaningful part or return Unknown
    if (email.startsWith('http://') || email.startsWith('https://')) {
      debugPrint('⚠️ Received URL instead of email: $email');
      return 'Unknown';
    }

    // Extract name from email if it contains a name part
    if (email.contains('@')) {
      final parts = email.split('@');
      final namePart = parts[0];
      // Convert common patterns like "john.doe" to "John Doe"
      if (namePart.contains('.')) {
        return namePart
            .split('.')
            .map(
              (part) =>
                  part.isNotEmpty
                      ? part[0].toUpperCase() + part.substring(1).toLowerCase()
                      : '',
            )
            .join(' ');
      }
      // Capitalize first letter
      return namePart.isNotEmpty
          ? namePart[0].toUpperCase() + namePart.substring(1).toLowerCase()
          : 'Unknown';
    }

    // If it's not an email format, return Unknown
    debugPrint('⚠️ Invalid email format: $email');
    return 'Unknown';
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          mails.isNotEmpty
              ? (mails.first.subject.isNotEmpty
                  ? mails.first.subject
                  : 'No Subject')
              : 'Email Thread',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryWhite,
            fontFamily: 'Borel',
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.star_border),
            onPressed: () {
              // TODO: Add to starred
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Show more options
            },
          ),
        ],
      ),
      body:
          isLoading
              ? const MessageDetailSkeleton(messageCount: 5)
              : error != null
              ? FadeInAnimation(
                child: Center(
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
                        error!,
                        style: const TextStyle(
                          color: AppTheme.primaryBlack,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
              : Column(
                children: [
                  // Email thread list
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: mails.length,
                      separatorBuilder:
                          (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final mail = mails[index];
                        final isMe =
                            myEmail != null && mail.senderEmail == myEmail;
                        final senderName = _getDisplayName(
                          mail.senderEmail,
                          mail.senderName,
                        );
                        final avatarText =
                            senderName.isNotEmpty
                                ? senderName[0].toUpperCase()
                                : 'U';
                        final avatarColor =
                            isMe
                                ? AppTheme.primaryYellow
                                : AvatarService.getAvatarColor(
                                  mail.senderEmail,
                                );

                        return SlideInAnimation(
                          delay: Duration(milliseconds: index * 100),
                          begin: const Offset(0.0, 0.3),
                          child: FadeInAnimation(
                            delay: Duration(milliseconds: index * 100),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppTheme.primaryWhite,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.primaryBlack.withValues(
                                    alpha: 0.1,
                                  ),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryBlack.withValues(
                                      alpha: 0.05,
                                    ),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Email header
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[50],
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(8),
                                        topRight: Radius.circular(8),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        _buildAvatar(
                                          mail.senderEmail,
                                          avatarColor,
                                          avatarText,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      senderName,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 16,
                                                      ),
                                                    ),
                                                  ),
                                                  Text(
                                                    DateFormat(
                                                      'MMM d, yyyy HH:mm',
                                                    ).format(mail.createdAt),
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey[600],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'to ${mail.receiverName.isNotEmpty ? mail.receiverName : mail.receiverEmail}',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.more_vert,
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            // TODO: Show email options
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                  // Email content
                                  Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (mail.subject.isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              bottom: 12,
                                            ),
                                            child: Text(
                                              mail.subject,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ),
                                        Text(
                                          _parseHtmlContent(mail.content),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.5,
                                          ),
                                        ),
                                        if (mail.attachments.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          ...mail.attachments.map(
                                            (attachment) => Container(
                                              margin: const EdgeInsets.only(
                                                bottom: 4,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 8,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.grey[100],
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  const Icon(
                                                    Icons.attach_file,
                                                    size: 16,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    attachment.fileName,
                                                    style: const TextStyle(
                                                      color: Colors.blue,
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Reply section
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    ),
                    child: Column(
                      children: [
                        // Reply actions
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showReplyDialog(false),
                                  icon: const Icon(Icons.reply),
                                  label: const Text('Reply'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlack,
                                    side: const BorderSide(
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _showReplyDialog(true),
                                  icon: const Icon(Icons.reply_all),
                                  label: const Text('Reply All'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryBlack,
                                    side: const BorderSide(
                                      color: AppTheme.primaryBlack,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              OutlinedButton.icon(
                                onPressed: () {
                                  // TODO: Forward email
                                },
                                icon: const Icon(Icons.forward),
                                label: const Text('Forward'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppTheme.primaryBlack,
                                  side: const BorderSide(
                                    color: AppTheme.primaryBlack,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }

  void _showReplyDialog(bool replyAll) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: MediaQuery.of(context).size.height * 0.8,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Column(
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        replyAll ? 'Reply All' : 'Reply',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                ),
                // Compose area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // To field
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'To: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Expanded(
                                child: Text(
                                  mails.isNotEmpty
                                      ? mails.last.senderEmail
                                      : '',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Subject field
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              const Text(
                                'Subject: ',
                                style: TextStyle(fontWeight: FontWeight.w500),
                              ),
                              Expanded(
                                child: Text(
                                  mails.isNotEmpty
                                      ? 'Re: ${mails.first.subject}'
                                      : '',
                                  style: TextStyle(color: Colors.grey[700]),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Content field
                        Expanded(
                          child: TextField(
                            controller: _replyController,
                            decoration: InputDecoration(
                              hintText: 'Type your reply...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              contentPadding: const EdgeInsets.all(12),
                            ),
                            maxLines: null,
                            expands: true,
                            textAlignVertical: TextAlignVertical.top,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Send button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                                _isSending
                                    ? null
                                    : () {
                                      Navigator.pop(context);
                                      _reply();
                                    },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryYellow,
                              foregroundColor: AppTheme.primaryBlack,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            child:
                                _isSending
                                    ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(
                                          AppTheme.primaryBlack,
                                        ),
                                      ),
                                    )
                                    : const Text(
                                      'Send',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }
}
