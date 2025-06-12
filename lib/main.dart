import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:mewmail/screens/splash_screen.dart';
import 'package:mewmail/widgets/splash_background.dart';
import 'package:mewmail/widgets/theme.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();
  // await FirebaseMessaging.instance.requestPermission(); // xin quyen
  // FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //   print('Tin nhắn đến trong foreground: ${message.notification?.title}');
  // });
  runApp(const MyApp(
  ));
  getToken();
}
// lay token cua thiet bi
void getToken() async {
  String? token = await FirebaseMessaging.instance.getToken();
  print("FCM Token: $token");
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MewMail',
      theme: AppTheme.theme,
      home: SplashScreen(),

    );
  }
}

