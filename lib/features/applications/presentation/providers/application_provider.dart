import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';

final applicationsByStudentProvider =
    StreamProvider.family<List<Application>, String>((ref, studentId) {
  return ref
      .watch(applicationRepositoryProvider)
      .getApplicationsByStudent(studentId);
});

final applicationsByStartupProvider =
    StreamProvider.family<List<Application>, String>((ref, startupId) {
  return ref
      .watch(applicationRepositoryProvider)
      .getApplicationsByStartup(startupId);
});
