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
    developer.log('Attempting to play sound name: $soundNamePath', name: 'AudioDebug');
    developer.log('Attempting to play animal sound: $soundPath', name: 'AudioDebug');

    final String cleanedName = soundNamePath.replaceFirst('assets/', '');
    final String cleanedSound = soundPath.replaceFirst('assets/', '');

    await _audioPlayer.stop();

    try {
      await _audioPlayer.play(AssetSource(cleanedName));
      await _audioPlayer.onPlayerComplete.first;

      if (cleanedSound.isNotEmpty) {
        await _audioPlayer.play(AssetSource(cleanedSound));
      }
    } catch (e, stack) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memutar audio: ${e.toString().split(':')[0]}'),
          backgroundColor: Colors.red,
        ),
      );
      developer.log('Audio error', name: 'AudioError', error: e, stackTrace: stack);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Hewan ${widget.categoryTitle}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
            final animal = widget.animals[index];
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
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isTapped = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controller.reverse();
        setState(() => _isTapped = false); // Reset background
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    setState(() => _isTapped = true);
    _controller.forward(from: 0.0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: GestureDetector(
        onTap: _handleTap,
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          color: _isTapped ? Colors.orange.shade100 : Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: Container(
                    color: Colors.white,
                    child: Image.asset(
                      widget.animal.gambar,
                      fit: BoxFit.contain,
                    ),
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
