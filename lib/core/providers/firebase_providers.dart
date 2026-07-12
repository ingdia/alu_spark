import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/services/firebase_auth_service.dart';
import 'package:alu_spark/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:alu_spark/features/auth/domain/repositories/auth_repository.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';

// 1. Provide the Firebase Auth Service
final firebaseAuthServiceProvider = Provider<FirebaseAuthService>((ref) {
  return FirebaseAuthService();
});

// 2. Provide the Auth Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    authService: ref.watch(firebaseAuthServiceProvider),
  );
});

// 3. Provide the Auth State Stream (to know if user is logged in)
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});