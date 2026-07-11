import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../features/home/presentation/screens/home_shell.dart';

class AluSparkApp extends StatelessWidget {
  const AluSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Spark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const HomeShell(),
    );
  }
}