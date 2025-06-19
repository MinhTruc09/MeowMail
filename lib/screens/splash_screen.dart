import 'package:flutter/material.dart';
import 'package:mewmail/widgets/splash_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late final AnimationController _rotationController;
  late final AnimationController _scaleController;
  late final AnimationController _exitController;

  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeOutAnimation;
  late final Animation<double> _exitScaleAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
    _scaleController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut));

    _exitController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeOut));
    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _exitController, curve: Curves.easeOut));

    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 3));
    _rotationController.stop();
    _scaleController.stop();
    await _exitController.forward();

    // Kiểm tra trạng thái đăng nhập
    final isLoggedIn = false; // TODO: Thay bằng logic kiểm tra thực tế
    if (mounted) {
      if (isLoggedIn) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _scaleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SplashBackground(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_rotationController, _scaleController, _exitController]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeOutAnimation.value,
                child: Transform.scale(
                  scale: _exitScaleAnimation.value,
                  child: RotationTransition(
                    turns: _rotationController,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Image.asset(
                        'assets/images/logocat.png',
                        width: screenWidth * 0.4,
                        height: screenWidth * 0.4,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: screenHeight * 0.025),
          Text('MEOW MAIL', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: screenWidth * 0.08)),
          Text('Chỉ đơn giản là mail.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: screenWidth * 0.045)),
        ],
      ),
    );
  }
}