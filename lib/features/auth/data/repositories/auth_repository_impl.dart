import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:alu_spark/core/constants/app_constants.dart';
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
    // Guard: only ALU emails may register (defence-in-depth after client validation)
    final isAdmin = AppConstants.isAdminEmail(email);
    if (!isAdmin && !AppConstants.isAluEmail(email)) {
      throw Exception('Only verified ALU email addresses can register.');
    }

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
    final isAdmin = AppConstants.isAdminEmail(refreshed.email ?? '');
    if (!isAdmin && !refreshed.emailVerified) {
      await _authService.signOut();
      throw Exception('Please verify your email before logging in.');
    }
    await refreshed.getIdToken(true);

    // Ensure the admin's /users doc exists so isAdmin() in Firestore rules
    // can resolve callerRole() == 'admin'. The doc is created on first login
    // because the admin never goes through signUpWithEmail.
    if (isAdmin) {
      final docRef = _firestore.collection('users').doc(refreshed.uid);
      final snap = await docRef.get();
      if (!snap.exists) {
        await docRef.set({
          'id': refreshed.uid,
          'email': refreshed.email ?? email,
          'fullName': refreshed.displayName ?? 'Admin',
          'role': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'isEmailVerified': true,
          'isApproved': true,
          'profileComplete': true,
        });
      }
    }

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
    required String proofDocumentUrl,
  }) async {
    if (founders.length < 2) {
      throw Exception('A startup must have at least two founders before it can be submitted.');
    }
    final trimmedUrl = proofDocumentUrl.trim();
    if (trimmedUrl.isEmpty) {
      throw Exception('A verification document link is required.');
    }
    if (!AppConstants.isValidUrl(trimmedUrl)) {
      throw Exception('Please enter a valid URL (must start with https://).');
    }
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');

    // Reload the Firebase Auth user so email_verified is current,
    // then force-refresh the ID token so the Firestore rules see
    // email_verified == true in request.auth.token.
    await _authService.currentUser?.reload();
    final refreshedUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (refreshedUser == null) throw Exception('User not authenticated');
    if (!refreshedUser.emailVerified) {
      throw Exception('Please verify your email before submitting your startup profile.');
    }
    await refreshedUser.getIdToken(true);

    final batch = _firestore.batch();

    batch.set(_firestore.collection('startups').doc(uid), {
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
      'proofDocumentUrl': trimmedUrl,
      'status': 'pending',
      'submittedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('users').doc(uid), {
      'startupProfileStatus': 'pending',
      'startupName': startupName,
      'profileComplete': true,
    });

    final adminNotifRef = _firestore.collection('admin_notifications').doc();
    batch.set(adminNotifRef, {
      'type': 'startup_review',
      'startupId': uid,
      'startupName': startupName,
      'submittedBy': refreshedUser.email ?? '',
      'proofDocumentUrl': trimmedUrl,
      'status': 'unread',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  @override
  Stream<Map<String, dynamic>?> getUserDataStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  @override
  Future<void> markEmailVerified() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'isEmailVerified': true,
    });
  }

  @override
  Future<void> setUserRole(String role) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    await _firestore.collection('users').doc(uid).update({
      'role': role,
      if (role == 'founder') 'profileComplete': false,
    });
  }

  @override
  Future<void> completeStudentProfile() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) throw Exception('User not authenticated');
    final displayName = _authService.currentUser?.displayName ?? '';
    await _firestore.collection('users').doc(uid).update({
      'profileComplete': true,
      'fullName': displayName,
    });
  }

  @override
  Future<void> signOut() async {
    await _authService.signOut();
  }

  Future<User> _fetchUser(firebase_auth.User firebaseUser) async {
    // authStateChanges emits a user carrying a CACHED token; its emailVerified
    // flag does not update when the email is verified later. Reload so the flag
    // reflects the current state — otherwise a verified user can get trapped on
    // the loading screen (AuthWrapper gates on isEmailVerified).
    var authUser = firebaseUser;
    try {
      await authUser.reload();
      authUser = _authService.currentUser ?? authUser;
    } catch (_) {}

    try {
      final doc = await _firestore.collection('users').doc(authUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        final roleStr = data['role'] as String? ?? 'student';
        final role = UserRole.values.firstWhere(
          (r) => r.name == roleStr,
          orElse: () => _resolveRole(authUser.email ?? ''),
        );
        return User(
          id: authUser.uid,
          email: authUser.email ?? '',
          fullName: data['fullName'] as String? ?? authUser.displayName ?? 'User',
          role: role,
          createdAt: DateTime.now(),
          isEmailVerified: authUser.emailVerified,
        );
      }
    } catch (_) {}
    return _mapToUserBasic(authUser);
  }

  UserRole _resolveRole(String email, {bool isStartup = false}) {
    if (AppConstants.isAdminEmail(email)) return UserRole.admin;
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
