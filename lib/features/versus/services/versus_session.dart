import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../versus_config.dart';

class VersusSession {
  static const _kUserId = 'versus_user_id';
  static const _kUsername = 'versus_username';

  static String? _cachedUsername;
  static DateTime? _cachedAt;

  /// Simpan meta login untuk fallback Versus (kalau cookie/session gak kebawa).
  /// - userId opsional 
  static Future<void> saveLogin({
    int? userId,
    required String username,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    if (userId != null) {
      await prefs.setInt(_kUserId, userId);
    }
    await prefs.setString(_kUsername, username);

    // update cache biar langsung kebaca
    _cachedUsername = username;
    _cachedAt = DateTime.now();
  }

  static Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kUserId);
  }

  static Future<String?> getSavedUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final u = prefs.getString(_kUsername);
    if (u == null || u.isEmpty) return null;
    return u;
  }

  /// Ambil username dari server via session cookie (CookieRequest).
  /// Cache 30 detik biar gak spam request.
  /// Kalau gagal (cookie gak kebawa), fallback ke username tersimpan.
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
      // ignore
    }

    // fallback local
    final local = await getSavedUsername();
    _cachedUsername = local;
    _cachedAt = now;
    return local;
  }

  /// Helper: nambahin username/user_id ke body request kalau ada.
  static Future<Map<String, dynamic>> withFallbackIdentity(
      Map<String, dynamic> body) async {
    final username = await getSavedUsername();
    final userId = await getUserId();

    final result = <String, dynamic>{...body};
    if (username != null && username.isNotEmpty) result['username'] = username;
    if (userId != null) result['user_id'] = userId;

    return result;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kUserId);
    await prefs.remove(_kUsername);
    _cachedUsername = null;
    _cachedAt = null;
  }
}
