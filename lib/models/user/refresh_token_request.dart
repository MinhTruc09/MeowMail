class RefreshTokenRequest {
  final String email;
  final String password; // Refresh token trong trường hợp này

  RefreshTokenRequest({
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  factory RefreshTokenRequest.fromJson(Map<String, dynamic> json) {
    return RefreshTokenRequest(
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }
}
