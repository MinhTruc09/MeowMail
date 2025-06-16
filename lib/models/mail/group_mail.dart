class CreateGroupRequest{
  final List<String> receiverEmails;
  final String subject;
  final String token;

  CreateGroupRequest({
    required this.receiverEmails,
    required this.subject,
    required this.token,
});
}