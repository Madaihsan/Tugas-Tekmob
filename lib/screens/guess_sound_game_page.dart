import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'dart:math'; // Untuk fungsi random
import 'package:audioplayers/audioplayers.dart'; // Untuk memutar suara
import 'dart:developer' as developer; // Untuk logging

class GuessSoundGamePage extends StatefulWidget {
  final List<Animal> animals;

  const GuessSoundGamePage({super.key, required this.animals});

  @override
  State<GuessSoundGamePage> createState() => _GuessSoundGamePageState();
}

class _GuessSoundGamePageState extends State<GuessSoundGamePage> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Animal> _questionAnimals = []; // Hewan untuk pilihan jawaban
  late Animal _correctAnimal; // Hewan yang benar
  String? _selectedAnswerAnimalName; // Nama hewan yang dipilih pengguna
  bool _isAnswered = false; // Status apakah pertanyaan sudah dijawab
  // Variabel _feedbackColor dihapus karena tidak digunakan dan logikanya sudah dihandle langsung di itemBuilder

  @override
  void initState() {
    super.initState();
    // Pastikan _audioPlayer diinisialisasi sebelum digunakan
    _audioPlayer.setReleaseMode(ReleaseMode.stop); // Hentikan audio saat aplikasi ditutup atau player di-dispose
    _startNewRound();
  }

  @override
  void dispose() {
    _audioPlayer.dispose(); // Pastikan player di-dispose saat widget tidak lagi digunakan
    super.dispose();
  }

  void _startNewRound() {
    // Periksa apakah widget masih mounted sebelum melakukan setState
    if (!mounted) return; 
    
    setState(() {
      _selectedAnswerAnimalName = null;
      _isAnswered = false;

      // Filter hewan yang memiliki suara non-kosong untuk game tebak suara
      final List<Animal> animalsWithSound = widget.animals.where((animal) => animal.suara.isNotEmpty).toList();

      if (animalsWithSound.isEmpty) {
        developer.log('No animals with sound found to start game.', name: 'GameError');
        // Anda bisa tambahkan logika untuk menampilkan pesan error atau kembali ke halaman sebelumnya
        return; 
      }

      // Pilih hewan yang benar secara acak dari daftar hewan yang memiliki suara
      _correctAnimal = animalsWithSound[Random().nextInt(animalsWithSound.length)];

      // Pilih hingga 3 hewan lain sebagai pilihan jawaban (total 4 pilihan)
      List<Animal> otherAnimals = animalsWithSound
          .where((animal) => animal.nama != _correctAnimal.nama) // Jangan pilih hewan yang sama dengan yang benar
          .toList();
      
      // Acak otherAnimals dan ambil beberapa untuk dijadikan pengecoh
      otherAnimals.shuffle(Random());
      
      _questionAnimals = [_correctAnimal]; // Tambahkan hewan yang benar ke pilihan
      // Tambahkan hingga 3 hewan pengecoh dari daftar otherAnimals yang sudah diacak
      for (int i = 0; i < 3 && i < otherAnimals.length; i++) {
        _questionAnimals.add(otherAnimals[i]);
      }
      
      _questionAnimals.shuffle(Random()); // Acak urutan pilihan jawaban akhir
    });

    _playQuestionSound(); // Putar suara pertanyaan setelah ronde baru dimulai
  }

  Future<void> _playQuestionSound() async {
    // Bersihkan path 'assets/' karena audioplayers AssetSource mungkin tidak memerlukannya
    final String cleanedSoundPath = _correctAnimal.suara.replaceFirst('assets/', '');
    developer.log('Playing question sound: $cleanedSoundPath', name: 'AudioDebug');
    
    try {
      await _audioPlayer.stop(); // Hentikan suara yang sedang bermain
      await _audioPlayer.play(AssetSource(cleanedSoundPath));
    } catch (e, stackTrace) {
      // Periksa apakah widget masih mounted sebelum menggunakan context setelah async gap
      if (!mounted) {
        developer.log('Widget not mounted, cannot show SnackBar for audio error.', name: 'GameError');
        return;
      }
      developer.log('Error playing question sound: $e', name: 'AudioError', error: e, stackTrace: stackTrace);
      
      // Tampilkan SnackBar untuk memberitahu pengguna jika ada error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memutar suara pertanyaan: ${e.toString().split(':')[0]}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _checkAnswer(String selectedAnimalName) {
    if (_isAnswered) return; // Jangan izinkan menjawab lagi jika pertanyaan sudah dijawab

    setState(() {
      _selectedAnswerAnimalName = selectedAnimalName;
      _isAnswered = true;
      // Logika untuk menentukan warna Card sudah dihandle langsung di itemBuilder
    });

    // Beri sedikit jeda (2 detik) lalu mulai ronde baru
    Future.delayed(const Duration(seconds: 2), () {
      // Periksa apakah widget masih mounted sebelum melakukan update state
      if (mounted) {
        _startNewRound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan pesan jika tidak ada hewan dengan suara yang tersedia
    if (_questionAnimals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tebak Suara'),
          backgroundColor: Colors.orange,
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Tidak ada hewan dengan suara yang tersedia untuk permainan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tebak Suara Hewan'),
        backgroundColor: Colors.orange, // Warna AppBar untuk halaman bermain
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.deepOrangeAccent], // Gradien warna untuk latar belakang
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'Suara hewan apa ini?',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [ // Efek bayangan pada teks agar lebih menonjol
                    Shadow(blurRadius: 5.0, color: Colors.black, offset: Offset(2.0, 2.0)),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Tombol untuk memutar ulang suara pertanyaan
            IconButton(
              icon: const Icon(Icons.volume_up, size: 60, color: Colors.white),
              onPressed: _isAnswered ? null : _playQuestionSound, // Tombol dinonaktifkan setelah dijawab
              tooltip: 'Dengarkan suara',
            ),
            const SizedBox(height: 30), // Spasi vertikal

            // Pilihan jawaban dalam GridView
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 kolom
                  crossAxisSpacing: 15, // Spasi horizontal antar item
                  mainAxisSpacing: 15, // Spasi vertikal antar item
                  childAspectRatio: 0.9, // Rasio aspek untuk gambar hewan
                ),
                itemCount: _questionAnimals.length,
                itemBuilder: (context, index) {
                  final animal = _questionAnimals[index];
                  final isSelected = _selectedAnswerAnimalName == animal.nama;
                  
                  // Logika untuk menentukan warna Card
                  Color cardColor = Colors.white; // Warna default
                  if (_isAnswered) { // Jika sudah dijawab
                    if (animal.nama == _correctAnimal.nama) {
                      cardColor = Colors.green.shade300; // Jawaban benar -> hijau
                    } else if (isSelected) {
                      cardColor = Colors.red.shade300; // Jawaban salah yang dipilih -> merah
                    }
                  } else if (isSelected) { // Jika sedang dipilih tapi belum dijawab
                    cardColor = Colors.blue.shade100; // Highlight pilihan
                  }

                  return GestureDetector(
                    onTap: _isAnswered ? null : () => _checkAnswer(animal.nama), // Nonaktifkan klik setelah dijawab
                    child: Card(
                      elevation: 6,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                        side: BorderSide( // Border untuk feedback visual yang lebih jelas
                          color: isSelected && _isAnswered // Border setelah dijawab
                              ? (animal.nama == _correctAnimal.nama ? Colors.green.shade800 : Colors.red.shade800)
                              : (isSelected ? Colors.blue.shade800 : Colors.transparent), // Border sebelum dijawab
                          width: 3,
                        ),
                      ),
                      color: cardColor, // Terapkan warna yang sudah ditentukan
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Image.asset(
                                animal.gambar,
                                fit: BoxFit.contain, // Memastikan gambar tidak terpotong
                              ),
                            ),
                          ),
                          Text(
                            animal.nama,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 8), // Spasi kecil di bawah nama
                        ],
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