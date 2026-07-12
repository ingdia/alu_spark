import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/auth/presentation/screens/login_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/splash_screen.dart';
import 'package:alu_spark/features/home/presentation/screens/home_shell.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _showingSplash = true;

  @override
  void initState() {
    super.initState();
    // Always show splash for at least 2.5 seconds
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) setState(() => _showingSplash = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showingSplash) return const SplashScreen();

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const SplashScreen(),
      data: (user) => user != null ? const HomeShell() : const LoginScreen(),
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}