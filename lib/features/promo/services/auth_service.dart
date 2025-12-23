import 'package:venyuk_mobile/features/promo/models/user.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

class AuthService {
  static User? _currentUser;

  static User? get currentUser => _currentUser;
  
  static bool get isSuperuser => _currentUser?.isSuperuser ?? false;

  static Future<void> login({
    required String username,
    required bool isSuperuser,
  }) async {
    _currentUser = User(
      username: username,
      isSuperuser: isSuperuser,
    );
  }

  static void logout() {
    _currentUser = null;
  }
}