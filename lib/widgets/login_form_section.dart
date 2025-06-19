import 'package:flutter/material.dart';
import 'package:mewmail/models/user/login_request.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/services/firebase_service.dart'; // thêm dòng này

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  Future<void> _submitLogin() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      // 1. Đăng nhập Firebase Auth
      await FirebaseAuthService.signInWithEmail(email: email, password: password);
      // 2. Đăng nhập backend API
      final apiResponse = await AuthService.login(LoginRequest(
        email: email,
        password: password,
      ));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Chào ${apiResponse.user.username}!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng nhập thất bại: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.05,
            vertical: screenHeight * 0.025,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFCC00),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Email:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Borel')),
              const SizedBox(height: 8),
              TextField(
                controller: _emailController,
                style: const TextStyle(color: Colors.black, fontFamily: 'Borel'),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "abc@gmail.com",
                  hintStyle: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, fontFamily: 'Borel'),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text("Mật khẩu:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Borel')),
              const SizedBox(height: 8),
              TextField(
                controller: _passwordController,
                obscureText: _obscure,
                style: const TextStyle(color: Colors.black, fontFamily: 'Borel'),
                cursorColor: Colors.black,
                decoration: InputDecoration(
                  hintText: "************",
                  hintStyle: const TextStyle(color: Colors.black54, fontStyle: FontStyle.italic, fontFamily: 'Borel'),
                  filled: true,
                  fillColor: Colors.transparent,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black12, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Quên mật khẩu?",
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.none,
                      fontSize: screenWidth * 0.035,
                      fontFamily: 'Borel',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: _loading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ĐĂNG NHẬP", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Borel')),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Chưa có tài khoản? ", style: theme.textTheme.bodyMedium?.copyWith(fontSize: screenWidth * 0.045, fontFamily: 'Borel')),
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: Text(
                "Đăng ký",
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: const Color(0xFFFFCC00),
                  fontWeight: FontWeight.bold,
                  fontSize: screenWidth * 0.045,
                  decoration: TextDecoration.none,
                  fontFamily: 'Borel',
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // Nút Google
        GestureDetector(
          onTap: () async {
            try {
              final userCred = await FirebaseAuthService.signInWithGoogle();
              final email = userCred.user?.email ?? '';
              final tokenPassword = 'google_auth';
              await AuthService.login(LoginRequest(email: email, password: tokenPassword));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Chào mừng $email')),
              );
              Navigator.pushReplacementNamed(context, '/home');
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Google login thất bại: $e')),
              );
            }
          },
          child: Container(
            margin: const EdgeInsets.only(top: 4),
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.05,
              vertical: screenHeight * 0.015,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/google.png', height: screenHeight * 0.025),
                SizedBox(width: screenWidth * 0.03),
                Text(
                  'ĐĂNG NHẬP BẰNG GOOGLE',
                  style: TextStyle(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[900],
                    letterSpacing: 0.5,
                    fontFamily: 'Borel',
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
