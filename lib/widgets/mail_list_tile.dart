import 'package:flutter/material.dart';

class MailListTile extends StatelessWidget {
  final Map thread;
  final VoidCallback? onTap;
  final VoidCallback? onStar;
  const MailListTile({super.key, required this.thread, this.onTap, this.onStar});

  @override
  Widget build(BuildContext context) {
    final sender = thread['sender'] ?? 'E';
    final subject = thread['subject'] ?? '';
    final preview = thread['preview'] ?? '';
    final date = thread['date'] ?? '';
    final isStarred = thread['starred'] ?? false;
    Color avatarColor = Colors.primaries[sender.hashCode % Colors.primaries.length];
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: avatarColor,
              child: Text(sender[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        date,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subject,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    preview,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(
                isStarred ? Icons.star : Icons.star_border,
                color: isStarred ? Colors.amber : Colors.grey,
              ),
              onPressed: onStar,
            ),
          ],
        ),
      ),
    );
  }
}