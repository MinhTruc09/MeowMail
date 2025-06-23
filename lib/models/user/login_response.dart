import 'user.dart';
class LoginResponse{
  final String accessToken;
  final String refreshToken;
  final String email;

  LoginResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.email,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json){
    return LoginResponse(
      accessToken: json['accessToken'] ?? '',
      refreshToken: json['refreshToken'] ?? '',
      email: json['email'] ?? '',
    );
  }
}