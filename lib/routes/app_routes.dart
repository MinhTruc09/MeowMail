import 'package:flutter/material.dart';
import 'package:mewmail/screens/home_screen.dart';
import 'package:mewmail/screens/login_screen.dart';
import 'package:mewmail/screens/main_screen.dart';
import 'package:mewmail/screens/register_screen.dart';
import 'package:mewmail/screens/splash_screen.dart';
import 'package:mewmail/screens/chat_detail_screen.dart';
import 'package:mewmail/screens/about_screen.dart';
import 'package:mewmail/screens/policy_screen.dart';
import 'package:mewmail/screens/terms_screen.dart';
import 'package:mewmail/screens/edit_profile_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/splash': (context) => const SplashScreen(),
  '/main': (context) => const MainScreen(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  late Widget page;

  switch (settings.name) {
    case '/home':
      page = const HomeScreen();
      break;
    case '/login':
      page = const LoginScreen();
      break;
    case '/register':
      page = const RegisterScreen();
      break;
    case '/splash':
      page = const SplashScreen();
      break;
    case '/main':
      page = const MainScreen();
      break;
    case '/chat_detail':
      final threadId = settings.arguments as int;
      page = ChatDetailScreen(threadId: threadId);
      break;
    case '/about':
      page = const AboutScreen();
      break;
    case '/policy':
      page = const PolicyScreen();
      break;
    case '/terms':
      page = const TermsScreen();
      break;
    case '/edit_profile':
      page = const EditProfileScreen();
      break;
    default:
      page = const SplashScreen();
      break;
  }

  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}
