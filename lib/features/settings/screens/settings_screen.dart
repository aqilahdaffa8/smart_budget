import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../../shared/providers/theme_provider.dart';
import '../../auth/providers/auth_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil data user yang sedang login dari Firebase
    final user = FirebaseAuth.instance.currentUser;
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan & Profil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Bagian Profil
          CircleAvatar(
            radius: 50,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(
              Icons.person,
              size: 50,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.email ?? 'Email tidak ditemukan',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 32),
          const Divider(),

          // Bagian Preferensi
          ListTile(
            leading: const Icon(Icons.dark_mode_outlined),
            title: const Text('Mode Gelap (Dark Mode)'),
            subtitle: const Text('Ubah tema tampilan aplikasi'),
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeColor: Theme.of(context).colorScheme.primary,
              onChanged: (value) {
                // Memanggil method toggleTheme dari ThemeProvider (Tahap 1)
                context.read<ThemeProvider>().toggleTheme(value);
              },
            ),
          ),
          const Divider(),

          // Bagian Informasi
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Tentang Aplikasi'),
            subtitle: const Text('SmartBudget v1.0.0'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'SmartBudget',
                applicationVersion: '1.0.0',
                applicationIcon: const Icon(Icons.account_balance_wallet, size: 40),
                applicationLegalese: '© 2026 SmartBudget App\nA Production Portfolio.',
              );
            },
          ),
          const Divider(),

          // Bagian Aksi Berbahaya (Logout)
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Keluar (Logout)',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              // Tutup layar setting dulu, baru panggil fungsi logout
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
          ),
        ],
      ),
    );
  }
}