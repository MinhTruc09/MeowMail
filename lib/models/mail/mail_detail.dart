class MailItem {
  final int mailId;
  final String subject;
  final String content;
  final String senderEmail;
  final String senderName;
  final String receiverEmail;
  final String receiverName;
  final DateTime createdAt;
  final List<Attachment> attachments;
  final bool isRead;
  final bool isSpam;

  MailItem({
    required this.mailId,
    required this.subject,
    required this.content,
    required this.senderEmail,
    required this.senderName,
    required this.receiverEmail,
    required this.receiverName,
    required this.createdAt,
    required this.attachments,
    required this.isRead,
    required this.isSpam,
});factory MailItem.fromJson(Map<String, dynamic> json) {
    return MailItem(
      mailId: json['mailId'],
      subject: json['subject'],
      content: json['content'],
      senderEmail: json['senderEmail'],
      senderName: json['senderName'],
      receiverEmail: json['receiverEmail'],
      receiverName: json['receiverName'],
      createdAt: DateTime.parse(json['createdAt']),
      attachments: (json['attachments'] as List?)?.map((e) => Attachment.fromJson(e)).toList() ?? [],
      isRead: json['isRead'],
      isSpam: json['isSpam'],
    );
  }
}

class Attachment {
  final String fileName;
  final String fileType;
  final int fileSize;
  final String fileUrl;

  Attachment({
    required this.fileName,
    required this.fileType,
    required this.fileSize,
    required this.fileUrl,
  });

  factory Attachment.fromJson(Map<String, dynamic> json) {
    return Attachment(
      fileName: json['fileName'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      fileUrl: json['fileUrl'],
    );
  }
}