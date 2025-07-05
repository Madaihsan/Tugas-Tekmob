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
              _buildGameImageButton(
                context,
                'assets/icon/icon_tebak_suara.png', // Path to the "Tebak Suara" image
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
              SizedBox(height: screenSize.height * 0.05), // Increased spacing for visual separation
              _buildGameImageButton(
                context,
                'assets/icon/icon_tebak_nama.png', // Path to the "Tebak Nama" image
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

  Widget _buildGameImageButton(
    BuildContext context,
    String imagePath,
    Size screenSize,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // You can adjust the padding to control the size of the image relative to the screen
        // This makes the image itself act as the primary visual element
        padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add horizontal padding
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0), // Apply some corner radius to the image itself
          child: Image.asset(
            imagePath,
            width: screenSize.width * 0.7, // Adjust width as a percentage of screen width
            fit: BoxFit.contain, // Ensures the image fits within the bounds without cropping
          ),
        ),
      ),
    );
  }
}