import 'dart:convert'; // Diperlukan untuk jsonDecode
import 'package:flutter/services.dart' show rootBundle; // Diperlukan untuk memuat aset

/// Model untuk merepresentasikan data satu hewan.
class Animal {
  final String nama;
  final String gambar;
  final String suara;
  final String suaraNama;

  Animal({
    required this.nama,
    required this.gambar,
    required this.suara,
    required this.suaraNama,
  });

  /// Factory constructor untuk membuat objek Animal dari Map (data JSON).
  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      nama: json['nama'] as String,
      gambar: json['gambar'] as String,
      suara: json['suara'] as String,
      suaraNama: json['suara_nama'] as String,
    );
  }
}

/// Model untuk merepresentasikan seluruh data hewan berdasarkan kategori (darat, air, udara).
class AnimalData {
  final List<Animal> darat;
  final List<Animal> air;
  final List<Animal> udara;

  AnimalData({
    required this.darat,
    required this.air,
    required this.udara,
  });

  /// Factory constructor untuk membuat objek AnimalData dari Map (data JSON utama).
  factory AnimalData.fromJson(Map<String, dynamic> json) {
    final List<Animal> daratList = (json['darat'] as List)
        .map((e) => Animal.fromJson(e as Map<String, dynamic>))
        .toList();
    final List<Animal> airList = (json['air'] as List)
        .map((e) => Animal.fromJson(e as Map<String, dynamic>))
        .toList();
    final List<Animal> udaraList = (json['udara'] as List)
        .map((e) => Animal.fromJson(e as Map<String, dynamic>))
        .toList();

    return AnimalData(
      darat: daratList,
      air: airList,
      udara: udaraList,
    );
  }

  /// Metode statis untuk memuat data hewan dari file JSON di assets menggunakan rootBundle.
  static Future<AnimalData> loadFromJsonAsset(String assetPath) async {
    // Menggunakan rootBundle untuk memuat string JSON dari asset tanpa context
    final String response = await rootBundle.loadString(assetPath);
    // Mengonversi string JSON menjadi Map<String, dynamic>
    final data = jsonDecode(response) as Map<String, dynamic>;
    // Membuat objek AnimalData dari Map yang dihasilkan
    return AnimalData.fromJson(data);
  }

  /// Getter untuk mendapatkan daftar gabungan dari semua hewan (darat, air, udara).
  List<Animal> get allAnimals {
    return [...darat, ...air, ...udara]; // Menggabungkan semua list menjadi satu
  }
}