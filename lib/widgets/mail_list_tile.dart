import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/widgets/theme.dart';

class MailListTile extends StatelessWidget {
  final InboxThread thread;
  final String? myEmail;
  final VoidCallback? onTap;
  final bool isStarred;
  const MailListTile({
    super.key,
    required this.thread,
    this.myEmail,
    this.onTap,
    this.isStarred = false,
  });

  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'Unknown';

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

    return email;
  }

  String _getTimeDisplay(DateTime? dateTime) {
    if (dateTime == null) return '';

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays == 0) {
      // Today - show time
      return DateFormat('HH:mm').format(dateTime);
    } else if (difference.inDays < 7) {
      // This week - show day
      return DateFormat('E').format(dateTime); // Mon, Tue, etc.
    } else if (dateTime.year == now.year) {
      // This year - show month and day
      return DateFormat('MMM d').format(dateTime);
    } else {
      // Other years - show full date
      return DateFormat('dd/MM/yy').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    final senderEmail = thread.lastSenderEmail ?? '';
    final senderName = _getDisplayName(senderEmail);
    final avatarText =
        senderName.isNotEmpty ? senderName[0].toUpperCase() : 'U';
    final isMe = myEmail != null && thread.lastSenderEmail == myEmail;
    final timeStr = _getTimeDisplay(thread.lastCreatedAt);
    final isUnread = thread.read == false || thread.read == null;

    // Generate avatar color based on sender email
    final avatarColor =
        isMe
            ? AppTheme.primaryBlack
            : Colors.primaries[senderEmail.hashCode % Colors.primaries.length];

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color:
              isUnread
                  ? AppTheme.primaryYellow.withOpacity(0.1)
                  : AppTheme.primaryWhite,
          border: Border(
            bottom: BorderSide(color: Colors.grey[200]!, width: 0.5),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            CircleAvatar(
              radius: 20,
              backgroundColor: avatarColor,
              child: Text(
                avatarText,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name and time
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          senderName,
                          style: TextStyle(
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w500,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        timeStr,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight:
                              isUnread ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Subject
                  Text(
                    thread.subject ?? thread.title ?? 'No Subject',
                    style: TextStyle(
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 14,
                      color: Colors.black87,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  // Preview content
                  Text(
                    thread.lastContent ?? '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                      fontWeight:
                          isUnread ? FontWeight.w500 : FontWeight.normal,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Star icon
            Icon(
              isStarred ? Icons.star : Icons.star_border,
              color: isStarred ? Colors.amber[600] : Colors.grey[400],
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
