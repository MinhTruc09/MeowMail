class RegisterResponse {
  final String message;

  RegisterResponse({
    required this.message,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json) {
    if (json['message'] == null) throw Exception('Missing message in response');
    return RegisterResponse(
      message: json['message'] as String,
    );
  }
}