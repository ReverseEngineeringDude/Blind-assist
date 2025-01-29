import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:blind_assist/main.dart';
import 'package:lottie/lottie.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: LottieBuilder.asset(
        "assets/Animation.json",
        repeat: false, // Ensures the animation plays once
        animate: true, // Plays the animation when displayed
      ),
      nextScreen: MainPage(), // Ensure MainPage() is implemented correctly
      splashIconSize: 400, // Adjust size to fit your animation
      backgroundColor: Colors.white, // Set to a clean white background
      duration: 3000, // Adjust duration if needed (default is 2500ms)
      splashTransition: SplashTransition.fadeTransition, // Optional: Choose transition
    );
  }
}
