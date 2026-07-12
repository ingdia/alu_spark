import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/features/admin_user_management/domain/repositories/user_repository.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'users';

  UserRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<User>> getAllUsers() {
    return _firestore
        .collection(_collectionPath)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          fullName: data['fullName'] ?? 'Unknown',
          role: UserRole.values.firstWhere(
            (e) => e.name == data['role'],
            orElse: () => UserRole.student,
          ),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isEmailVerified: data['isEmailVerified'] ?? false,
        );
      }).toList();
    });
  }

  @override
  Stream<List<User>> getUsersByRole(String role) {
    return _firestore
        .collection(_collectionPath)
        .where('role', isEqualTo: role)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return User(
          id: doc.id,
          email: data['email'] ?? '',
          fullName: data['fullName'] ?? 'Unknown',
          role: UserRole.values.firstWhere(
            (e) => e.name == data['role'],
            orElse: () => UserRole.student,
          ),
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          isEmailVerified: data['isEmailVerified'] ?? false,
        );
      }).toList();
    });
  }

  @override
  Future<void> updateUserRole(String userId, String role) async {
    await _firestore.collection(_collectionPath).doc(userId).update({'role': role});
  }

  @override
  Future<void> updateUserStatus(String userId, bool isActive) async {
    await _firestore.collection(_collectionPath).doc(userId).update({'isActive': isActive});
  }
}
