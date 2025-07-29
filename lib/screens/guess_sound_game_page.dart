import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:developer' as developer; // Import developer log
import 'package:audioplayers/audioplayers.dart';
import 'package:zooplay/models/animal.dart';

class GuessSoundGamePage extends StatefulWidget {
  final List<Animal> animals;

  const GuessSoundGamePage({super.key, required this.animals});

  @override
  State<GuessSoundGamePage> createState() => _GuessSoundGamePageState();
}

class _GuessSoundGamePageState extends State<GuessSoundGamePage> {
  // --- PERUBAHAN: Tambah player untuk suara intro pertanyaan ---
  final AudioPlayer _introPlayer = AudioPlayer();
  final AudioPlayer _questionPlayer = AudioPlayer();
  final AudioPlayer _namePlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  List<Animal> _questionAnimals = [];
  late Animal _correctAnimal;
  String? _selectedAnswerAnimalName;
  bool _isAnswered = false;

  int _currentQuestion = 0;
  int _correctCount = 0;
  int _wrongCount = 0;

  @override
  void initState() {
    super.initState();
    // --- PERUBAHAN: Set release mode untuk player baru ---
    _introPlayer.setReleaseMode(ReleaseMode.stop);
    _startNewRound();
  }

  @override
  void dispose() {
    // --- PERUBAHAN: Dispose player baru ---
    _introPlayer.dispose();
    _questionPlayer.dispose();
    _namePlayer.dispose();
    _feedbackPlayer.dispose();
    super.dispose();
  }
  
  // --- PERUBAHAN: Fungsi baru untuk memutar suara intro ---
  Future<void> _playIntroSound() async {
    try {
      await _introPlayer.stop();
      await _introPlayer.play(AssetSource('soundtrack/suara_pertanyaan_tebaksuara_hewan.mp3'));
    } catch (e) {
      developer.log('Gagal memutar suara intro: $e', name: 'GuessSoundGamePage');
    }
  }

  void _startNewRound() async {
    if (!mounted) return;

    // --- PERUBAHAN: Panggil suara intro di awal ronde ---
    await _playIntroSound();

    setState(() {
      _selectedAnswerAnimalName = null;
      _isAnswered = false;
    });

    final List<Animal> withSound = widget.animals.where((e) => e.suara.isNotEmpty).toList();
    if (withSound.isEmpty) return;

    _correctAnimal = withSound[Random().nextInt(withSound.length)];
    List<Animal> options = [ _correctAnimal ];
    List<Animal> others = withSound.where((e) => e.nama != _correctAnimal.nama).toList()..shuffle();
    options.addAll(others.take(3));
    options.shuffle();

    setState(() {
      _questionAnimals = options;
    });

    // --- PERUBAHAN: Beri jeda sebelum suara hewan diputar ---
    await Future.delayed(const Duration(milliseconds: 1800));

    // Pastikan widget masih ada sebelum memutar suara
    if (mounted && !_isAnswered) {
      await _playSound(_questionPlayer, _correctAnimal.suara);
    }
  }

  Future<void> _playSound(AudioPlayer player, String assetPath) async {
    try {
      final cleanedPath = assetPath.replaceFirst('assets/', '');
      await player.stop();
      await player.play(AssetSource(cleanedPath));
    } catch (e) {
      developer.log('Gagal memutar suara: $e', name: 'GuessSoundGamePage');
    }
  }

  Future<void> _checkAnswer(Animal selectedAnimal) async {
    if (_isAnswered) return;

    // --- PERUBAHAN: Hentikan suara intro & pertanyaan saat jawaban dipilih ---
    await _introPlayer.stop();
    await _questionPlayer.stop();

    setState(() {
      _selectedAnswerAnimalName = selectedAnimal.nama;
      _isAnswered = true;
    });

    await _playSound(_namePlayer, selectedAnimal.suaraNama);
    await Future.delayed(const Duration(milliseconds: 1200)); // Beri jeda agar suara nama selesai

    bool isCorrect = selectedAnimal.nama == _correctAnimal.nama;

    if (isCorrect) {
      _correctCount++;
      // Mainkan backsound benar dahulu, lalu suara pujian
      await _playSound(_feedbackPlayer, 'soundtrack/backsound_jawaban_benar.mp3');
      await Future.delayed(const Duration(milliseconds: 1000));
      final positifList = ['benar_hebat.mp3', 'benar_keren.mp3', 'benar_luarbiasa.mp3'];
      await _playSound(_feedbackPlayer, 'soundtrack/${positifList[Random().nextInt(positifList.length)]}');
    } else {
      _wrongCount++;
      final salahList = ['salah_belajarlagiya.mp3', 'salah_salahbubuub.mp3'];
      await _playSound(_feedbackPlayer, 'soundtrack/${salahList[Random().nextInt(salahList.length)]}');
    }

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (_currentQuestion + 1 >= 5) {
      _showResultDialog();
    } else {
      setState(() {
        _currentQuestion++;
      });
      _startNewRound();
    }
  }

  void _resetGame() {
    setState(() {
      _currentQuestion = 0;
      _correctCount = 0;
      _wrongCount = 0;
    });
    _startNewRound();
  }

  void _showResultDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.orange[100],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hasil Permainan', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Soal: 5', style: const TextStyle(fontSize: 16)),
            Text('Benar: $_correctCount', style: const TextStyle(fontSize: 16, color: Colors.green)),
            Text('Salah: $_wrongCount', style: const TextStyle(fontSize: 16, color: Colors.red)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context); // Kembali ke HomePage
                  },
                  child: Image.asset('assets/icon/ikon_home.png', width: 50),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    _resetGame();
                  },
                  child: Image.asset('assets/icon/ikon_play.png', width: 50),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questionAnimals.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Tebak Suara')),
        body: const Center(child: CircularProgressIndicator()), // Tampilkan loading
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tebak Suara Hewan'),
        backgroundColor: Colors.orange,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Suara hewan apakah ini?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white, shadows: [Shadow(blurRadius: 5.0, color: Colors.black, offset: Offset(2.0, 2.0))]),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 60, color: Colors.white),
              onPressed: _isAnswered ? null : () => _playSound(_questionPlayer, _correctAnimal.suara),
              iconSize: 60,
              splashRadius: 40,
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.8, // Sesuaikan rasio agar gambar dan teks pas
                ),
                itemCount: _questionAnimals.length,
                itemBuilder: (context, index) {
                  final animal = _questionAnimals[index];
                  final isSelected = _selectedAnswerAnimalName == animal.nama;

                  Color color = Colors.white;
                  Color borderColor = Colors.transparent;

                  if (_isAnswered) {
                    if (animal.nama == _correctAnimal.nama) {
                      color = Colors.green.shade300;
                      borderColor = Colors.green.shade800;
                    } else if (isSelected) {
                      color = Colors.red.shade300;
                      borderColor = Colors.red.shade800;
                    }
                  }

                  return GestureDetector(
                    onTap: _isAnswered ? null : () => _checkAnswer(animal),
                    child: Card(
                      color: color,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(color: borderColor, width: 3),
                      ),
                      clipBehavior: Clip.antiAlias, // Agar gambar tidak keluar dari border
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(animal.gambar, fit: BoxFit.contain),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                            child: Text(
                              animal.nama,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}