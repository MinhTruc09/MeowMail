import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mewmail/models/ai/ai_response.dart';
import 'package:mewmail/services/auth_service.dart';

class AiService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  static Future<AiGenerateResponse> generateMail({
    required String token,
    required String prompt,
  }) async {
    try {
      debugPrint('🤖 Gửi yêu cầu AI generate: prompt=$prompt');

      final uri = Uri.parse(
        '$baseUrl/api/ai/generate-ai',
      ).replace(queryParameters: {'prompt': prompt});

      final response = await http
          .post(
            uri,
            headers: {'Authorization': 'Bearer $token', 'accept': '*/*'},
          )
          .timeout(const Duration(seconds: 30));

      debugPrint(
        '📬 Phản hồi AI generate: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] == null) {
          throw Exception('Không có dữ liệu AI response');
        }
        return AiGenerateResponse.fromJson(json['data']);
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint(
          '❌ Lỗi xác thực khi gọi AI: ${response.statusCode} - ${response.body}',
        );
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await generateMail(token: newToken, prompt: prompt);
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint(
          '❌ Lỗi AI generate: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Lỗi tạo nội dung AI: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi AI generate: $e');
      rethrow;
    }
  }

  /// Alias for generateMail method to maintain compatibility
  static Future<AiGenerateResponse> generateAiMail({
    required String token,
    required String prompt,
  }) async {
    return await generateMail(token: token, prompt: prompt);
  }
}
