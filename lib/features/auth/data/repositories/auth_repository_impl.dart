import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:alu_spark/core/services/firebase_auth_service.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/features/auth/domain/repositories/auth_repository.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    required this._authService,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges {
    return _authService.authStateChanges.map((firebase_auth.User? firebaseUser) {
      if (firebaseUser == null) return null;
      return _mapToUser(firebaseUser);
    });
  }

  @override
  User? get currentUser {
    final firebase_auth.User? firebaseUser = _authService.currentUser;
    return firebaseUser != null ? _mapToUser(firebaseUser) : null;
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
  }) async {
    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user!;

    // Create user document in Firestore
    final newUser = User(
      id: firebaseUser.uid,
      email: email,
      fullName: fullName,
      role: UserRole.student,
      isVerified: false,
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'id': newUser.id,
      'email': newUser.email,
      'fullName': newUser.fullName,
      'role': newUser.role.name,
      'createdAt': DateTime.now().toIso8601String(),
      'isEmailVerified': newUser.isVerified,
    });

    return newUser;
  }

  @override
  Future<User> signInWithEmail({
    required String email,
    required String password,
  }) async {
    await _authService.signInWithEmail(email: email, password: password);
    final firebaseUser = _authService.currentUser!;
    return _mapToUser(firebaseUser);
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Helper to map Firebase User to our App User entity
  User _mapToUser(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? 'User',
      role: UserRole.student,
      isVerified: firebaseUser.emailVerified,
    );
  }
}