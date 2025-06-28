class AiMailResponseDto {
  final String receiverEmail;
  final String subject;
  final String content;

  AiMailResponseDto({
    required this.receiverEmail,
    required this.subject,
    required this.content,
  });

  factory AiMailResponseDto.fromJson(Map<String, dynamic> json) {
    return AiMailResponseDto(
      receiverEmail: json['receiverEmail'] ?? '',
      subject: json['subject'] ?? '',
      content: json['content'] ?? '',
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
