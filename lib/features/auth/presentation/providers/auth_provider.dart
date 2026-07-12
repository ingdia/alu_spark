import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_state.dart';

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(authRepositoryProvider).signInWithEmail(
            email: email,
            password: password,
          );
      state = state.copyWith(status: AuthStatus.success, successMessage: 'Login successful!');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String fullName,
    bool isStartup = false,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(authRepositoryProvider).signUpWithEmail(
            email: email,
            password: password,
            fullName: fullName,
            isStartup: isStartup,
          );
      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: 'Account created successfully!',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> registerStartup({
    required String startupName,
    required String tagline,
    required String website,
    required String linkedin,
    required String industry,
    required String stage,
    required String teamSize,
    required List<Map<String, String>> founders,
    required String description,
    String? proofFilePath,
    List<int>? proofFileBytes,
    required String proofFileName,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(authRepositoryProvider).submitStartupProfile(
            startupName: startupName,
            tagline: tagline,
            website: website,
            linkedin: linkedin,
            industry: industry,
            stage: stage,
            teamSize: teamSize,
            founders: founders,
            description: description,
            proofFilePath: proofFilePath,
            proofFileBytes: proofFileBytes,
            proofFileName: proofFileName,
          );
      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: 'Startup profile submitted for review!',
      );
    } catch (e, st) {
      debugPrint('registerStartup ERROR: $e');
      debugPrint('STACKTRACE: $st');
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> forgotPassword({required String email}) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      await ref.read(firebaseAuthServiceProvider).sendPasswordResetEmail(email);
      state = state.copyWith(
        status: AuthStatus.success,
        successMessage: 'Password reset email sent to $email',
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void reset() => state = const AuthState();
}

final authNotifierProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
