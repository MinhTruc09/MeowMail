class MarkMailRequest{
  final List<int> threadIds;
  final String token;

  MarkMailRequest({
    required this.threadIds,
    required this.token,
});
  Map<String,dynamic> toJson() => {
    'threadIds': threadIds,
  };
}