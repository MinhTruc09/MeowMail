import 'package:flutter/material.dart';

class LoginFormSection extends StatefulWidget {
  const LoginFormSection({super.key});

  @override
  State<LoginFormSection> createState() => _LoginFormSectionState();
}

class _LoginFormSectionState extends State<LoginFormSection> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFCC00), // màu vàng
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // EMAIL
          Text("Email:", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _emailController,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Borel',
            ),
            decoration: const InputDecoration(
              isDense: true,
              hintText: "abc@gmail.com",
              contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.2),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // PASSWORD
          Text("Mật khẩu:", style: theme.textTheme.bodyMedium),
          const SizedBox(height: 4),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontFamily: 'Borel',
            ),
            decoration: InputDecoration(
              isDense: true,
              hintText: "************",
              contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.2),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.black, width: 1.5),
              ),
              suffixIcon: IconButton(
                icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
                color: Colors.black,
                onPressed: () {
                  setState(() {
                    _obscure = !_obscure;
                  });
                },
              ),
            ),
          ),

          // Quên mật khẩu
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {},
              child: Text(
                "Quên mật khẩu?",
                style: theme.textTheme.labelLarge?.copyWith(
                  fontSize: 14,
                  color: Colors.black,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ),

          // Đăng nhập
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 45,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // TODO: Call signIn logic
              },
              child: Text("Đăng nhập", style: theme.textTheme.bodyLarge?.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
