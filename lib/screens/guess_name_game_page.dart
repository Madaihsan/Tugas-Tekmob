import 'package:flutter/material.dart';
import 'package:zooplay/models/animal.dart';
import 'dart:math'; // Untuk fungsi random
import 'dart:developer' as developer; // Untuk logging

class GuessNameGamePage extends StatefulWidget {
  final List<Animal> animals;

  const GuessNameGamePage({super.key, required this.animals});

  @override
  State<GuessNameGamePage> createState() => _GuessNameGamePageState();
}

class _GuessNameGamePageState extends State<GuessNameGamePage> {
  List<Animal> _questionAnimals = []; // Hewan untuk pilihan jawaban
  late Animal _correctAnimal; // Hewan yang benar
  String? _selectedAnswerAnimalName; // Nama hewan yang dipilih pengguna
  bool _isAnswered = false; // Status apakah pertanyaan sudah dijawab
  // Variabel _feedbackColor dihapus karena tidak digunakan dan logikanya sudah dihandle langsung di itemBuilder

  @override
  void initState() {
    super.initState();
    _startNewRound();
  }

  void _startNewRound() {
    if (!mounted) return; // Pastikan widget masih aktif sebelum update state
    setState(() {
      _selectedAnswerAnimalName = null;
      _isAnswered = false;
      // _feedbackColor = null; // Ini juga tidak diperlukan lagi

      if (widget.animals.isEmpty) {
        developer.log('No animals found to start game.', name: 'GameError');
        // Anda bisa tambahkan logika untuk menampilkan pesan atau kembali jika tidak ada hewan
        return;
      }

      // Pilih hewan yang benar secara acak
      _correctAnimal = widget.animals[Random().nextInt(widget.animals.length)];

      // Pilih 3 hewan lain sebagai pilihan jawaban (total 4 pilihan)
      // Filter hewan yang namanya tidak sama dengan hewan yang benar
      List<Animal> otherAnimals = widget.animals
          .where((animal) => animal.nama != _correctAnimal.nama)
          .toList();
      
      // Acak otherAnimals agar pilihan pengecoh bervariasi
      otherAnimals.shuffle(Random());
      
      _questionAnimals = [_correctAnimal]; // Tambahkan hewan yang benar ke pilihan
      // Tambahkan hingga 3 hewan pengecoh, atau kurang jika tidak cukup
      for (int i = 0; i < 3 && i < otherAnimals.length; i++) {
        _questionAnimals.add(otherAnimals[i]);
      }
      
      _questionAnimals.shuffle(Random()); // Acak urutan pilihan jawaban akhir
    });
  }

  void _checkAnswer(String selectedAnimalName) {
    if (_isAnswered) return; // Jangan izinkan menjawab lagi jika sudah dijawab

    setState(() {
      _selectedAnswerAnimalName = selectedAnimalName;
      _isAnswered = true;
      // Logika _feedbackColor sudah dihandle langsung di builder Card berdasarkan _selectedAnswerAnimalName dan _correctAnimal.nama
    });

    // Beri sedikit jeda lalu mulai ronde baru
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) { // Periksa mounted sebelum update state setelah async gap
        _startNewRound();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Tampilkan pesan jika tidak ada hewan yang tersedia untuk permainan
    if (_questionAnimals.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Tebak Nama'),
          backgroundColor: Colors.orange,
          centerTitle: true,
        ),
        body: const Center(
          child: Text(
            'Tidak ada hewan yang tersedia untuk permainan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
        ),
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
                _correctAnimal.gambar, // Tampilkan gambar hewan yang benar
                height: 180, // Sesuaikan ukuran gambar agar tidak terlalu besar
                fit: BoxFit.contain,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                'Nama hewan apa ini?',
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
            const SizedBox(height: 30), // Spasi vertikal

            // Pilihan jawaban dalam GridView (teks nama hewan)
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(15),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // 2 kolom
                  crossAxisSpacing: 15, // Spasi horizontal antar item
                  mainAxisSpacing: 15, // Spasi vertikal antar item
                  childAspectRatio: 2.5, // Rasio aspek untuk tombol teks (lebih lebar dari tinggi)
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
                        side: BorderSide( // Border untuk feedback visual lebih jelas
                          color: isSelected && _isAnswered // Border setelah dijawab
                              ? (animal.nama == _correctAnimal.nama ? Colors.green.shade800 : Colors.red.shade800)
                              : (isSelected ? Colors.blue.shade800 : Colors.transparent), // Border sebelum dijawab
                          width: 3,
                        ),
                      ),
                      color: cardColor, // Terapkan warna yang sudah ditentukan
                      child: Center(
                        child: Text(
                          animal.nama,
                          textAlign: TextAlign.center,
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