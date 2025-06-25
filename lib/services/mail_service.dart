import 'dart:convert';
import 'package:flutter/foundation.dart';

import 'package:mewmail/models/mail/group_mail.dart';
import 'package:mewmail/models/mail/inbox.dart';
import 'package:mewmail/models/mail/mail_detail.dart';
import 'package:mewmail/models/mail/mark_mail_action.dart';
import 'package:mewmail/models/mail/reply_mail.dart';
import 'package:mewmail/models/mail/send_mail.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:mewmail/services/auth_service.dart';

class MailService {
  static Future<SendMailResponse> sendMail(SendMailRequest data) async {
    try {
      const url = 'https://mailflow-backend-mj3r.onrender.com/api/mail/send';
      final uri = Uri.parse(url);
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer ${data.token}';
      request.fields['receiverEmail'] = data.receiverEmail;
      request.fields['subject'] = data.subject;
      request.fields['content'] = data.content;
      if (data.file != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            data.file!.path,
            contentType: MediaType('application', 'octet-stream'),
          ),
        );
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        final body = await http.Response.fromStream(response);
        final json = jsonDecode(body.body);
        return SendMailResponse.fromJson(json);
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          return await sendMail(data.copyWith(token: newToken));
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Send mail failed: ${response.statusCode}');
        throw Exception('Failed to send mail');
      }
    } catch (e) {
      debugPrint('Exception in sendMail: $e');
      rethrow;
    }
  }

  // GET inbox
  static Future<List<InboxThread>> getInbox(String token) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/inbox',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        debugPrint('Inbox data loaded: [${json['data'].length}] threads');
        return (json['data'] as List)
            .map((e) => InboxThread.fromJson(e))
            .toList();
      } else if (response.statusCode == 403) {
        // Token hết hạn, thử refresh
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          return await getInbox(newToken);
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint(
          'Error loading inbox: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to load inbox');
      }
    } catch (e) {
      debugPrint('Exception loading inbox: $e');
      rethrow;
    }
  }

  // GET thread detail
  static Future<List<MailItem>> getThreadDetail(
    String token,
    int threadId,
  ) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/inbox/thread/$threadId',
      );
      final response = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return (json['data']['mails'] as List)
            .map((e) => MailItem.fromJson(e))
            .toList();
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          return await getThreadDetail(newToken, threadId);
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint(
          'Error loading thread: ${response.statusCode} ${response.body}',
        );
        throw Exception('Failed to load thread');
      }
    } catch (e) {
      debugPrint('Exception loading thread: $e');
      rethrow;
    }
  }

  // POST reply
  static Future<void> replyMail(ReplyMailRequest data) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/reply',
      );
      final request = http.MultipartRequest('POST', uri);
      request.fields['threadId'] = data.threadId.toString();
      request.fields['content'] = data.content;
      request.headers['Authorization'] = 'Bearer ${data.token}';

      if (data.file != null) {
        request.files.add(
          await http.MultipartFile.fromPath('file', data.file!.path),
        );
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          await replyMail(data.copyWith(token: newToken));
          return;
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Reply mail failed: ${response.statusCode}');
        throw Exception('Failed to reply mail');
      }
    } catch (e) {
      debugPrint('Exception in replyMail: $e');
      rethrow;
    }
  }

  // POST mark spam/read
  static Future<void> markSpamOrRead(
    String endpoint,
    MarkMailRequest data,
  ) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/mail/$endpoint',
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${data.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data.toJson()),
      );

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          await markSpamOrRead(endpoint, data.copyWith(token: newToken));
          return;
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Mark spam/read failed: ${response.statusCode}');
        throw Exception('Failed to mark mail');
      }
    } catch (e) {
      debugPrint('Exception in markSpamOrRead: $e');
      rethrow;
    }
  }

  // POST create group
  static Future<void> createGroup(CreateGroupRequest data) async {
    try {
      final uri = Uri.parse(
      final uri = Uri.parse('https://mailflow-backend-mj3r.onrender.com/api/mail/create-group');      );
      final request = http.MultipartRequest('POST', uri);
      request.fields['subject'] = data.subject;
      for (var email in data.receiverEmails) {
        request.fields['receiverEmail'] = email;
      }
      request.headers['Authorization'] = 'Bearer ${data.token}';

      final response = await request.send();
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          await createGroup(data.copyWith(token: newToken));
          return;
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Create group failed: ${response.statusCode}');
        throw Exception('Failed to create group');
      }
    } catch (e) {
      debugPrint('Exception in createGroup: $e');
      rethrow;
    }
  }

  // POST spam mail
  static Future<void> spamMail(MarkMailRequest data) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/spam-mail',
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${data.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'threadId': data.threadIds}),
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          await spamMail(data.copyWith(token: newToken));
          return;
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Spam mail failed: ${response.statusCode}');
        throw Exception('Failed to mark spam');
      }
    } catch (e) {
      debugPrint('Exception in spamMail: $e');
      rethrow;
    }
  }

  // POST read mail
  static Future<void> readMail(MarkMailRequest data) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/read-mail',
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer ${data.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'threadId': data.threadIds}),
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          await readMail(data.copyWith(token: newToken));
          return;
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Read mail failed: ${response.statusCode}');
        throw Exception('Failed to mark read');
      }
    } catch (e) {
      debugPrint('Exception in readMail: $e');
      rethrow;
    }
  }

  // POST delete threads
  static Future<void> deleteThreads(List<int> threadIds, String token) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/mail/delete-threads',
      );
      final response = await http.post(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(threadIds),
      );
      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          await deleteThreads(threadIds, newToken);
          return;
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Delete threads failed: ${response.statusCode}');
        throw Exception('Failed to delete threads');
      }
    } catch (e) {
      debugPrint('Exception in deleteThreads: $e');
      rethrow;
    }
  }

  // POST upload file
  static Future<String> uploadFile(String filePath, String token) async {
    try {
      final uri = Uri.parse(
        'https://mailflow-backend-mj3r.onrender.com/api/file/upload',
      );
      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode == 200) {
        return response.body;
      } else if (response.statusCode == 403) {
        final newToken = await AuthService.refreshTokenIfNeeded();
        if (newToken != null) {
          return await uploadFile(filePath, newToken);
        } else {
          throw Exception(
            'Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại.',
          );
        }
      } else {
        debugPrint('Upload file failed: ${response.statusCode}');
        throw Exception('Failed to upload file');
      }
    } catch (e) {
      debugPrint('Exception in uploadFile: $e');
      rethrow;
    }
  }
}
