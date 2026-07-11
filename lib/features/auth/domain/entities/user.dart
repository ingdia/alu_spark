import 'package:alu_spark/shared/enums/user_role.dart';

class User {
  final String id;
  final String fullName;
  final String email;
  final UserRole role;
  final bool isVerified;

  const User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.isVerified = false,
  });
}
