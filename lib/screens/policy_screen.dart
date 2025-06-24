import 'package:flutter/material.dart';
import '../widgets/theme.dart';

class PolicyScreen extends StatelessWidget {
  const PolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chính sách'),
        backgroundColor: AppTheme.primaryBlack,
        foregroundColor: AppTheme.primaryYellow,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Text(
            'Nội dung chính sách mẫu...\nBạn có thể chỉnh sửa nội dung này.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ),
    );
  }
} 