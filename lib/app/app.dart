import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/auth/presentation/screens/register_screen.dart'; // Import Register

class ALUSparkApp extends StatelessWidget {
  const ALUSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Spark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const RegisterScreen(), // Temporarily set to RegisterScreen
    );
  }
  
}