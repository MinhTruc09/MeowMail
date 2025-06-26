import 'package:flutter/material.dart';
import 'package:mewmail/widgets/theme.dart';
import 'package:mewmail/routes/app_routes.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MewMail',
      theme: AppTheme.theme,
      initialRoute: '/splash',
      routes: appRoutes,
      onGenerateRoute: onGenerateRoute,
    );
  }
}