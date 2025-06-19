import 'package:flutter/material.dart';
import 'package:mewmail/screens/home_screen.dart';
import 'package:mewmail/screens/login_screen.dart';
import 'package:mewmail/screens/register_screen.dart';
import 'package:mewmail/screens/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/home': (context) => const HomeScreen(),
  '/login': (context) => const LoginScreen(),
  '/register': (context) => const RegisterScreen(),
  '/splash': (context) => const SplashScreen(),
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

  // Nếu cần xử lý màn có arguments thì xử lý thêm tại đây:
  // case '/some_screen_with_data':
  //   final args = settings.arguments as Map<String, dynamic>? ?? {};
  //   page = SomeScreen(data: args['key']);
  //   break;

    default:
      page = const SplashScreen();
      break;
  }

  return PageRouteBuilder(
    settings: settings,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 500),
  );
}
