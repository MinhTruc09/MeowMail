import 'package:flutter/material.dart';

class SplashBackground extends StatelessWidget {
  final Widget child;
  const SplashBackground({super.key,required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      body: SafeArea(
          child: SizedBox.expand(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  child: Image.asset('assets/images/lefttail.png',
                    width: screenWidth*0.35,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  top: 0,
                  right: 0,
                  child: Image.asset('assets/images/righttail.png',
                    width: screenWidth*0.3,
                    fit: BoxFit.contain,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Image.asset('assets/images/bottomleftpaw.png',
                    width: screenWidth*0.55,
                    fit: BoxFit.contain,
                  ),
                ),
                Center(child: child,)
              ],
            ),

          ),
      ),

    );
  }
}
