import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'shared/providers/theme_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/splash_screen.dart';

class SmartBudgetApp extends StatelessWidget {
  const SmartBudgetApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      title: 'SmartBudget',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      
      // Tema Kustom Hijau Teal
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      
      // Halaman Pertama
      home: const SplashScreen(), 
    );
  }
}