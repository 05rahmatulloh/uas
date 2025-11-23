import 'package:flutter/material.dart';
import 'package:Santri/features/auth/controllers/auth_controller.dart';
import 'package:Santri/features/auth/model/user_model.dart';
// import 'auth_controller.dart';
// import 'user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthController _authController = AuthController();
  User? _user;
  bool _isLoading = true;

  User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoaded => !_isLoading;
  bool get isLoading => _isLoading;

  AuthProvider() {
    loadUser();
  }

  Future<void> loadUser() async {
    _isLoading = true;
    notifyListeners();
    _user = await _authController.getLoggedInUser();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(User user) async {
    _user = user;
    notifyListeners();
  }

  Future<void> logout() async {
    await _authController.logout();
    _user = null;
    notifyListeners();
  }
}
