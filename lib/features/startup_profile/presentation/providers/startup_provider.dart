import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';

final startupDetailProvider = StreamProvider.family<Startup?, String>((ref, startupId) {
  final repository = ref.watch(startupRepositoryProvider);
  return repository.getStartupById(startupId);
});

final unverifiedStartupsProvider = StreamProvider<List<Startup>>((ref) {
  final repository = ref.watch(startupRepositoryProvider);
  return repository.getUnverifiedStartups();
});
