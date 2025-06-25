class CreateGroupRequest{
  final List<String> receiverEmails;
  final String subject;
  final String token;

  CreateGroupRequest({
    required this.receiverEmails,
    required this.subject,
    required this.token,
});

  CreateGroupRequest copyWith({
    List<String>? receiverEmails,
    String? subject,
    String? token,
  }) {
    return CreateGroupRequest(
      receiverEmails: receiverEmails ?? this.receiverEmails,
      subject: subject ?? this.subject,
      token: token ?? this.token,
    );
  }
}