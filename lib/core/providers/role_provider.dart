import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class RoleNotifier extends Notifier<UserRole> {
  @override
  UserRole build() => UserRole.student;

  void setRole(UserRole role) => state = role;
}

final roleProvider = NotifierProvider<RoleNotifier, UserRole>(RoleNotifier.new);
