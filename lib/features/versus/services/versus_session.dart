// lib/features/versus/services/versus_session.dart
import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../versus_config.dart';

class VersusSession {
  static String? _cachedUsername;
  static DateTime? _cachedAt;

  /// Ambil username dari server via session cookie (CookieRequest).
  /// Cache 30 detik biar gak spam request.
  static Future<String?> getUsername(CookieRequest request) async {
    final now = DateTime.now();
    if (_cachedUsername != null &&
        _cachedAt != null &&
        now.difference(_cachedAt!).inSeconds < 30) {
      return _cachedUsername;
    }

    try {
      final resp = await request.get(authUserDataUrl());
      if (resp is Map) {
        final map = resp.cast<String, dynamic>();
        final isAuth = map['is_authenticated'] == true;
        if (isAuth) {
          final username = (map['username'] ?? '').toString();
          if (username.isNotEmpty) {
            _cachedUsername = username;
            _cachedAt = now;
            return username;
          }
        }
      }
    } catch (_) {
      // ignore: fallback null
    }

    _cachedUsername = null;
    _cachedAt = now;
    return null;
  }

  static void clear() {
    _cachedUsername = null;
    _cachedAt = null;
  }
}
