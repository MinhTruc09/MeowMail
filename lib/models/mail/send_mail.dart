import 'dart:io';

class SendMailRequest {
  final String receiverEmail;
  final String subject;
  final String content;
  final File? file;
  final String token;

  SendMailRequest({
    required this.receiverEmail,
    required this.subject,
    required this.content,
    this.file,
    required this.token,
  });

  SendMailRequest copyWith({
    String? receiverEmail,
    String? subject,
    String? content,
    File? file,
    String? token,
  }) {
    return SendMailRequest(
      receiverEmail: receiverEmail ?? this.receiverEmail,
      subject: subject ?? this.subject,
      content: content ?? this.content,
      file: file ?? this.file,
      token: token ?? this.token,
    );
  }
}

class SendMailResponse {
  final String message;

  SendMailResponse({
    required this.message,
  });

  factory SendMailResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) throw Exception('Missing message in response');
    return SendMailResponse(
      message: json['message'] as String,
    );
  }
}