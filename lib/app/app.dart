import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

// Import your HomeShell (adjust the path based on where you saved it)
import '../features/home/presentation/screens/home_shell.dart'; 

class ALUSparkApp extends StatelessWidget {
  const ALUSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Spark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeShell(), // Point to your awesome HomeShell!
    );
  }
}