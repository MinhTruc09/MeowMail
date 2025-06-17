import 'package:flutter/material.dart';
import 'package:mewmail/screens/home_screen.dart';
import 'package:mewmail/screens/login_screen.dart';
import 'package:mewmail/screens/register_screen.dart';
import 'package:mewmail/screens/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homescreen': (context) => const HomeScreen(),
  '/loginscreen': (context) => const LoginScreen(),
  '/registerscreen': (context) => const RegisterScreen(),
  '/splashscreen': (context) => const SplashScreen(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  late Widget page;

  switch (settings.name) {
    case '/homescreen':
      page = const HomeScreen();
      break;
    case '/loginscreen':
      page = const LoginScreen();
      break;
    case '/registerscreen':
      page = const RegisterScreen();
      break;
    case '/splashscreen':
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
