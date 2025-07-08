import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/models/user/login_request.dart';
import 'package:mewmail/models/user/register_request.dart';
import 'package:http_parser/http_parser.dart';

class AuthService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  static Future<String> login(LoginRequest request) async {
    try {
      debugPrint('📡 Gửi yêu cầu đăng nhập: ${request.email}');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/login'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(request.toJson()),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint(
        '📬 Phản hồi đăng nhập: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final token = json['data']['accessToken'];
        final refreshToken = json['data']['refreshToken'];
        final email = json['data']['email'];
        if (token == null || refreshToken == null || email == null) {
          throw Exception(
            'Thiếu token, refreshToken hoặc email trong phản hồi',
          );
        }
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token);
        await prefs.setString('refreshToken', refreshToken);
        await prefs.setString('email', email);
        debugPrint('✅ Lưu token, refreshToken và email thành công');
        return email;
      } else {
        throw Exception('Đăng nhập thất bại: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi đăng nhập: $e');
      rethrow;
    }
  }

  static Future<String?> refreshTokenIfNeeded(String? oldToken) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final refreshToken = prefs.getString('refreshToken');
      final email = prefs.getString('email');
      if (refreshToken == null || email == null) {
        debugPrint('❌ Không tìm thấy refreshToken hoặc email');
        return null;
      }
      debugPrint('🔄 Gửi yêu cầu refresh token');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/auth/Refresh-token'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'email': email, 'password': refreshToken}),
          )
          .timeout(const Duration(seconds: 10));
      debugPrint(
        '📬 Phản hồi refresh token: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final newToken = json['data']['accessToken'];
        final newRefreshToken = json['data']['refreshToken'];
        if (newToken == null) {
          throw Exception('Token mới không có trong phản hồi');
        }
        await prefs.setString('token', newToken);
        if (newRefreshToken != null) {
          await prefs.setString('refreshToken', newRefreshToken);
        }
        debugPrint('✅ Refresh token thành công');
        return newToken;
      } else {
        // If refresh token fails, clear all auth data
        debugPrint('❌ Refresh token thất bại, xóa dữ liệu đăng nhập');
        await logout();
        throw Exception('Refresh token thất bại: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi refresh token: $e');
      // Clear auth data on any refresh token error
      await logout();
      return null;
    }
  }

  static Future<void> register(RegisterRequest request) async {
    try {
      debugPrint('📡 Gửi yêu cầu đăng ký: ${request.email}');
      final requestBody = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/api/auth/register'),
      );
      requestBody.fields['email'] = request.email;
      requestBody.fields['password'] = request.password;
      requestBody.fields['fullName'] = request.fullName;
      requestBody.fields['phone'] = request.phone;
      if (request.avatar != null) {
        requestBody.files.add(
          await http.MultipartFile.fromPath(
            'avatar',
            request.avatar!.path,
            contentType: MediaType('image', 'png'),
          ),
        );
      }
      final response = await requestBody.send().timeout(
        const Duration(seconds: 10),
      );
      final responseBody = await http.Response.fromStream(response);
      debugPrint(
        '📬 Phản hồi đăng ký: ${response.statusCode} - ${responseBody.body}',
      );

      if (response.statusCode == 200) {
        // Đăng ký thành công, không cần lấy token ở đây
        debugPrint('✅ Đăng ký thành công');
        return;
      } else {
        // Parse error response
        String errorMessage = 'Lỗi server (${response.statusCode})';

        try {
          final json = jsonDecode(responseBody.body);
          if (json['message'] != null) {
            errorMessage = json['message'];
          }
        } catch (e) {
          // If JSON parsing fails, use raw body
          if (responseBody.body.isNotEmpty) {
            errorMessage = responseBody.body;
          }
        }

        // Handle specific error cases
        if (response.statusCode == 403 ||
            response.statusCode == 409 ||
            errorMessage.toLowerCase().contains('email') &&
                (errorMessage.toLowerCase().contains('exist') ||
                    errorMessage.toLowerCase().contains('đã') ||
                    errorMessage.toLowerCase().contains('tồn tại'))) {
          throw Exception(
            'Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.',
          );
        } else if (response.statusCode == 400) {
          throw Exception('Thông tin đăng ký không hợp lệ: $errorMessage');
        } else {
          throw Exception('Đăng ký thất bại: $errorMessage');
        }
      }
    } catch (e) {
      debugPrint('❌ Lỗi đăng ký: $e');
      rethrow;
    }
  }

  /// Check if the error indicates that the user should be redirected to login
  static bool shouldRedirectToLogin(String errorMessage) {
    return errorMessage.contains('Session expired') ||
        errorMessage.contains('401') ||
        errorMessage.contains('403') ||
        errorMessage.contains('please log in again') ||
        errorMessage.contains('Unauthorized');
  }

  /// Clear all stored authentication data
  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('refreshToken');
      await prefs.remove('email');
      await prefs.remove('user_id');
      debugPrint('✅ Đã xóa tất cả dữ liệu đăng nhập');
    } catch (e) {
      debugPrint('❌ Lỗi logout: $e');
    }
  }
}
