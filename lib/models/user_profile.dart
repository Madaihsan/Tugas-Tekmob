class UserProfile {
  final String name;
  final String avatarPath;

  UserProfile({
    required this.name,
    required this.avatarPath,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'avatarPath': avatarPath,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        name: json['name'] ?? '',
        avatarPath: json['avatarPath'] ?? 'assets/icon/ikon_profil1.png',
      );
}
