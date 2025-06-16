import 'package:flutter/material.dart';
import 'package:mewmail/models/user/login_request.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/widgets/login_background.dart';

class SignInScreen extends StatefulWidget {
  // final VoidCallback showSignUpScreen;
  const SignInScreen({super.key,});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  Future<void> _signIn()async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),);
    try {
      await AuthService.login(
        LoginRequest(
            email: _emailController.text,
            password: _passwordController.text),
      );
      Navigator.of(context).pop();
    } catch (e) {
      Navigator.of(context).pop();
      _showErrorDialog(e.toString());
    }
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
    ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    // TODO: implement dispose
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return LoginBackground(
      child: Column(

      ),
      // body: SafeArea(
      //     child: Center(
      //       child: SingleChildScrollView(
      //         padding: const EdgeInsets.all(24),
      //         child: Column(
      //           children: [
      //
      //           ],
      //         ),
      //     ),
      //   ),
      // ),
    );
  }
}
