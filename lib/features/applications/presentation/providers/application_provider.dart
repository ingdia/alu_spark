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

final applicationByIdProvider =
    StreamProvider.autoDispose.family<Application?, String>((ref, id) {
  return ref
      .watch(applicationRepositoryProvider)
      .getApplicationById(id);
});

/// Watches the single application a student has for a specific opportunity.
/// Emits null when no application exists.
final applicationForOpportunityProvider = StreamProvider.autoDispose
    .family<Application?, ({String studentId, String opportunityId})>(
        (ref, args) {
  return ref
      .watch(applicationRepositoryProvider)
      .getApplicationForOpportunity(args.studentId, args.opportunityId);
});
