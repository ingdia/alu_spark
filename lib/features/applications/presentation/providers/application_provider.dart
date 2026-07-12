import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';

// Stream provider to fetch applications by student ID
final applicationsByStudentProvider = StreamProvider.family<List<Application>, String>((ref, studentId) {
  final repository = ref.watch(applicationRepositoryProvider);
  return repository.getApplicationsByStudent(studentId);
});