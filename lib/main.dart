import 'package:flutter/material.dart';
import 'package:zooplay/screens/splash_screen.dart'; // Ganti path jika berbeda

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ZooPlay',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: false, // Gunakan Material 2 agar konsisten jika UI kamu pakai AppBar lama
      ),
      home: const SplashScreen(), // Ganti dari HomePage ke SplashScreen
    );
  }
}
