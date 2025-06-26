import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';

class MailListTile extends StatelessWidget {
  final InboxThread thread;
  final String? myEmail;
  final VoidCallback? onTap;
  final bool isStarred;
  const MailListTile({super.key, required this.thread, this.myEmail, this.onTap, this.isStarred = false});

  @override
  Widget build(BuildContext context) {
    final senderName = thread.lastSenderEmail ?? 'E';
    final avatarText = senderName.isNotEmpty ? senderName[0].toUpperCase() : 'E';
    final isMe = myEmail != null && thread.lastSenderEmail == myEmail;
    final dateStr = thread.lastCreatedAt != null
        ? DateFormat('MMM d').format(thread.lastCreatedAt!)
        : '';
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: isMe ? Colors.black : Colors.deepPurple,
        child: Text(avatarText, style: TextStyle(color: isMe ? Colors.white : Colors.white, fontWeight: FontWeight.bold)),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              senderName,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            dateStr,
            style: const TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            thread.subject ?? thread.title ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            thread.lastContent ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      trailing: Icon(
        isStarred ? Icons.star : Icons.star_border,
        color: isStarred ? Colors.amber : Colors.grey,
      ),
      onTap: onTap,
    );
  }
}