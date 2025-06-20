import 'dart:convert';

import 'package:mewmail/models/mail/group_mail.dart';
import 'package:mewmail/models/mail/inbox.dart';
import 'package:mewmail/models/mail/mail_detail.dart';
import 'package:mewmail/models/mail/mark_mail_action.dart';
import 'package:mewmail/models/mail/reply_mail.dart';
import 'package:mewmail/models/mail/send_mail.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
class MailService{
  static Future<SendMailResponse> sendMail(SendMailRequest data) async {
    const url = 'http://localhost:8080/api/mail/send';
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
    } else{
      throw Exception('Failed to send mail');
    }
  }
  // GET inbox
  static Future<List<InboxThread>> getInbox(String token) async {
    final uri = Uri.parse('http://localhost:8080/api/mail/inbox');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data'] as List)
          .map((e) => InboxThread.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load inbox');
    }
  }

// GET thread detail
  static Future<List<MailItem>> getThreadDetail(String token, int threadId) async {
    final uri = Uri.parse('http://localhost:8080/api/mail/inbox/thread/$threadId');
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer $token',
    });

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return (json['data']['mails'] as List)
          .map((e) => MailItem.fromJson(e))
          .toList();
    } else {
      throw Exception('Failed to load thread');
    }
  }

// POST reply
  static Future<void> replyMail(ReplyMailRequest data) async {
    final uri = Uri.parse('http://localhost:8080/api/mail/reply');
    final request = http.MultipartRequest('POST', uri);
    request.fields['threadId'] = data.threadId.toString();
    request.fields['content'] = data.content;
    request.headers['Authorization'] = 'Bearer ${data.token}';

    if (data.file != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'file',
        data.file!.path,
      ));
    }

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to reply mail');
    }
  }

// POST mark spam/read
  static Future<void> markSpamOrRead(
      String endpoint, MarkMailRequest data) async {
    final uri = Uri.parse('http://localhost:8080/api/mail/mail/$endpoint');
    final response = await http.post(uri,
        headers: {
          'Authorization': 'Bearer ${data.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data.toJson()));

    if (response.statusCode != 200) {
      throw Exception('Failed to mark mail');
    }
  }

// POST create group
  static Future<void> createGroup(CreateGroupRequest data) async {
    final uri = Uri.parse('http://localhost:8080/api/mail/creat-group');
    final request = http.MultipartRequest('POST', uri);
    request.fields['subject'] = data.subject;
    for (var email in data.receiverEmails) {
      request.fields['receiverEmail'] = email;
    }
    request.headers['Authorization'] = 'Bearer ${data.token}';

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('Failed to create group');
    }
  }
}