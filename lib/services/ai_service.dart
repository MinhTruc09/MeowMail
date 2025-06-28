import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:mewmail/models/ai/ai_mail_response.dart';
import 'package:mewmail/models/mail/api_response.dart';
import 'package:mewmail/services/auth_service.dart';

class AiService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  /// Chat với AI hoặc trợ lý soạn mail
  /// Muốn soạn mail thêm từ khóa: "hãy giúp tôi soạn mail..."
  static Future<ApiResponse<AiMailResponseDto>> generateAiMail({
    required String token,
    required String prompt,
  }) async {
    try {
      debugPrint('🤖 Gửi yêu cầu AI: prompt=$prompt');
      
      final uri = Uri.parse('$baseUrl/api/ai/generate-ai').replace(
        queryParameters: {
          'prompt': prompt,
        },
      );

      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30)); // AI có thể mất thời gian

      debugPrint('🤖 Phản hồi AI: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] == null) {
          throw Exception('Missing data in AI response');
        }
        return ApiResponse.fromJson(
          json, 
          (data) => AiMailResponseDto.fromJson(data),
        );
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực AI: ${response.statusCode} - ${response.body}');
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await generateAiMail(
            token: newToken,
            prompt: prompt,
          );
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint('❌ Lỗi AI: ${response.statusCode} - ${response.body}');
        throw Exception('AI service error: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi generateAiMail: $e');
      rethrow;
    }
  }

  /// Helper method để kiểm tra xem prompt có phải là yêu cầu soạn mail không
  static bool isMailCompositionRequest(String prompt) {
    final lowerPrompt = prompt.toLowerCase();
    return lowerPrompt.contains('soạn mail') ||
           lowerPrompt.contains('viết mail') ||
           lowerPrompt.contains('tạo mail') ||
           lowerPrompt.contains('compose mail') ||
           lowerPrompt.contains('write email') ||
           lowerPrompt.contains('create email');
  }

  /// Helper method để tạo prompt cho AI soạn mail
  static String createMailCompositionPrompt({
    required String purpose,
    String? recipient,
    String? context,
  }) {
    String prompt = 'Hãy giúp tôi soạn mail $purpose';
    
    if (recipient != null && recipient.isNotEmpty) {
      prompt += ' gửi cho $recipient';
    }
    
    if (context != null && context.isNotEmpty) {
      prompt += '. Bối cảnh: $context';
    }
    
    return prompt;
  }
}
