import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mewmail/services/mail_service.dart';
import 'package:mewmail/widgets/register/register_validator.dart';

class SendMailDialog extends StatefulWidget {
  final VoidCallback onSend;
  const SendMailDialog({super.key, required this.onSend});

  @override
  State<SendMailDialog> createState() => _SendMailDialogState();
}

class _SendMailDialogState extends State<SendMailDialog> {
  final _formKey = GlobalKey<FormState>();
  final _receiverController = TextEditingController();
  final _subjectController = TextEditingController();
  final _contentController = TextEditingController();
  bool _isSending = false;

  @override
  void dispose() {
    _receiverController.dispose();
    _subjectController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _sendMail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSending = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token == null) {
        throw Exception('Vui lòng đăng nhập lại');
      }
      await MailService.sendMail(
        token: token,
        receiver: _receiverController.text.trim(),
        subject: _subjectController.text.trim(),
        content: _contentController.text.trim(),
      );
      debugPrint('✅ Gửi mail thành công');
      if (mounted) {
        Navigator.pop(context);
        widget.onSend();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi gửi mail: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Soạn thư'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _receiverController,
                decoration: const InputDecoration(
                  labelText: 'Email người nhận',
                  hintText: 'example@email.com',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _subjectController,
                decoration: const InputDecoration(
                  labelText: 'Tiêu đề',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) => value!.isEmpty ? 'Vui lòng nhập tiêu đề' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _contentController,
                decoration: const InputDecoration(
                  labelText: 'Nội dung',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator:
                    (value) => value!.isEmpty ? 'Vui lòng nhập nội dung' : null,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _isSending ? null : _sendMail,
          child:
              _isSending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Gửi'),
        ),
      ],
    );
  }
}
