import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart'; // Import AnimalData jika diperlukan

class PlayPage extends StatelessWidget {
  // Terima data AnimalData sebagai argumen
  final AnimalData animalData;

  const PlayPage({super.key, required this.animalData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bermain Zooplay'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Ini Halaman Bermain',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Kembali ke halaman sebelumnya (HomePage)
              },
              child: const Text('Kembali ke Home'),
            ),
          ],
        ),
      ),
    );
  }
}