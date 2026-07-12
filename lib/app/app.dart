import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_theme.dart';
import 'package:alu_spark/core/widgets/auth_wrapper.dart';

class ALUSparkApp extends StatelessWidget {
  const ALUSparkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: 'ALU Spark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        
        // CHANGE 1: Use AuthWrapper as the home widget
        home: const AuthWrapper(),
        
        // CHANGE 2: Keep the router for internal navigation
        onGenerateRoute: AppRouter.generateRoute,
      ),
    );
  }
}