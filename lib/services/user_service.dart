import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mewmail/models/user/profile_response.dart';
import 'package:mewmail/models/mail/api_response.dart';

class UserService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  static Future<ApiResponse<ProfileResponseDto>> myProfile(String token) async {
    final uri = Uri.parse('$baseUrl/api/user/my-profile');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ApiResponse.fromJson(json, (data) => ProfileResponseDto.fromJson(data));
    } else {
      throw Exception('Failed to get profile');
    }
  }

  static Future<ApiResponse> updateProfile({
    required String token,
    required String fullName,
    required String phone,
    String? avatarPath,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/update-profile');
    final request = http.MultipartRequest('PUT', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['fullName'] = fullName;
    request.fields['phone'] = phone;
    if (avatarPath != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'avatar',
        avatarPath,
        contentType: MediaType('image', 'png'),
      ));
    }
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ApiResponse.fromJson(json, (data) => data);
    } else {
      throw Exception('Failed to update profile');
    }
  }

  static Future<ApiResponse> changePass({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/change-pass');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['Mật khẩu cũ'] = oldPassword;
    request.fields['Mật khẩu mới'] = newPassword;
    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return ApiResponse.fromJson(json, (data) => data);
    } else {
      throw Exception('Failed to change password');
    }
  }
} 