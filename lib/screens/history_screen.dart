import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử')),
      body: Center(
        child: Text(
          'Lịch sử',
          style: TextStyle(fontSize: width * 0.05),
        ),
      ),
    );
  }
} 