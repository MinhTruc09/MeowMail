import 'dart:io';

class SendMailRequest{
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
}
class SendMailResponse{
  final String message;
  SendMailResponse({
    required this.message,
  });
  factory SendMailResponse.fromJson(Map<String,dynamic> json) {
    return SendMailResponse(
      message: json['message'] ?? 'Success',
    );
  }
}