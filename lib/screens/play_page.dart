import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
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
              SizedBox(height: screenSize.height * 0.05),
              _buildGameImageButton(
                context,
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

  Widget _buildGameImageButton(
    BuildContext context,
    String imagePath,
    Size screenSize,
    VoidCallback onNavigate,
  ) {
    return GestureDetector(
      onTap: () async {
        final player = AudioPlayer();
        await player.play(AssetSource('soundtrack/backsound_tombol.mp3'));
        await Future.delayed(const Duration(milliseconds: 300)); // jeda pendek agar suara sempat terdengar
        onNavigate();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: Image.asset(
            imagePath,
            width: screenSize.width * 0.7,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
