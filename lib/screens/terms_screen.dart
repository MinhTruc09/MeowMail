import 'package:flutter/material.dart';
import '../widgets/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Điều khoản dịch vụ'),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryYellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Text(
            'Điều khoản dịch vụ mẫu...\nBạn có thể chỉnh sửa nội dung này.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
} 