class RegisterResponse{
  final String message;
  final String? token;
  final Map<String, dynamic> user;

  RegisterResponse({
    required this.message,
    required this.token,
    required this.user,
  });

  factory RegisterResponse.fromJson(Map<String, dynamic> json){
    return RegisterResponse(
      message: json['message'],
      token: json['token'],
      user: json['user'],
    );
  }
}