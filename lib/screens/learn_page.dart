import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/screens/animal_gallery_page.dart';

class LearnPage extends StatelessWidget {
  final AnimalData animalData;

  const LearnPage({
    super.key,
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
            horizontal: screenSize.width * 0.05,
          ),
          children: [
            _PulsingCategoryCard(
              title: 'Darat',
              imagePath: 'assets/icon/icon_darat.png',
              animals: animalData.darat,
            ),
            const SizedBox(height: 20),
            _PulsingCategoryCard(
              title: 'Air',
              imagePath: 'assets/icon/icon_air.png',
              animals: animalData.air,
            ),
            const SizedBox(height: 20),
            _PulsingCategoryCard(
              title: 'Udara',
              imagePath: 'assets/icon/icon_udara.png',
              animals: animalData.udara,
            ),
          ],
        ),
      ),
    );
  }
}

// =====================
// Kartu dengan animasi pulse loop
// =====================
class _PulsingCategoryCard extends StatefulWidget {
  final String title;
  final String imagePath;
  final List<Animal> animals;

  const _PulsingCategoryCard({
    required this.title,
    required this.imagePath,
    required this.animals,
  });

  @override
  State<_PulsingCategoryCard> createState() => _PulsingCategoryCardState();
}

class _PulsingCategoryCardState extends State<_PulsingCategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // Animasi bolak-balik

    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.05).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigateToGallery() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AnimalGalleryPage(
          categoryTitle: widget.title,
          animals: widget.animals,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _pulseAnimation,
      child: GestureDetector(
        onTap: _navigateToGallery,
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                // Gambar
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    widget.imagePath,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                // Overlay teks
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha((0.6 * 255).round()),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.title,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          '(${widget.animals.length} hewan)',
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
      ),
    );
  }
}
