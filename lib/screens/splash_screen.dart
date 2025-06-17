import 'package:flutter/material.dart';
import 'package:mewmail/widgets/splash_background.dart';
import 'package:mewmail/screens/home_screen.dart';

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

  bool _showLogo = true;

  @override
  void initState() {
    super.initState();

    // Xoay nhẹ
    _rotationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    // Nhấp nhô logo (zoom nhẹ)
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    // Khi loading xong
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeOutAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _exitScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeOut),
    );

    _simulateLoading();
  }

  Future<void> _simulateLoading() async {
    await Future.delayed(const Duration(seconds: 3)); // giả lập loading API
     _rotationController.stop();
     _scaleController.stop();

    setState(() {
      _showLogo = true;
    });

    await _exitController.forward();

    // Khi hoàn tất animation thì chuyển trang
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/loginscreen');
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
          const SizedBox(height: 20),
          Text(
            'MEOW MAIL',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontSize: screenWidth * 0.08,
            ),
          ),
          Text(
            'Chỉ đơn giản là mail.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontSize: screenWidth * 0.045,
            ),
          ),
        ],
      ),
    );
  }
}
