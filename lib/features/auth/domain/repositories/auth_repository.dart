import 'package:alu_spark/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  // Stream to listen to auth state changes (logged in or logged out)
  Stream<User?> get authStateChanges;
  
  // Get the currently logged-in user
  User? get currentUser;
  
  // Sign up with email and password
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  });
  
  // Sign in with email and password
  Future<User> signInWithEmail({
    required String email,
    required String password,
  });
  
  // Sign out
  Future<void> signOut();
}