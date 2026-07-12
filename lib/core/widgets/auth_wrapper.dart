import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/auth/presentation/screens/login_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/splash_screen.dart';
import 'package:alu_spark/features/home/presentation/screens/home_shell.dart';

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the auth state stream we created in firebase_providers.dart
    final authState = ref.watch(authStateProvider);

    // Use .when() to handle the 3 states of an AsyncValue (loading, data, error)
    return authState.when(
      // 1. Loading: Firebase is checking if a user is already logged in
      loading: () => const SplashScreen(), 
      
      // 2. Data: Firebase has returned the auth state
      data: (user) {
        if (user != null) {
          // User is logged in -> Show Home
          return const HomeShell();
        } else {
          // User is NOT logged in -> Show Login
          return const LoginScreen();
        }
      },
      
      // 3. Error: Something went wrong with Firebase
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}