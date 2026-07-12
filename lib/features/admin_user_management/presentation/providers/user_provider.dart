import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';

final usersProvider = StreamProvider<List<User>>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getAllUsers();
});

final usersByRoleProvider = StreamProvider.family<List<User>, String>((ref, role) {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUsersByRole(role);
});
