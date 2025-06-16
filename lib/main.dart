import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mewmail/routes/app_routes.dart';
import 'package:mewmail/widgets/theme.dart';
import 'firebase_options.dart'; // Nhớ thêm file này nếu dùng firebase CLI

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase (bắt buộc để dùng Auth hoặc Firestore)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splashscreen',
      title: 'MewMail',
      theme: AppTheme.theme,
      onGenerateRoute: onGenerateRoute,
      routes: appRoutes,
    );
  }
}
