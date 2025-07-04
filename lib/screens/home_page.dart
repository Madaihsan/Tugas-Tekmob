import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/screens/learn_page.dart'; // Import halaman belajar
import 'package:zooplay/screens/play_page.dart';   // Import halaman bermain

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<AnimalData> _animalDataFuture;
  AnimalData? _loadedAnimalData; // Tambahkan variabel untuk menyimpan data setelah dimuat

  @override
  void initState() {
    super.initState();
    _animalDataFuture = AnimalData.loadFromJsonAsset('assets/data/hewan.json').then((data) {
      _loadedAnimalData = data; // Simpan data setelah berhasil dimuat
      return data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

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
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat data: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                );
              } else if (snapshot.hasData) {
                // Pastikan data sudah tersedia sebelum navigasi
                // snapshot.data sudah pasti tidak null di sini karena ada hasData
                // _loadedAnimalData juga sudah terisi dari .then() di initState

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'ZOO PLAY',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.black,
                              offset: Offset(3.0, 3.0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 50),

                      // Tombol "Belajar"
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke LearnPage dan teruskan data hewan
                          if (_loadedAnimalData != null) { // Pastikan data sudah dimuat
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LearnPage(animalData: _loadedAnimalData!),
                              ),
                            );
                          }
                        },
                        child: Image.asset(
                          'assets/icon/icon_belajar.png',
                          width: screenSize.width * 0.6,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tombol "Bermain"
                      GestureDetector(
                        onTap: () {
                          // Navigasi ke PlayPage dan teruskan data hewan
                          if (_loadedAnimalData != null) { // Pastikan data sudah dimuat
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PlayPage(animalData: _loadedAnimalData!),
                              ),
                            );
                          }
                        },
                        child: Image.asset(
                          'assets/icon/icon_bermain.png',
                          width: screenSize.width * 0.6,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(
                  child: Text('Tidak ada data.'),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}