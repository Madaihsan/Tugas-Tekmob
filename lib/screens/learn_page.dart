import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/screens/animal_gallery_page.dart';

class LearnPage extends StatelessWidget {
  final AnimalData animalData;

  const LearnPage({
    super.key, // Menambahkan super.key untuk menghilangkan warning
    required this.animalData,
  });

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Belajar Hewan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.lightBlue,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.blueAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: ListView(
          padding: EdgeInsets.symmetric(
              vertical: screenSize.height * 0.05,
              horizontal: screenSize.width * 0.05),
          children: [
            _buildCategoryCard(
              context,
              'Darat',
              'assets/icon/icon_darat.png',
              animalData.darat,
              screenSize,
            ),
            SizedBox(height: screenSize.height * 0.03),
            _buildCategoryCard(
              context,
              'Air',
              'assets/icon/icon_air.png',
              animalData.air,
              screenSize,
            ),
            SizedBox(height: screenSize.height * 0.03),
            _buildCategoryCard(
              context,
              'Udara',
              'assets/icon/icon_udara.png',
              animalData.udara,
              screenSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String imagePath,
    List<Animal> animals,
    Size screenSize,
  ) {
    double cardWidth = screenSize.width * 0.8;
    double cardHeight = screenSize.height * 0.25;
    // double imageHeight = cardHeight * 0.7; // Variabel ini tidak digunakan, bisa dihapus
    double textBgHeight = cardHeight * 0.3;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AnimalGalleryPage(
              categoryTitle: title,
              animals: animals,
            ),
          ),
        );
      },
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        clipBehavior: Clip.antiAlias,
        child: Container(
          width: cardWidth,
          height: cardHeight,
          decoration: const BoxDecoration(
            // Tidak ada dekorasi langsung di Container ini karena akan diisi oleh Image.asset
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  alignment: Alignment.center,
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: textBgHeight,
                  decoration: BoxDecoration(
                    // Menggunakan Colors.black.withAlpha() atau Color.fromRGBO() sebagai pengganti withOpacity yang deprecated
                    color: Colors.black.withAlpha((0.6 * 255).round()), // Alpha 0-255
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '(${animals.length} hewan)',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
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