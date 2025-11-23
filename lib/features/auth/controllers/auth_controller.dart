import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:Santri/features/auth/model/user_model.dart';
// import 'user_model.dart';

class AuthController {
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Simulasi login
  Future<User?> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1)); // Simulasi request API

    User? user;
    if (email == "admin@pesantren.com" && password == "123") {
      user = User(email: email, role: "admin");
    } else if (email == "wali@pesantren.com" && password == "123") {
      user = User(email: email, role: "wali");
    } else if (email == "ustadz@pesantren.com" && password == "123") {
      user = User(email: email, role: "ustadz");
    }

    if (user != null) {
      await _storage.write(key: 'email', value: user.email);
      await _storage.write(key: 'role', value: user.role);
    }

    return user;
  }

  Future<User?> getLoggedInUser() async {
    final email = await _storage.read(key: 'email');
    final role = await _storage.read(key: 'role');
    if (email != null && role != null) {
      return User(email: email, role: role);
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.delete(key: 'email');
    await _storage.delete(key: 'role');
  }
}
