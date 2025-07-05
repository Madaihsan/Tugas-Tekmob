// HomePage.dart
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:audioplayers/audioplayers.dart';
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
  late final AudioPlayer _bgPlayer;
  late final AudioPlayer _sfxPlayer;
  bool _isBgsPlaying = false;

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

    _bgPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    _bgPlayer.setReleaseMode(ReleaseMode.loop);
    _playBackgroundMusic();

    _titlePulseController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _titlePulse = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _titlePulseController, curve: Curves.easeInOut));

    _floatController = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(CurvedAnimation(parent: _floatController, curve: Curves.easeInOut));
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserProfileStorage.loadProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _playBackgroundMusic() async {
    if (!_isBgsPlaying) {
      await _bgPlayer.play(AssetSource('soundtrack/backsound_utama.mp3'));
      _isBgsPlaying = true;
    }
  }

  Future<void> _stopBackgroundMusic() async {
    await _bgPlayer.pause();
    _isBgsPlaying = false;
  }

  Future<void> _playButtonSFX() async {
    await _sfxPlayer.stop();
    await _sfxPlayer.play(AssetSource('soundtrack/backsound_tombol.mp3'));
  }

  Future<void> _navigateWithSound(Widget page) async {
    await _playButtonSFX();
    await _stopBackgroundMusic();
    await Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    await _loadUserProfile(); // Tambahan untuk reload data profil
    await _playBackgroundMusic(); // Resume backsound saat kembali ke home
  }

  @override
  void dispose() {
    _bgPlayer.dispose();
    _sfxPlayer.dispose();
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
                  child: Text('Gagal memuat data: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                );
              } else if (snapshot.hasData) {
                return SafeArea(
                  child: Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Judul
                          FadeInDown(
                            duration: const Duration(milliseconds: 1000),
                            child: ScaleTransition(
                              scale: _titlePulse,
                              child: Image.asset(
                                'assets/icon/judul.png',
                                width: screenSize.width * 0.7,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Avatar & nama
                          GestureDetector(
                            onTap: () => _navigateWithSound(const ProfilePage()),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: _userProfile?.avatarPath != null
                                      ? AssetImage(_userProfile!.avatarPath)
                                      : const AssetImage('assets/icon/ikon_profil1.png'),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _userProfile?.name != null && _userProfile!.name.isNotEmpty
                                      ? 'Selamat datang, ${_userProfile!.name}!'
                                      : 'Selamat datang!',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                    shadows: [Shadow(blurRadius: 4, color: Colors.black)],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 30),

                          // ✅ Tombol Belajar (di atas)
                          BounceInUp(
                            duration: const Duration(milliseconds: 1600),
                            child: AnimatedBuilder(
                              animation: _floatAnim,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _floatAnim.value),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (_loadedAnimalData != null) {
                                        _navigateWithSound(LearnPage(animalData: _loadedAnimalData!));
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/icon/icon_belajar.png',
                                      width: screenSize.width * 0.55,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          // ✅ Tombol Bermain (di bawah)
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
                                        _navigateWithSound(PlayPage(animalData: _loadedAnimalData!));
                                      }
                                    },
                                    child: Image.asset(
                                      'assets/icon/icon_bermain.png',
                                      width: screenSize.width * 0.55,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
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
