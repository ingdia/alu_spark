import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBlue,
      primaryColor: AppColors.darkRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.darkRed,
        secondary: AppColors.darkBlueLight,
        surface: AppColors.darkBlueLight,
        background: AppColors.darkBlue,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent, elevation: 0, centerTitle: true,
        iconTheme: IconThemeData(color: AppColors.white),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.darkRed, foregroundColor: AppColors.white, elevation: 8,
      ),
    );
  }
}