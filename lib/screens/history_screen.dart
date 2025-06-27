import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = AppTheme.screenWidth(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử')),
      body: Center(
        child: Text(
          'Lịch sử',
          style: TextStyle(fontSize: AppTheme.responsiveWidth(context, 0.05)),
        ),
      ),
    );
  }
} 