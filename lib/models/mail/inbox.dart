class InboxThread{
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
  factory InboxThread.fromJson(Map<String, dynamic> json){
    return InboxThread(
      threadId: json['threadId'],
      title: json['title'],
      subject: json['subject'],
      lastContent: json['lastContent'],
      lastSenderEmail: json['lastSenderEmail'],
      lastReceiverEmail: json['lastReceiverEmail'],
      groupMembers: List<String>.from(json['groupMembers']),
      lastCreatedAt: DateTime.parse(json['lastCreatedAt']),
      read: json['read'],
      spam: json['spam'],
    );
  }
}