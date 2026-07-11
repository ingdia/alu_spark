import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'theme/app_colors.dart';
import 'theme/app_text_styles.dart';

class AluSparkApp extends StatelessWidget {
  const AluSparkApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ALU Spark',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('ALU Spark', style: AppTextStyles.heading1),
              const SizedBox(height: 16),
              Text('Core Foundation Initialized', style: AppTextStyles.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}