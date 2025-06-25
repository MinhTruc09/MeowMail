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

  MarkMailRequest copyWith({
    List<int>? threadIds,
    String? token,
  }) {
    return MarkMailRequest(
      threadIds: threadIds ?? this.threadIds,
      token: token ?? this.token,
    );
  }
}