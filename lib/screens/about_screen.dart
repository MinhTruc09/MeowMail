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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Giới thiệu', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontFamily: 'Borel')),
              const SizedBox(height: 16),
              Text('Phiên bản: 1.0.0'),
              Text('Người phát triển: Nguyễn Minh Trực'),
              Text('SĐT: 0384548931'),
              Text('Ngày sinh: 09/10/2004'),
              Text('Sinh viên năm 3, trường Đại học Giao thông Vận tải TP.HCM (UTH) - Cơ sở 3, Quận 12'),
              Text('Facebook: facebook.com/nguyen.truc.101966'),
              Text('GitHub: github.com/MinhTruc09'),
              const SizedBox(height: 24),
              Text('Ứng dụng MewMail là sản phẩm đồ án cá nhân, hỗ trợ gửi/nhận mail, quản lý hộp thư, và nhiều tính năng khác.'),
            ],
          ),
        ),
      ),
    );
  }
} 