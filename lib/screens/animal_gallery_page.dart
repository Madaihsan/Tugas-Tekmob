import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:zooplay/models/animal.dart';
import 'dart:developer' as developer;

class AnimalGalleryPage extends StatefulWidget {
  final String categoryTitle;
  final List<Animal> animals;

  const AnimalGalleryPage({
    super.key,
    required this.categoryTitle,
    required this.animals,
  });

  @override
  State<AnimalGalleryPage> createState() => _AnimalGalleryPageState();
}

class _AnimalGalleryPageState extends State<AnimalGalleryPage> {
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playAnimalSound(String soundPath, String soundNamePath) async {
    developer.log('Attempting to play sound name (original): $soundNamePath', name: 'AudioDebug');
    developer.log('Attempting to play animal sound (original): $soundPath', name: 'AudioDebug');

    // **Perubahan di sini:** Hapus prefiks 'assets/' dari path
    final String cleanedSoundNamePath = soundNamePath.replaceFirst('assets/', '');
    final String cleanedSoundPath = soundPath.replaceFirst('assets/', '');

    developer.log('Attempting to play sound name (cleaned): $cleanedSoundNamePath', name: 'AudioDebug');
    developer.log('Attempting to play animal sound (cleaned): $cleanedSoundPath', name: 'AudioDebug');


    await _audioPlayer.stop();

    try {
      // Putar suara nama hewan terlebih dahulu
      await _audioPlayer.play(AssetSource(cleanedSoundNamePath));
      developer.log('Played sound name: $cleanedSoundNamePath', name: 'AudioDebug');

      // Tunggu hingga suara nama hewan selesai diputar
      await _audioPlayer.onPlayerComplete.first;

      // Jika ada suara hewan (tidak kosong), putar suara hewan
      if (cleanedSoundPath.isNotEmpty) {
        await _audioPlayer.play(AssetSource(cleanedSoundPath));
        developer.log('Played animal sound: $cleanedSoundPath', name: 'AudioDebug');
      } else {
        developer.log('Animal sound path is empty, skipping.', name: 'AudioDebug');
      }
    } catch (e, stackTrace) {
      if (!mounted) {
        developer.log('Widget is not mounted, cannot show SnackBar.', name: 'AudioError');
        return;
      }

      developer.log('Error playing audio: $e', name: 'AudioError', error: e, stackTrace: stackTrace);
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memutar audio: ${e.toString().split(':')[0]}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hewan ${widget.categoryTitle}',
          style: const TextStyle(
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
        child: GridView.builder(
          padding: const EdgeInsets.all(15),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 0.8,
          ),
          itemCount: widget.animals.length,
          itemBuilder: (context, index) {
            final Animal animal = widget.animals[index];
            return _AnimatedAnimalCard(
              key: ValueKey(animal.nama),
              animal: animal,
              onTap: () => _playAnimalSound(animal.suara, animal.suaraNama),
            );
          },
        ),
      ),
    );
  }
}

// Widget terpisah untuk Kartu Hewan dengan Animasi Sendiri
class _AnimatedAnimalCard extends StatefulWidget {
  final Animal animal;
  final VoidCallback onTap;

  const _AnimatedAnimalCard({
    super.key,
    required this.animal,
    required this.onTap,
  });

  @override
  State<_AnimatedAnimalCard> createState() => _AnimatedAnimalCardState();
}

class _AnimatedAnimalCardState extends State<_AnimatedAnimalCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reverse();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap();
        _animationController.forward(from: 0.0);
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Image.asset(
                    widget.animal.gambar,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  widget.animal.nama,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
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