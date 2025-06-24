import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class ForgotScreen extends StatefulWidget {
  const ForgotScreen({super.key});
  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  int step = 1;
  final emailController = TextEditingController();
  final captchaController = TextEditingController();
  final oldPassController = TextEditingController();
  final newPassController = TextEditingController();
  String captcha = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateCaptcha();
  }

  void _generateCaptcha() {
    // Giả lập captcha
    captcha = 'qG9phJD7';
    setState(() {});
  }

  void _onContinue() async {
    if (emailController.text.isEmpty || captchaController.text != captcha) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email hoặc Captcha không đúng!')));
      return;
    }
    setState(() { step = 2; });
  }

  void _onChangePassword() async {
    if (oldPassController.text.isEmpty || newPassController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng nhập đủ thông tin!')));
      return;
    }
    setState(() { isLoading = true; });
    await Future.delayed(const Duration(seconds: 1)); // Giả lập gọi API
    setState(() { isLoading = false; });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đổi mật khẩu thành công!')));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Text('Quên mật khẩu', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontFamily: 'Borel')),
              const SizedBox(height: 8),
              Text('Xác nhận lại thông tin', style: TextStyle(color: AppTheme.primaryYellow, fontFamily: 'Borel', fontSize: 18)),
              const SizedBox(height: 16),
              Image.asset('assets/images/questionmark.png', width: width * 0.3),
              const SizedBox(height: 8),
              if (step == 1) ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Email:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: 'abc@gmail.com'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text('Nhận Captcha:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: captchaController,
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none, hintText: 'Nhập mã captcha'),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(captcha, style: const TextStyle(fontFamily: 'Borel', fontSize: 22)),
                          const SizedBox(width: 8),
                          IconButton(onPressed: _generateCaptcha, icon: const Icon(Icons.refresh, size: 20)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: width * 0.7,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _onContinue,
                    child: const Text('Tiếp tục', style: TextStyle(fontFamily: 'Borel', color: Colors.white, fontSize: 18)),
                  ),
                ),
              ] else ...[
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryYellow,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Nhận mật khẩu cũ:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: oldPassController,
                        obscureText: true,
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      const Text('Nhận mật khẩu mới:', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextField(
                        controller: newPassController,
                        obscureText: true,
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: width * 0.7,
                  height: 44,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: isLoading ? null : _onChangePassword,
                    child: isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Đổi mật khẩu', style: TextStyle(fontFamily: 'Borel', color: Colors.white, fontSize: 18)),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              Image.asset('assets/images/middlecat.png', width: width * 0.4),
            ],
          ),
        ),
      ),
    );
  }
}
