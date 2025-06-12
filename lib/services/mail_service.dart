import 'dart:convert';

import 'package:mewmail/models/mail/send_mail.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
class MailService{
  static Future<SendMailResponse> sendMail(SendMailRequest data) async {
    const url = 'http://localhost:8080/api/mail/send';
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);
    request.fields['Authorization'] = 'Bearer ${data.token}';
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
}