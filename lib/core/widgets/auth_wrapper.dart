import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/role_provider.dart';
import 'package:alu_spark/features/auth/presentation/screens/app_loading_screen.dart';
import 'package:alu_spark/features/auth/presentation/screens/splash_screen.dart';
import 'package:alu_spark/features/home/presentation/screens/home_shell.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 5000), () {
      if (mounted) setState(() => _loading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const AppLoadingScreen();

    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () => const AppLoadingScreen(),
      data: (user) {
        if (user == null) return const SplashScreen();

        // Sync the real role from Firestore into roleProvider
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ref.read(roleProvider.notifier).setRole(user.role);
        });

        return const HomeShell();
      },
      error: (error, stack) => Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
        ),
      ),
    );
  }
}
