import 'package:flutter/material.dart';

class MailListTile extends StatelessWidget {
  final Map thread;
  final VoidCallback? onTap;
  final VoidCallback? onStar;
  final double? width;
  final double? height;
  const MailListTile({super.key, required this.thread, this.onTap, this.onStar, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    final w = width ?? MediaQuery.of(context).size.width;
    final h = height ?? MediaQuery.of(context).size.height;
    final sender = thread['sender'] ?? 'E';
    final subject = thread['subject'] ?? '';
    final preview = thread['preview'] ?? '';
    final date = thread['date'] ?? '';
    final isRead = thread['read'] ?? false;
    final isStarred = thread['starred'] ?? false;
    Color avatarColor = Colors.primaries[sender.hashCode % Colors.primaries.length];
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: w * 0.03, vertical: h * 0.015),
        child: Row(
          children: [
            CircleAvatar(
              radius: w * 0.06,
              backgroundColor: avatarColor,
              child: Text(
                sender[0].toUpperCase(),
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: w * 0.045,
                ),
              ),
            ),
            SizedBox(width: w * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          sender,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: w * 0.045,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        date,
                        style: TextStyle(fontSize: w * 0.032, color: Colors.grey),
                      ),
                    ],
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    subject,
                    style: TextStyle(
                      fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                      fontSize: w * 0.04,
                      color: isRead ? Colors.black : Colors.blueAccent,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: h * 0.004),
                  Text(
                    preview,
                    style: TextStyle(fontSize: w * 0.035, color: Colors.grey),
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
                size: w * 0.07,
              ),
              onPressed: onStar,
            ),
          ],
        ),
      ),
    );
  }
}