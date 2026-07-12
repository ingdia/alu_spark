import 'package:alu_spark/features/auth/domain/entities/user.dart';

abstract class UserRepository {
  Stream<List<User>> getAllUsers();
  Stream<List<User>> getUsersByRole(String role);
  Future<void> updateUserRole(String userId, String role);
  Future<void> updateUserStatus(String userId, bool isActive);
}
