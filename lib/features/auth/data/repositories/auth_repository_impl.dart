import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:alu_spark/core/services/firebase_auth_service.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/features/auth/domain/repositories/auth_repository.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  static const String _adminEmail = 'ngabirediane02@gmail.com';

  AuthRepositoryImpl({
    required this._authService,
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

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
    return _fetchUser(firebaseUser);
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
    required String proofFilePath,
    required String proofFileName,
  }) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    final ext = proofFileName.split('.').last;
    final storageRef = _storage.ref('startup_proofs/$uid/proof.$ext');
    await storageRef.putFile(File(proofFilePath));
    final proofUrl = await storageRef.getDownloadURL();

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
      'proofDocumentUrl': proofUrl,
      'proofFileName': proofFileName,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
      'adminEmail': _adminEmail,
    });

    await _firestore.collection('users').doc(uid).update({
      'startupProfileStatus': 'pending',
      'startupName': startupName,
    });

    await _firestore.collection('admin_notifications').add({
      'type': 'startup_review',
      'startupId': uid,
      'startupName': startupName,
      'submittedBy': _authService.currentUser?.email ?? '',
      'proofDocumentUrl': proofUrl,
      'adminEmail': _adminEmail,
      'status': 'unread',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  // Fetch full user with role from Firestore
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
    // Fallback if Firestore doc missing
    return _mapToUserBasic(firebaseUser);
  }

  UserRole _resolveRole(String email, {bool isStartup = false}) {
    if (email.trim().toLowerCase() == _adminEmail.toLowerCase()) return UserRole.admin;
    if (isStartup) return UserRole.founder;
    return UserRole.student;
  }

  // Basic mapping without Firestore (used only as fallback)
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
