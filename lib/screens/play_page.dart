// lib/screens/play_page.dart
import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/screens/guess_sound_game_page.dart';
import 'package:zooplay/screens/guess_name_game_page.dart';

class PlayPage extends StatelessWidget {
  final AnimalData animalData;

  const PlayPage({super.key, required this.animalData});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ayo Bermain!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.orange,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildGameCard(
                context,
                'Tebak Suara Hewan',
                'assets/icon/icon_tebak_suara.png',
                screenSize,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuessSoundGamePage(animals: animalData.allAnimals),
                    ),
                  );
                },
              ),
              // Menggunakan SizedBox untuk spasi vertikal
              SizedBox(height: screenSize.height * 0.03), // Mengganti Container dengan SizedBox
              _buildGameCard(
                context,
                'Tebak Nama Hewan',
                'assets/icon/icon_tebak_nama.png',
                screenSize,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => GuessNameGamePage(animals: animalData.allAnimals),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context,
    String title,
    String imagePath,
    Size screenSize,
    VoidCallback onTap,
  ) {
    double cardWidth = screenSize.width * 0.8;
    double cardHeight = screenSize.height * 0.3; // Total tinggi kartu

    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        // **Perubahan di sini**: Menggunakan SizedBox dengan tinggi dan lebar tetap
        child: SizedBox( // Mengganti Container dengan SizedBox
          width: cardWidth,
          height: cardHeight,
          child: Stack(
            children: [
              // Gambar Kategori (Tebak Suara, Tebak Nama)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: cardHeight * 0.7, // Alokasi 70% tinggi kartu untuk gambar
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.contain, // **Perubahan: Menggunakan BoxFit.contain**
                  alignment: Alignment.center,
                ),
              ),
              // Area teks di bagian bawah gambar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: cardHeight * 0.3, // 30% untuk background teks
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha((0.6 * 255).round()),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Center(
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}