import 'user.dart';

class LoginResponse {
  final String accessToken;
  final String refreshToken;
  final String email;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    if (json['accessToken'] == null) throw Exception('Missing accessToken');
    if (json['refreshToken'] == null) throw Exception('Missing refreshToken');
    if (json['email'] == null) throw Exception('Missing email');

    return LoginResponse(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      email: json['email'] as String,
    );
  }
}