import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/screens/login_screen.dart';

class ALUSparkApp extends StatelessWidget {
  const ALUSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Spark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Make sure to use your darkTheme here!
      home: const LoginScreen(), // Temporarily set to LoginScreen
    );
  }
}