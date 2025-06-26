import 'package:flutter/foundation.dart';

class InboxThread {
  final int threadId;
  final String? title;
  final String? subject;
  final String? lastContent;
  final String? lastSenderEmail;
  final String? lastReceiverEmail;
  final DateTime? lastCreatedAt;
  final bool? read;
  final bool? spam;

  InboxThread({
    required this.threadId,
    this.title,
    this.subject,
    this.lastContent,
    this.lastSenderEmail,
    this.lastReceiverEmail,
    this.lastCreatedAt,
    this.read,
    this.spam,
  });

  factory InboxThread.fromJson(Map<String, dynamic> json) {
    return InboxThread(
      threadId: json['threadId'] as int,
      title: json['title'] as String?,
      subject: json['subject'] as String?,
      lastContent: json['lastContent'] as String?,
      lastSenderEmail: json['lastSenderEmail'] as String?,
      lastReceiverEmail: json['lastReceiverEmail'] as String?,
      lastCreatedAt: json['lastCreatedAt'] != null ? DateTime.tryParse(json['lastCreatedAt']) : null,
      read: json['read'] as bool?,
      spam: json['spam'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
      'title': title,
      'subject': subject,
      'lastContent': lastContent,
      'lastSenderEmail': lastSenderEmail,
      'lastReceiverEmail': lastReceiverEmail,
      'lastCreatedAt': lastCreatedAt?.toIso8601String(),
      'read': read,
      'spam': spam,
    };
  }
}