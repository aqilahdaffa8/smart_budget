import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class AppTheme {
  // Text Theme dengan Google Fonts
  static TextTheme _buildTextTheme(TextTheme base) {
    return GoogleFonts.poppinsTextTheme(base);
  }

  // Light Theme Data
  static ThemeData get lightTheme {
    final base = ThemeData.light();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.onPrimaryLight,
        primaryContainer: AppColors.primaryContainerLight,
        onPrimaryContainer: AppColors.onPrimaryContainerLight,
        background: AppColors.backgroundLight,
        surface: AppColors.surfaceLight,
        error: AppColors.errorLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textLight,
        displayColor: AppColors.textLight,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundLight,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textLight),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.onPrimaryLight,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  // Dark Theme Data
  static ThemeData get darkTheme {
    final base = ThemeData.dark();
    return base.copyWith(
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryDark,
        onPrimary: AppColors.onPrimaryDark,
        primaryContainer: AppColors.primaryContainerDark,
        onPrimaryContainer: AppColors.onPrimaryContainerDark,
        background: AppColors.backgroundDark,
        surface: AppColors.surfaceDark,
        error: AppColors.errorDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _buildTextTheme(base.textTheme).apply(
        bodyColor: AppColors.textDark,
        displayColor: AppColors.textDark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: AppColors.onPrimaryDark,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}