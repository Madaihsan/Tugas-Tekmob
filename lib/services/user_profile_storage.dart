import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';

class UserProfileStorage {
  static const String _storageKey = 'user_profile';

  /// Simpan profil ke SharedPreferences
  static Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = jsonEncode(profile.toJson());
    await prefs.setString(_storageKey, profileJson);
  }

  /// Ambil profil dari SharedPreferences
  // ignore: unintended_html_in_doc_comment
  /// Mengembalikan Future<UserProfile?> (nullable)
  static Future<UserProfile?> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_storageKey);

    if (profileJson == null) return null;

    try {
      final Map<String, dynamic> json = jsonDecode(profileJson);
      return UserProfile.fromJson(json);
    } catch (e) {
      // Optional: bisa log error di debug mode
      return null;
    }
  }

  /// Hapus profil dari SharedPreferences (jika reset)
  static Future<void> clearProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
