import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/services/firebase_service.dart';
import 'package:mewmail/services/auth_service.dart';
import 'package:mewmail/models/user/register_request.dart';

class RegisterFormSection extends StatefulWidget {
  const RegisterFormSection({super.key});

  @override
  State<RegisterFormSection> createState() => _RegisterFormSectionState();
}

class _RegisterFormSectionState extends State<RegisterFormSection> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _rePasswordController = TextEditingController();
  bool _obscure = true;
  bool _obscureRe = true;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Container(
      width: screenWidth * 0.88,
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05, vertical: screenHeight * 0.025),
      decoration: BoxDecoration(
        color: AppTheme.primaryYellow,
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
          Text("Họ và tên:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Borel')),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.black, fontFamily: 'Borel'),
            cursorColor: Colors.black,
            decoration: InputDecoration(
              hintText: "Nguyễn Văn A",
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
          const SizedBox(height: 12),
          Text("Nhập lại mật khẩu:", style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.black, fontFamily: 'Borel')),
          const SizedBox(height: 8),
          TextField(
            controller: _rePasswordController,
            obscureText: _obscureRe,
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
                icon: Icon(_obscureRe ? Icons.visibility_off : Icons.visibility, color: Colors.black54),
                onPressed: () => setState(() => _obscureRe = !_obscureRe),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _loading ? null : _submitRegister,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Đăng ký", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Borel', color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitRegister() async {
    final email = _emailController.text.trim();
    final name = _nameController.text.trim();
    final password = _passwordController.text.trim();
    final rePassword = _rePasswordController.text.trim();

    if (email.isEmpty || name.isEmpty || password.isEmpty || rePassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập đầy đủ thông tin!')),
      );
      return;
    }
    if (password != rePassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu không khớp!')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      await FirebaseAuthService.registerWithEmail(email: email, password: password, name: name);
      await AuthService.register(RegisterRequest(
        email: email,
        password: password,
        fullName: name,
        phone: '',
        avatar: null,
      ));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đăng ký thành công!')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Đăng ký thất bại: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }
} 