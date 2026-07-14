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
    String? proofFilePath,
    List<int>? proofFileBytes,
    required String proofFileName,
  });

  Future<void> signOut();
}
