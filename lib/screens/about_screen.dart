import 'package:flutter/material.dart';
import '../widgets/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tìm hiểu về chúng tôi'),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryYellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Text(
            'Thông tin về chúng tôi...\nBạn có thể chỉnh sửa nội dung này.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
} 