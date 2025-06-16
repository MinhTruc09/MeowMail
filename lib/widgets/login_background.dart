import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  final Widget child;
  const LoginBackground({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body:  SafeArea(
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  left: screenWidth/2,
                  child: Image.asset('assets/images/middlecat.png',
            ),
          ),
        ],
        ),
      )
      ),
    );
  }
}
