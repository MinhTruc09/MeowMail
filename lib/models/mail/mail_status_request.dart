class MailStatusRequestDto {
  final List<int> threadId;

  MailStatusRequestDto({
    required this.threadId,
  });

  Map<String, dynamic> toJson() {
    return {
      'threadId': threadId,
    };
  }

  factory MailStatusRequestDto.fromJson(Map<String, dynamic> json) {
    return MailStatusRequestDto(
      threadId: List<int>.from(json['threadId'] ?? []),
    );
  }
}
