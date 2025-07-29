import 'dart:async';
import 'package:flutter/material.dart';
import 'package:zooplay/screens/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startSplashSequence();
  }

  Future<void> _startSplashSequence() async {
    // Fade in
    await _controller.forward();

    // Tahan beberapa detik
    await Future.delayed(const Duration(seconds: 2));

    // Fade out
    await _controller.reverse();

    // Navigasi ke halaman utama
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _opacityAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/icon/bg_splash_screen.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }
}
