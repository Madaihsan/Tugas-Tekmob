import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:math';
import 'dart:developer' as developer;
import 'package:zooplay/models/animal.dart';

class GuessNameGamePage extends StatefulWidget {
  final List<Animal> animals;

  const GuessNameGamePage({super.key, required this.animals});

  @override
  State<GuessNameGamePage> createState() => _GuessNameGamePageState();
}

class _GuessNameGamePageState extends State<GuessNameGamePage> {
  final AudioPlayer _voicePlayer = AudioPlayer();
  final AudioPlayer _feedbackPlayer = AudioPlayer();

  List<Animal> _questionAnimals = [];
  late Animal _correctAnimal;
  String? _selectedAnswerAnimalName;
  bool _isAnswered = false;

  int _currentQuestion = 0;
  int _scoreCorrect = 0;

  @override
  void initState() {
    super.initState();
    _voicePlayer.setReleaseMode(ReleaseMode.stop);
    _feedbackPlayer.setReleaseMode(ReleaseMode.stop);
    _startNewRound();
  }

  @override
  void dispose() {
    _voicePlayer.dispose();
    _feedbackPlayer.dispose();
    super.dispose();
  }

  void _startNewRound() {
    if (_currentQuestion >= 5) {
      _showResultDialog();
      return;
    }

    setState(() {
      _selectedAnswerAnimalName = null;
      _isAnswered = false;

      _correctAnimal = widget.animals[Random().nextInt(widget.animals.length)];

      List<Animal> otherAnimals = widget.animals
          .where((animal) => animal.nama != _correctAnimal.nama)
          .toList()
        ..shuffle();

      _questionAnimals = [_correctAnimal];
      for (int i = 0; i < 3 && i < otherAnimals.length; i++) {
        _questionAnimals.add(otherAnimals[i]);
      }

      _questionAnimals.shuffle();
    });
  }

  Future<void> _playSound(String path) async {
    try {
      if (path.isEmpty) return;
      final cleaned = path.replaceFirst('assets/', '');
      await _voicePlayer.stop();
      await _voicePlayer.play(AssetSource(cleaned));
    } catch (e) {
      developer.log('Gagal memutar suara: $e', name: 'GuessNameGamePage');
    }
  }

  Future<void> _playFeedback(bool isCorrect) async {
    final sounds = isCorrect
        ? ['soundtrack/benar_keren.mp3', 'soundtrack/benar_luarbiasa.mp3', 'soundtrack/benar_hebat.mp3']
        : ['soundtrack/salah_salahbubuub.mp3', 'soundtrack/salah_belajarlagiya.mp3'];
    final sound = (sounds..shuffle()).first;

    try {
      await _feedbackPlayer.stop();
      await _feedbackPlayer.play(AssetSource(sound));
    } catch (e) {
      developer.log('Gagal memutar feedback: $e', name: 'GuessNameGamePage');
    }
  }

  void _checkAnswer(Animal selectedAnimal) async {
    if (_isAnswered) return;

    setState(() {
      _selectedAnswerAnimalName = selectedAnimal.nama;
      _isAnswered = true;
    });

    await _playSound(selectedAnimal.suaraNama);
    await Future.delayed(const Duration(milliseconds: 1200));
    bool isCorrect = selectedAnimal.nama == _correctAnimal.nama;
    if (isCorrect) _scoreCorrect++;

    await _playFeedback(isCorrect);

    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() {
        _currentQuestion++;
      });
      _startNewRound();
    }
  }

  void _showResultDialog() {
    int wrong = 5 - _scoreCorrect;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Hasil Permainan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Soal: 5'),
            Text('Jawaban Benar: $_scoreCorrect'),
            Text('Jawaban Salah: $wrong'),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Image.asset('assets/icon/ikon_home.png', width: 50),
                  onPressed: () {
                    Navigator.of(context).pop(); // Tutup dialog
                    Navigator.of(context).pop(); // Kembali ke home
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icon/ikon_play.png', width: 50),
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _scoreCorrect = 0;
                      _currentQuestion = 0;
                    });
                    _startNewRound();
                  },
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
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tebak Nama Hewan'),
        backgroundColor: Colors.orange,
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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Image.asset(
                _correctAnimal.gambar,
                height: 180,
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                'Nama hewan apa ini?',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [Shadow(blurRadius: 5.0, color: Colors.black, offset: Offset(2.0, 2.0))],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 15,
                  crossAxisSpacing: 15,
                  childAspectRatio: 2.5,
                ),
                itemCount: _questionAnimals.length,
                itemBuilder: (context, index) {
                  final animal = _questionAnimals[index];
                  final isSelected = _selectedAnswerAnimalName == animal.nama;

                  Color cardColor = Colors.white;
                  if (_isAnswered) {
                    if (animal.nama == _correctAnimal.nama) {
                      cardColor = Colors.green.shade300;
                    } else if (isSelected) {
                      cardColor = Colors.red.shade300;
                    }
                  } else if (isSelected) {
                    cardColor = Colors.blue.shade100;
                  }

                  return GestureDetector(
                    onTap: _isAnswered ? null : () => _checkAnswer(animal),
                    child: Card(
                      color: cardColor,
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide(
                          color: isSelected && _isAnswered
                              ? (animal.nama == _correctAnimal.nama ? Colors.green.shade800 : Colors.red.shade800)
                              : (isSelected ? Colors.blue.shade800 : Colors.transparent),
                          width: 3,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          animal.nama,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
