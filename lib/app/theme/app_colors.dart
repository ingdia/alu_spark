import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Core Palette
  static const Color darkBlue = Color(0xFF0B132B);
  static const Color darkBlueLight = Color(0xFF1C2541);
  static const Color darkRed = Color(0xFF9A031E);
  static const Color darkRedLight = Color(0xFFB91C1C);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8F9FA);

  // Glassmorphism & Surfaces
  static const Color glassWhite = Color(0x1AFFFFFF); // 10% opacity
  static const Color borderGlass = Color(0x33FFFFFF); // 20% opacity

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);

  // Gradients
  static const LinearGradient backgroundGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkBlue, darkBlueLight],
  );

  static const LinearGradient redGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkRed, darkRedLight],
  );
}