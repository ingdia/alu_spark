import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/student_profile/domain/entities/student.dart';

final studentProfileProvider = FutureProvider.family<Student?, String>((ref, uid) async {
  return ref.watch(studentRepositoryProvider).getStudent(uid);
});
