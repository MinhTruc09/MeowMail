import 'dart:io';

class ReplyMailRequest{
  final int threadId;
  final String content;
  final File? file;
  final String token;

  ReplyMailRequest({
    required this.threadId,
    required this.content,
    this.file,
    required this.token,
});
}