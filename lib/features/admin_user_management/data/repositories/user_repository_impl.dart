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
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) {
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
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
    });
  }

  @override
  Stream<List<User>> getUsersByRole(String role) {
    return _firestore
        .collection(_collectionPath)
        .where('role', isEqualTo: role)
        .snapshots()
        .map((snapshot) {
      final users = snapshot.docs.map((doc) {
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
      users.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return users;
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
