
import 'dart:convert';
import 'dart:core';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http_parser/http_parser.dart';
import 'package:http/http.dart' as http;
import 'package:mewmail/models/user/login_request.dart';
import 'package:mewmail/models/user/login_response.dart';
import 'package:mewmail/models/user/register_request.dart';
import 'package:mewmail/models/user/register_response.dart';
class AuthService{
  static Future<RegisterResponse> register(RegisterRequest data) async{
    const url = 'http://localhost:8080/api/auth/register';
    final uri = Uri.parse(url);
    final request = http.MultipartRequest('POST', uri);


    request.fields['email'] = data.email;
    request.fields['password'] = data.password;
    request.fields['fullName'] = data.fullName;
    request.fields['phone'] = data.phone;

    if(data.avatar != null){
      request.files.add(await http.MultipartFile.fromPath(
          'avatar',
          data.avatar!.path,
        contentType: MediaType('image', 'png'),
      ));
    }
    final response = await request.send();

    if(response.statusCode == 200){
      final body = await http.Response.fromStream(response);
      final json = jsonDecode(body.body);
      return RegisterResponse.fromJson(json);
    }else{
      throw Exception('Failed to register');
    }

  }
  static Future<LoginResponse> login(LoginRequest data) async{
    final url = Uri.parse('http://localhost:8080/api/auth/login');
    final response = await http.post(
    url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final loginResponse = LoginResponse.fromJson(json);
      await _saveAccount(loginResponse);
      return loginResponse;
    } else {
      throw Exception('Failed to login');
    }
  }
  static Future<void> logout() async{
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
  }

  static Future<void>_saveAccount(LoginResponse response) async{
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('accounts');
    List<Map<String,dynamic>> accounts = [];

    if (raw != null) {
      accounts = List<Map<String,dynamic>>.from(jsonDecode(raw));
    }
    accounts.removeWhere((acc) => acc['email'] == response.user.email);

    accounts.insert(0, {
      'email': response.user.email,
      'username': response.user.username,
      'token': response.token,
    });
    if(accounts.length > 3){
      accounts = accounts.sublist(0,3);
    }
    await prefs.setString('accounts', jsonEncode(accounts));
    await prefs.setString('token', response.token);
  }
  static Future<List<Map<String,dynamic>>> getRememberedAccounts() async{
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('accounts');
    if(raw == null){
     return[];
    }
    return List<Map<String,dynamic>>.from(jsonDecode(raw));
  }
}