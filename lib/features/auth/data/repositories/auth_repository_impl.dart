import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:alu_spark/core/services/firebase_auth_service.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/features/auth/domain/repositories/auth_repository.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;

  static const String _adminEmail = 'ngabirediane02@gmail.com';

  AuthRepositoryImpl({
    required this._authService,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<User?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebase_auth.User? firebaseUser) async {
      if (firebaseUser == null) return null;
      return _fetchUser(firebaseUser);
    });
  }

  @override
  User? get currentUser {
    final firebase_auth.User? firebaseUser = _authService.currentUser;
    return firebaseUser != null ? _mapToUserBasic(firebaseUser) : null;
  }

  @override
  Future<User> signUpWithEmail({
    required String email,
    required String password,
    required String fullName,
    bool isStartup = false,
  }) async {
    final credential = await _authService.signUpWithEmail(
      email: email,
      password: password,
    );

    final firebaseUser = credential.user!;
    final role = _resolveRole(email, isStartup: isStartup);

    final newUser = User(
      id: firebaseUser.uid,
      email: email,
      fullName: fullName,
      role: role,
      createdAt: DateTime.now(),
      isEmailVerified: false,
    );

    await _firestore.collection('users').doc(firebaseUser.uid).set({
      'id': newUser.id,
      'email': newUser.email,
      'fullName': newUser.fullName,
      'role': newUser.role.name,
      'createdAt': FieldValue.serverTimestamp(),
      'isEmailVerified': false,
      'isApproved': isStartup ? false : true,
      'profileComplete': false,
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
    await firebaseUser.reload();
    final refreshed = firebase_auth.FirebaseAuth.instance.currentUser!;
    final isAdmin = refreshed.email?.trim().toLowerCase() == _adminEmail.toLowerCase();
    if (!isAdmin && !refreshed.emailVerified) {
      await _authService.signOut();
      throw Exception('Please verify your email before logging in.');
    }
    await refreshed.getIdToken(true);
    return _fetchUser(refreshed);
  }

  @override
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
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    debugPrint('submitStartupProfile: uid=$uid');

    await _authService.currentUser?.getIdToken(true);
    debugPrint('submitStartupProfile: token refreshed, writing to Firestore');

    await _firestore.collection('startups').doc(uid).set({
      'uid': uid,
      'startupName': startupName,
      'tagline': tagline,
      'website': website,
      'linkedin': linkedin,
      'industry': industry,
      'stage': stage,
      'teamSize': teamSize,
      'founders': founders,
      'description': description,
      'proofFileName': proofFileName,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'adminEmail': _adminEmail,
    });

    debugPrint('submitStartupProfile: startups doc written');

    await _firestore.collection('users').doc(uid).update({
      'startupProfileStatus': 'pending',
      'startupName': startupName,
      'profileComplete': true,
    });

    debugPrint('submitStartupProfile: users doc updated');

    await _firestore.collection('admin_notifications').add({
      'type': 'startup_review',
      'startupId': uid,
      'startupName': startupName,
      'submittedBy': _authService.currentUser?.email ?? '',
      'proofFileName': proofFileName,
      'adminEmail': _adminEmail,
      'status': 'unread',
      'createdAt': FieldValue.serverTimestamp(),
    });

    debugPrint('submitStartupProfile: admin_notification written — DONE');
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<User> _fetchUser(firebase_auth.User firebaseUser) async {
    try {
      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final roleStr = data['role'] as String? ?? 'student';
        final role = UserRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => _resolveRole(firebaseUser.email ?? ''),
        );
        return User(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          fullName: data['fullName'] as String? ?? firebaseUser.displayName ?? 'User',
          role: role,
          createdAt: DateTime.now(),
          isEmailVerified: firebaseUser.emailVerified,
        );
      }
    } catch (_) {}
    return _mapToUserBasic(firebaseUser);
  }

  UserRole _resolveRole(String email, {bool isStartup = false}) {
    if (email.trim().toLowerCase() == _adminEmail.toLowerCase()) return UserRole.admin;
    if (isStartup) return UserRole.founder;
    return UserRole.student;
  }

  User _mapToUserBasic(firebase_auth.User firebaseUser) {
    return User(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      fullName: firebaseUser.displayName ?? 'User',
      role: _resolveRole(firebaseUser.email ?? ''),
      createdAt: DateTime.now(),
      isEmailVerified: firebaseUser.emailVerified,
    );
  }
}
