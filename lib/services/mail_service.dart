import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/models/mail/inbox_thread.dart';
import 'package:mewmail/models/mail/mail_detail.dart';
import 'package:mewmail/services/auth_service.dart';

class MailService {
  static const String baseUrl = 'https://mailflow-backend-mj3r.onrender.com';

  static Future<List<InboxThread>> getInbox(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint(
        '📡 Gửi yêu cầu getInbox: token=${token.substring(0, 10)}..., page=$page, limit=$limit',
      );
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/mail/inbox?page=$page&limit=$limit'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
      debugPrint(
        '📬 Phản hồi getInbox: ${response.statusCode} - ${response.body.length} bytes - ${response.body}',
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        if (json['data'] == null) {
          debugPrint('⚠️ Không có dữ liệu inbox trong phản hồi');
          return [];
        }
        return (json['data'] as List)
            .map((e) => InboxThread.fromJson(e))
            .toList();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực: ${response.statusCode} - ${response.body}');
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await getInbox(newToken, page: page, limit: limit);
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint('❌ Lỗi getInbox: ${response.statusCode} - ${response.body}');
        throw Exception('Lỗi ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi getInbox: $e');
      rethrow;
    }
  }

  static Future<void> sendMail({
    required String token,
    required String receiver,
    required String subject,
    required String content,
    String? filePath,
  }) async {
    try {
      debugPrint('📤 Gửi yêu cầu sendMail: to=$receiver, subject=$subject');
      final uri = Uri.parse('$baseUrl/api/mail/send').replace(
        queryParameters: {
          'receiverEmail': receiver,
          'subject': subject,
          'content': content,
        },
      );
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['accept'] = '*/*';
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      } else {
        request.fields['file'] = '';
      }
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint(
        '📬 Phản hồi sendMail: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        debugPrint('✅ Gửi mail thành công');
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint(
          '❌ Lỗi xác thực khi gửi mail: ${response.statusCode} - ${response.body}',
        );
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await sendMail(
            token: newToken,
            receiver: receiver,
            subject: subject,
            content: content,
            filePath: filePath,
          );
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint('❌ Lỗi sendMail: ${response.statusCode} - ${response.body}');
        throw Exception('Lỗi gửi mail: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi sendMail: $e');
      rethrow;
    }
  }

  static Future<List<MailItem>> getThreadDetail(
    String token,
    int threadId,
  ) async {
    try {
      debugPrint('📡 Gửi yêu cầu lấy chi tiết threadId: $threadId');
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/mail/inbox/thread/$threadId'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          )
          .timeout(const Duration(seconds: 15));
      debugPrint(
        '📬 Phản hồi thread detail: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        final data = json['data'];
        if (data == null || data['mails'] == null) {
          debugPrint('⚠️ Không có dữ liệu chi tiết thread trong phản hồi');
          return [];
        }
        return (data['mails'] as List)
            .map((e) => MailItem.fromJson(e))
            .toList();
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint(
          '❌ Lỗi xác thực khi lấy chi tiết thread: ${response.statusCode} - ${response.body}',
        );
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await getThreadDetail(newToken, threadId);
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint(
          '❌ Lỗi lấy chi tiết thread: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Lỗi lấy chi tiết thread: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi getThreadDetail: $e');
      rethrow;
    }
  }

  static Future<void> replyMail({
    required String token,
    required int threadId,
    required String content,
    String? filePath,
  }) async {
    try {
      debugPrint('📤 Gửi replyMail: threadId=$threadId, content=$content');
      final uri = Uri.parse('$baseUrl/api/mail/reply').replace(
        queryParameters: {'threadId': threadId.toString(), 'content': content},
      );
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.headers['accept'] = '*/*';
      if (filePath != null && filePath.isNotEmpty) {
        request.files.add(await http.MultipartFile.fromPath('file', filePath));
      } else {
        request.fields['file'] = '';
      }
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);
      debugPrint(
        '📬 Phản hồi replyMail: ${response.statusCode} - ${response.body}',
      );
      if (response.statusCode == 200) {
        debugPrint('✅ Reply thành công');
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint(
          '❌ Lỗi xác thực khi reply: ${response.statusCode} - ${response.body}',
        );
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await replyMail(
            token: newToken,
            threadId: threadId,
            content: content,
            filePath: filePath,
          );
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint(
          '❌ Lỗi replyMail: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Lỗi gửi reply: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi replyMail: $e');
      rethrow;
    }
  }

  static Future<List<InboxThread>> getSpamEmails(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('📡 Spam emails không được lưu local - trả về empty list');
      // Since we don't store spam locally anymore and there's no API endpoint
      // for getting spam emails, return empty list
      return [];
    } catch (e) {
      debugPrint('❌ Lỗi getSpamEmails: $e');
      return [];
    }
  }

  static Future<List<InboxThread>> getDeletedEmails(
    String token, {
    int page = 1,
    int limit = 10,
  }) async {
    try {
      debugPrint('📡 Deleted emails không được lưu local - trả về empty list');
      // Since we don't store deleted locally anymore and there's no API endpoint
      // for getting deleted emails, return empty list
      return [];
    } catch (e) {
      debugPrint('❌ Lỗi getDeletedEmails: $e');
      return [];
    }
  }

  static Future<void> deleteThreads({
    required String token,
    required List<int> threadIds,
  }) async {
    try {
      debugPrint('🗑️ Gửi yêu cầu deleteThreads: threadIds=$threadIds');
      debugPrint('🔑 Token: ${token.substring(0, 20)}...');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/mail/delete-threads'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(threadIds), // Send as array directly
          )
          .timeout(const Duration(seconds: 15));
      debugPrint(
        '📬 Phản hồi deleteThreads: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Xóa threads thành công');
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực: ${response.statusCode} - ${response.body}');
        // Don't try to refresh token, just logout immediately
        throw Exception('Session expired, please log in again');
      } else {
        debugPrint(
          '❌ Lỗi deleteThreads: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Lỗi xóa threads: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi deleteThreads: $e');
      rethrow;
    }
  }

  static Future<int?> createGroup({
    required String token,
    required List<String> receiverEmails,
    required String subject,
  }) async {
    try {
      debugPrint(
        '👥 Gửi yêu cầu createGroup: emails=$receiverEmails, subject=$subject',
      );

      // Build query parameters according to API doc
      final uri = Uri.parse('$baseUrl/api/mail/creat-group').replace(
        queryParameters: {
          'subject': subject,
          'receiverEmail': receiverEmails, // API expects array as query param
        },
      );

      final response = await http
          .post(uri, headers: {'Authorization': 'Bearer $token'})
          .timeout(const Duration(seconds: 15));
      debugPrint(
        '📬 Phản hồi createGroup: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Tạo group thành công');

        // Parse response to get thread ID
        try {
          final json = jsonDecode(response.body);
          final threadId = json['data'] as int?;
          debugPrint('📧 Thread ID của nhóm mới: $threadId');
          return threadId;
        } catch (e) {
          debugPrint('❌ Lỗi parse response createGroup: $e');
          return null;
        }
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực: ${response.statusCode} - ${response.body}');
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await createGroup(
            token: newToken,
            receiverEmails: receiverEmails,
            subject: subject,
          );
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint(
          '❌ Lỗi createGroup: ${response.statusCode} - ${response.body}',
        );
        throw Exception('Lỗi tạo group: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi createGroup: $e');
      rethrow;
    }
  }

  static Future<void> readMail({
    required String token,
    required List<int> threadIds,
  }) async {
    try {
      debugPrint('📖 Gửi yêu cầu readMail: threadIds=$threadIds');
      final response = await http
          .patch(
            Uri.parse('$baseUrl/api/mail/read'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'threadIds': threadIds}),
          )
          .timeout(const Duration(seconds: 15));
      debugPrint(
        '📬 Phản hồi readMail: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Đánh dấu đã đọc thành công');
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực: ${response.statusCode} - ${response.body}');
        final newToken = await AuthService.refreshTokenIfNeeded(token);
        if (newToken != null) {
          return await readMail(token: newToken, threadIds: threadIds);
        } else {
          throw Exception('Session expired, please log in again');
        }
      } else {
        debugPrint('❌ Lỗi readMail: ${response.statusCode} - ${response.body}');
        throw Exception('Lỗi đánh dấu đã đọc: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi readMail: $e');
      rethrow;
    }
  }

  static Future<void> spamMail({
    required String token,
    required List<int> threadIds,
  }) async {
    try {
      debugPrint('🚫 Gửi yêu cầu spamMail: threadIds=$threadIds');
      final response = await http
          .post(
            Uri.parse('$baseUrl/api/mail/spam-mail'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'threadId': threadIds,
            }), // Use 'threadId' key as per API
          )
          .timeout(const Duration(seconds: 15));
      debugPrint(
        '📬 Phản hồi spamMail: ${response.statusCode} - ${response.body}',
      );

      if (response.statusCode == 200) {
        debugPrint('✅ Đánh dấu spam thành công');
      } else if (response.statusCode == 403 || response.statusCode == 401) {
        debugPrint('❌ Lỗi xác thực: ${response.statusCode} - ${response.body}');
        // Don't try to refresh token, just logout immediately
        throw Exception('Session expired, please log in again');
      } else {
        debugPrint('❌ Lỗi spamMail: ${response.statusCode} - ${response.body}');
        throw Exception('Lỗi đánh dấu spam: ${response.body}');
      }
    } catch (e) {
      debugPrint('❌ Lỗi spamMail: $e');
      rethrow;
    }
  }
}
