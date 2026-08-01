import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/widgets/loading_indicator.dart';
import '../../dashboard/screens/dashboard_screen.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // Memantau perubahan state auth secara real-time dari Firebase
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Jika sedang mengecek (Loading)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: LoadingIndicator(message: 'Memeriksa sesi...'),
          );
        }

        // Jika user memiliki data/sesi aktif
        if (snapshot.hasData) {
          return const DashboardScreen();
        }

        // Jika user tidak aktif/belum login
        return const LoginScreen();
      },
    );
  }
}