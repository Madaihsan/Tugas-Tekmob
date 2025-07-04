// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/models/user_profile.dart';
import 'package:zooplay/screens/learn_page.dart';
import 'package:zooplay/screens/play_page.dart';
import 'package:zooplay/screens/profile_page.dart';
import 'package:zooplay/services/user_profile_storage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Future<AnimalData> _animalDataFuture;
  AnimalData? _loadedAnimalData;
  UserProfile? _userProfile;

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

    _loadUserProfile();

    _titlePulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _titlePulse = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _titlePulseController, curve: Curves.easeInOut),
    );

    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserProfileStorage.loadProfile();
    setState(() {
      _userProfile = profile;
    });
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
      extendBodyBehindAppBar: true, // Allows content to go behind the app bar
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset(
              'assets/icon/background_home.jpg',
              fit: BoxFit.cover,
            ),
          ),
          // Gradient Overlay to make text/buttons more readable
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.4),
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.8),
                  ],
                  stops: const [0.0, 0.4, 0.7, 1.0],
                ),
              ),
            ),
          ),

          // Main content
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
                      // Judul
                      FadeInDown(
                        duration: const Duration(milliseconds: 1200),
                        child: ScaleTransition(
                          scale: _titlePulse,
                          child: Image.asset(
                            'assets/icon/judul.png',
                            width: screenSize.width * 0.75,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),

                      // Tombol Belajar
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
                                        builder: (_) =>
                                            LearnPage(animalData: _loadedAnimalData!),
                                      ),
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/icon/icon_belajar.png',
                                  width: screenSize.width * 0.6,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tombol Bermain
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
                                        builder: (_) =>
                                            PlayPage(animalData: _loadedAnimalData!),
                                      ),
                                    );
                                  }
                                },
                                child: Image.asset(
                                  'assets/icon/icon_bermain.png',
                                  width: screenSize.width * 0.6,
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
      // Bottom Navigation Bar
      bottomNavigationBar: BottomAppBar(
        color: Colors.blue.withOpacity(0.8), // Semi-transparent blue
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.home, color: Colors.white, size: 30),
              onPressed: () {
                // Already on home page
              },
            ),
            // Placeholder for potential other buttons
            const SizedBox(width: 48), // The space for the FAB
            GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfilePage()),
                );
                _loadUserProfile(); // Refresh after returning
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundImage: _userProfile?.avatarPath != null
                        ? AssetImage(_userProfile!.avatarPath)
                        : const AssetImage('assets/icon/ikon_profil1.png'),
                  ),
                  if (_userProfile?.name != null && _userProfile!.name.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _userProfile!.name,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          shadows: [Shadow(blurRadius: 2, color: Colors.black)],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action for the central button, e.g., quick play or info
        },
        backgroundColor: Colors.amber,
        child: const Icon(Icons.star, color: Colors.white, size: 30),
      ),
    );
  }
}