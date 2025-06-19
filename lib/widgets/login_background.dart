import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // ✅ Hình mèo nền đặt TRƯỚC để nằm DƯỚI
              Align(
                alignment: Alignment.bottomCenter,
                child: Image.asset(
                  'assets/images/middlecat.png',
                  width: screenWidth * 0.5,
                ),
              ),

              // ✅ Nội dung đặt SAU để nằm TRÊN
              child,
            ],
          ),
        ),
      ),
    );
  }
}
