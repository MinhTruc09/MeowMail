import 'dart:convert';
import 'package:flutter/foundation.dart'; // Add this import
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mewmail/models/user/profile_response.dart';
import 'package:mewmail/models/mail/api_response.dart';
import 'package:mewmail/services/auth_service.dart';

class UserService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  static Future<ApiResponse<ProfileResponseDto>> myProfile(String token) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/my-profile');
      final response = await http.get(uri, headers: {
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 10));
      debugPrint('MyProfile response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] == null) throw Exception('Missing data in profile response');
        return ApiResponse.fromJson(json, (data) => ProfileResponseDto.fromJson(data));
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded(null);
        if (newToken != null) {
          return await myProfile(newToken);
        } else {
          throw Exception('Session expired, please log in again.');
        }
      } else {
        throw Exception('Failed to get profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in myProfile: $e');
      rethrow;
    }
  }

  static Future<ApiResponse> updateProfile({
    required String token,
    required String fullName,
    required String phone,
    String? avatarPath,
  }) async {
    try {
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
      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Update profile response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse.fromJson(json, (data) => data);
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded(null);
        if (newToken != null) {
          return await updateProfile(
            token: newToken,
            fullName: fullName,
            phone: phone,
            avatarPath: avatarPath,
          );
        } else {
          throw Exception('Session expired, please log in again.');
        }
      } else {
        throw Exception('Failed to update profile: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in updateProfile: $e');
      rethrow;
    }
  }

  static Future<ApiResponse> changePass({
    required String token,
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/user/change-pass');
      final request = http.MultipartRequest('PATCH', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['oldPassword'] = oldPassword;
      request.fields['newPassword'] = newPassword;
      final streamedResponse = await request.send().timeout(const Duration(seconds: 10));
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint('Change password response: ${response.statusCode} - ${response.body}');
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return ApiResponse.fromJson(json, (data) => data);
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded(null);
        if (newToken != null) {
          return await changePass(
            token: newToken,
            oldPassword: oldPassword,
            newPassword: newPassword,
          );
        } else {
          throw Exception('Session expired, please log in again.');
        }
      } else {
        throw Exception('Failed to change password: ${response.body}');
      }
    } catch (e) {
      debugPrint('Exception in changePass: $e');
      rethrow;
    }
  }
}