import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;

  // Dependency Injection (Memudahkan Unit Testing nantinya)
  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  // Stream untuk memantau status login/logout secara realtime
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Translasi error Firebase ke bahasa yang *User-friendly*
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email tidak ditemukan. Silakan daftar terlebih dahulu.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah terdaftar. Silakan login.';
      case 'weak-password':
        return 'Password terlalu lemah. Gunakan minimal 6 karakter.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      default:
        return 'Terjadi kesalahan autentikasi: ${e.message}';
    }
  }
}