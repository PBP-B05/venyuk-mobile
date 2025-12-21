// =====================================
// FILE: lib/models/user.dart
// =====================================

class User {
  final String username;
  final bool isSuperuser;
  final String? token;

  User({
    required this.username,
    required this.isSuperuser,
    this.token,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'] ?? '',
      isSuperuser: json['is_superuser'] ?? false,
      token: json['token'],
    );
  }
}