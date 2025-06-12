import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MewMail')),
      body: const Center(
        child: Text('Xin chào Minh!', style: TextStyle(fontSize: 20)),
      ),
    );
  }
}
