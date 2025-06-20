import 'package:flutter/material.dart';

class RegisterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool loading;
  final String text;

  const RegisterButton({
    super.key,
    required this.onPressed,
    required this.loading,
    this.text = 'Đăng ký',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 44,
      child: ElevatedButton(
        onPressed: loading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
        child: loading
            ? const CircularProgressIndicator(color: Colors.white)
            : Text(text, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, fontFamily: 'Borel', color: Colors.white)),
      ),
    );
  }
} 