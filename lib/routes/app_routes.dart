import 'package:flutter/material.dart';
import 'package:mewmail/screens/home_screen.dart';
import 'package:mewmail/screens/signin_screen.dart';
import 'package:mewmail/screens/signup_screen.dart';
import 'package:mewmail/screens/splash_screen.dart';

final Map<String, WidgetBuilder> appRoutes = {
  '/homescreen': (context) => const HomeScreen(),
  '/signinscreen': (context) => const SignInScreen(),
  '/signupscreen': (context) => const SignUpScreen(),
  '/splashscreen': (context) => const SplashScreen(),
};

Route<dynamic> onGenerateRoute(RouteSettings settings) {
  late Widget page;

  switch (settings.name) {
    case '/homescreen':
      page = const HomeScreen();
      break;
    case '/signinscreen':
      page = const SignInScreen();
      break;
    case '/signupscreen':
      page = const SignUpScreen();
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
