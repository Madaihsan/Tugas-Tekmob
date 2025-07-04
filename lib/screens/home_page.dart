import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/screens/learn_page.dart';
import 'package:zooplay/screens/play_page.dart';
import 'package:animate_do/animate_do.dart'; // Untuk animasi FadeIn, BounceIn

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<AnimalData> _animalDataFuture;
  AnimalData? _loadedAnimalData;

  late AnimationController _titlePulseController;
  late Animation<double> _titlePulse;

  late AnimationController _floatController;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();

    _animalDataFuture = AnimalData.loadFromJsonAsset('assets/data/hewan.json').then((data) {
      _loadedAnimalData = data;
      return data;
    });

    // Judul: Membesar & mengecil
    _titlePulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _titlePulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _titlePulseController, curve: Curves.easeInOut),
    );

    // Tombol: Floating naik turun
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _titlePulseController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/icon/background_home.jpg',
              fit: BoxFit.cover,
            ),
          ),
          FutureBuilder<AnimalData>(
            future: _animalDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (snapshot.hasData) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Judul gambar dengan animasi FadeInDown + Pulse loop
                      FadeInDown(
                        duration: const Duration(milliseconds: 1200),
                        child: ScaleTransition(
                          scale: _titlePulse,
                          child: Image.asset(
                            'assets/icon/judul.png',
                            width: screenSize.width * 0.8, // Lebih besar
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Tombol BELAJAR: BounceInUp + Floating
                      BounceInUp(
                        duration: const Duration(milliseconds: 1500),
                        child: AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _floatAnim.value),
                              child: GestureDetector(
                                onTap: () {
                                  if (_loadedAnimalData != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            LearnPage(animalData: _loadedAnimalData!),
                                      ),
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/icon/icon_belajar.png',
                                  width: screenSize.width * 0.65, // Perbesar
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tombol BERMAIN: BounceInUp + Floating (arah berlawanan)
                      BounceInUp(
                        duration: const Duration(milliseconds: 1800),
                        child: AnimatedBuilder(
                          animation: _floatAnim,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, -_floatAnim.value),
                              child: GestureDetector(
                                onTap: () {
                                  if (_loadedAnimalData != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PlayPage(animalData: _loadedAnimalData!),
                                      ),
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/icon/icon_bermain.png',
                                  width: screenSize.width * 0.65,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: Text('Tidak ada data.'));
              }
            },
          ),
        ],
      ),
    );
  }
}
