import 'package:flutter/material.dart';
import 'package:mewmail/screens/home_screen.dart';
import 'package:mewmail/screens/login_screen.dart';
import 'package:mewmail/screens/main_screen.dart';
import 'package:mewmail/screens/register_screen.dart';
import 'package:mewmail/screens/splash_screen.dart';
import 'package:mewmail/screens/ai_demo_screen.dart';
import 'package:mewmail/screens/settings_screen.dart';
import 'package:mewmail/screens/history_screen.dart';
import 'package:mewmail/screens/search_screen.dart';
import 'package:mewmail/screens/edit_profile_screen.dart';
import 'package:mewmail/screens/about_screen.dart';
import 'package:mewmail/screens/policy_screen.dart';
import 'package:mewmail/screens/terms_screen.dart';
import 'package:mewmail/screens/forgot_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/splash': (context) => const SplashScreen(),
  '/main': (context) => const MainScreen(),
  '/ai-demo': (context) => const AiDemoScreen(),
  '/settings': (context) => const SettingsScreen(),
  '/history': (context) => const HistoryScreen(),
  '/search': (context) => const SearchScreen(),
  '/edit_profile': (context) => const EditProfileScreen(),
  '/about': (context) => const AboutScreen(),
  '/policy': (context) => const PolicyScreen(),
  '/terms': (context) => const TermsScreen(),
  '/forgot': (context) => const ForgotScreen(),
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
    case '/ai-demo':
      page = const AiDemoScreen();
      break;
    case '/settings':
      page = const SettingsScreen();
      break;
    case '/history':
      page = const HistoryScreen();
      break;
    case '/search':
      page = const SearchScreen();
      break;
    case '/edit_profile':
      page = const EditProfileScreen();
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
    case '/forgot':
      page = const ForgotScreen();
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
