import 'package:flutter/material.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';
import 'package:zooplay/models/animal.dart';
import 'package:zooplay/screens/home_page.dart';

class GuessSoundGamePage extends StatefulWidget {
  final List<Animal> animals;

  const GuessSoundGamePage({super.key, required this.animals});

  @override
  State<GuessSoundGamePage> createState() => _GuessSoundGamePageState();
}

class _GuessSoundGamePageState extends State<GuessSoundGamePage> {
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
    _startNewRound();
  }

  @override
  void dispose() {
    _questionPlayer.dispose();
    _namePlayer.dispose();
    _feedbackPlayer.dispose();
    super.dispose();
  }

  void _startNewRound() async {
    if (!mounted) return;

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

    await _playSound(_questionPlayer, _correctAnimal.suara);
  }

  Future<void> _playSound(AudioPlayer player, String assetPath) async {
    final cleanedPath = assetPath.replaceFirst('assets/', '');
    await player.stop();
    await player.play(AssetSource(cleanedPath));
  }

  Future<void> _checkAnswer(Animal selectedAnimal) async {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerAnimalName = selectedAnimal.nama;
      _isAnswered = true;
    });

    await _playSound(_namePlayer, selectedAnimal.suaraNama);

    if (selectedAnimal.nama == _correctAnimal.nama) {
      _correctCount++;
      await _playSound(_feedbackPlayer, 'soundtrack/backsound_jawaban_benar.mp3');
      final positifList = ['benar_hebat.mp3', 'benar_keren.mp3', 'benar_luarbiasa.mp3'];
      await _playSound(_feedbackPlayer, 'soundtrack/${positifList[Random().nextInt(positifList.length)]}');
    } else {
      _wrongCount++;
      final salahList = ['salah_belajarlagiya.mp3', 'salah_salahbubuub.mp3'];
      await _playSound(_feedbackPlayer, 'soundtrack/${salahList[Random().nextInt(salahList.length)]}');
    }

    await Future.delayed(const Duration(seconds: 2));

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
        body: const Center(child: Text('Tidak ada data hewan.')),
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
          gradient: LinearGradient(colors: [Colors.orangeAccent, Colors.deepOrange]),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Suara hewan apa ini?',
                style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 50, color: Colors.white),
              onPressed: _isAnswered ? null : () => _playSound(_questionPlayer, _correctAnimal.suara),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(20),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                ),
                itemCount: _questionAnimals.length,
                itemBuilder: (context, index) {
                  final animal = _questionAnimals[index];
                  final isSelected = _selectedAnswerAnimalName == animal.nama;

                  Color color = Colors.white;
                  if (_isAnswered) {
                    if (animal.nama == _correctAnimal.nama) {
                      color = Colors.green.shade300;
                    } else if (isSelected) {
                      color = Colors.red.shade300;
                    }
                  }

                  return GestureDetector(
                    onTap: _isAnswered ? null : () => _checkAnswer(animal),
                    child: Card(
                      color: color,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: isSelected
                              ? (animal.nama == _correctAnimal.nama ? Colors.green : Colors.red)
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(animal.gambar, fit: BoxFit.contain),
                            ),
                          ),
                          Text(
                            animal.nama,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
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
