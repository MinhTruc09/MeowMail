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

  ReplyMailRequest copyWith({
    int? threadId,
    String? content,
    File? file,
    String? token,
  }) {
    return ReplyMailRequest(
      threadId: threadId ?? this.threadId,
      content: content ?? this.content,
      file: file ?? this.file,
      token: token ?? this.token,
    );
  }
}