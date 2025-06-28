import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/services/avatar_service.dart';

class MailListTile extends StatelessWidget {
  final InboxThread thread;
  final String? myEmail;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onSpam;
  final VoidCallback? onDelete;
  final bool isStarred;

  const MailListTile({
    super.key,
    required this.thread,
    this.myEmail,
    this.onTap,
    this.onMarkAsRead,
    this.onSpam,
    this.onDelete,
    this.isStarred = false,
  });

  String _getDisplayName(String? email) {
    if (email == null || email.isEmpty) return 'Unknown';

    // Handle special cases
    if (email == '(không xác định)' || email == 'Unknown') return 'Unknown';

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
    final receiverEmail = thread.lastReceiverEmail ?? '';
    final isMe = myEmail != null && thread.lastSenderEmail == myEmail;

    // Determine who to display: if I sent it, show receiver; if I received it, show sender
    String displayEmail = isMe ? receiverEmail : senderEmail;

    // Handle case where API returns "(không xác định)" or invalid email
    if (displayEmail.isEmpty ||
        displayEmail == '(không xác định)' ||
        !displayEmail.contains('@')) {
      // Fallback: if I sent it and receiver is invalid, show my email
      // if I received it and sender is invalid, show "Unknown"
      displayEmail = isMe ? (myEmail ?? 'Unknown') : 'Unknown';
    }

    final displayName = _getDisplayName(displayEmail);
    final avatarText =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

    final timeStr = _getTimeDisplay(thread.lastCreatedAt);
    final isUnread = thread.read == false || thread.read == null;

    // Generate avatar color based on display email
    final avatarColor =
        isMe
            ? AppTheme.primaryYellow
            : AvatarService.getAvatarColor(displayEmail);

    return Dismissible(
      key: Key('mail_${thread.threadId}'),
      background: Container(
        color: AppTheme.primaryYellow,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 20),
        child: const Icon(
          Icons.mark_email_read,
          color: AppTheme.primaryBlack,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        color: AppTheme.primaryBlack,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: AppTheme.primaryWhite, size: 24),
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          // Mark as read
          onMarkAsRead?.call();
          return false; // Don't actually dismiss
        } else if (direction == DismissDirection.endToStart) {
          // Delete
          return true; // Allow delete
        }
        return false;
      },
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          onDelete?.call();
        }
      },
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          decoration: BoxDecoration(
            color:
                isUnread
                    ? AppTheme.primaryYellow.withValues(alpha: 0.1)
                    : AppTheme.primaryWhite,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primaryBlack.withValues(alpha: 0.1),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: avatarColor,
                child: Text(
                  avatarText,
                  style: const TextStyle(
                    color: AppTheme.primaryWhite,
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    fontFamily: 'Borel',
                  ),
                ),
              ),
              const SizedBox(width: 16),
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
                            displayName,
                            style: TextStyle(
                              fontWeight:
                                  isUnread ? FontWeight.w700 : FontWeight.w600,
                              fontSize: 18,
                              color: AppTheme.primaryBlack,
                              fontFamily: 'Borel',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timeStr,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppTheme.primaryBlack.withValues(alpha: 0.6),
                            fontWeight:
                                isUnread ? FontWeight.w600 : FontWeight.w500,
                            fontFamily: 'Borel',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    // Subject
                    Text(
                      thread.subject ?? thread.title ?? 'No Subject',
                      style: TextStyle(
                        fontWeight:
                            isUnread ? FontWeight.w600 : FontWeight.w500,
                        fontSize: 16,
                        color: AppTheme.primaryBlack,
                        fontFamily: 'Borel',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 6),
                    // Preview content
                    Text(
                      thread.lastContent ?? '',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppTheme.primaryBlack.withValues(alpha: 0.7),
                        fontWeight:
                            isUnread ? FontWeight.w500 : FontWeight.normal,
                        fontFamily: 'Borel',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Star icon
              Icon(
                isStarred ? Icons.star : Icons.star_border,
                color:
                    isStarred
                        ? AppTheme.primaryYellow
                        : AppTheme.primaryBlack.withValues(alpha: 0.4),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
