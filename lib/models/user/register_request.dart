import 'dart:core';
import 'dart:io';

class RegisterRequest {
  final String email;
  final String password;
  final String fullName;
  final String phone;
  final File? avatar;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.fullName,
    required this.phone,
    this.avatar,
  });
}