import 'package:flutter/material.dart';
import '../repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  AuthProvider({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository();

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signIn(email, password);
    } catch (e) {
      rethrow; // Lempar ke UI untuk ditampilkan di SnackBar
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password) async {
    _setLoading(true);
    try {
      await _authRepository.signUp(email, password);
    } catch (e) {
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    await _authRepository.signOut();
    _setLoading(false);
  }
}