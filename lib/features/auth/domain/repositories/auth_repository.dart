import 'package:alu_spark/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  User? get currentUser;

  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    bool isStartup = false,
  });

  Future<User> signInWithEmail({
    required String email,
    required String password,
  });

  Future<void> submitStartupProfile({
    required String startupName,
    required String tagline,
    required String website,
    required String linkedin,
    required String industry,
    required String stage,
    required String teamSize,
    required List<Map<String, String>> founders,
    required String description,
    required String proofDocumentUrl,
  });

  /// Called after email verification is confirmed — marks the user doc.
  Future<void> markEmailVerified();

  /// Streams the raw user document map for routing decisions.
  Stream<Map<String, dynamic>?> getUserDataStream(String uid);

  /// Called from role selection — persists the chosen role to the user doc.
  Future<void> setUserRole(String role);

  /// Called after student onboarding — marks the profile as complete.
  Future<void> completeStudentProfile();

  Future<void> signOut();
}
