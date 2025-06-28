class AiGenerateResponse {
  final String receiverEmail;
  final String subject;
  final String content;

  AiGenerateResponse({
    required this.receiverEmail,
    required this.subject,
    required this.content,
  });

  factory AiGenerateResponse.fromJson(Map<String, dynamic> json) {
    if (json['receiverEmail'] == null) throw Exception('Missing receiverEmail');
    if (json['subject'] == null) throw Exception('Missing subject');
    if (json['content'] == null) throw Exception('Missing content');

    return AiGenerateResponse(
      receiverEmail: json['receiverEmail'] as String,
      subject: json['subject'] as String,
      content: json['content'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'receiverEmail': receiverEmail,
      'subject': subject,
      'content': content,
    };
  }
}
