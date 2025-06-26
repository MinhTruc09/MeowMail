import 'dart:core';

class InboxThread {
  final int threadId;
  final String title;
  final String subject;
  final String lastContent;
  final String lastSenderEmail;
  final String lastReceiverEmail;
  final List<String> groupMembers;
  final DateTime lastCreatedAt;
  final bool read;
  final bool spam;

  InboxThread({
    required this.threadId,
    required this.title,
    required this.subject,
    required this.lastContent,
    required this.lastSenderEmail,
    required this.lastReceiverEmail,
    required this.groupMembers,
    required this.lastCreatedAt,
    required this.read,
    required this.spam,
  });

  factory InboxThread.fromJson(Map<String, dynamic> json) {
    if (json['threadId'] == null) throw Exception('Missing threadId');
    if (json['title'] == null) throw Exception('Missing title');
    if (json['subject'] == null) throw Exception('Missing subject');
    if (json['lastContent'] == null) throw Exception('Missing lastContent');
    if (json['lastSenderEmail'] == null) throw Exception('Missing lastSenderEmail');
    if (json['lastReceiverEmail'] == null) throw Exception('Missing lastReceiverEmail');
    if (json['lastCreatedAt'] == null) throw Exception('Missing lastCreatedAt');
    if (json['read'] == null) throw Exception('Missing read');
    if (json['spam'] == null) throw Exception('Missing spam');

    return InboxThread(
      threadId: json['threadId'] as int,
      title: json['title'] as String,
      subject: json['subject'] as String,
      lastContent: json['lastContent'] as String,
      lastSenderEmail: json['lastSenderEmail'] as String,
      lastReceiverEmail: json['lastReceiverEmail'] as String,
      groupMembers: json['groupMembers'] != null
          ? List<String>.from(json['groupMembers'])
          : [],
      lastCreatedAt: DateTime.parse(json['lastCreatedAt'] as String),
      read: json['read'] as bool,
      spam: json['spam'] as bool,
    );
  }
}