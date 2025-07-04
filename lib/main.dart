import 'package:flutter/material.dart';
import 'package:zooplay/screens/home_page.dart'; // Impor HomePage Anda

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zooplay', // Nama aplikasi
      theme: ThemeData(
        primarySwatch: Colors.blue, // Tema warna dasar aplikasi
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const HomePage(), // Set HomePage sebagai halaman awal
    );
  }
}