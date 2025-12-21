// =====================================
// FILE: lib/services/auth_service.dart
// =====================================

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:venyuk_mobile/features/promo/models/user.dart';

class AuthService {
  static const String baseUrl = 'http://localhost:8000';
  static User? _currentUser;

  static User? get currentUser => _currentUser;

  static void setUser(User user) {
    _currentUser = user;
  }

  static bool get isSuperuser => _currentUser?.isSuperuser ?? false;

  // Untuk sementara, set dummy user (nanti bisa diganti dengan real login)
  static void setDummyUser({bool isSuperuser = false}) {
    _currentUser = User(
      username: 'pbpb05',
      isSuperuser: isSuperuser,
    );
  }
}