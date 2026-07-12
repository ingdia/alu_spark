import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/features/opportunities/data/repositories/opportunity_repository_impl.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';
import 'package:alu_spark/features/applications/data/repositories/application_repository_impl.dart';
import 'package:alu_spark/features/applications/domain/repositories/application_repository.dart';
import 'package:alu_spark/features/startup_profile/data/repositories/startup_repository_impl.dart';
import 'package:alu_spark/features/startup_profile/domain/repositories/startup_repository.dart';

// Opportunity Repository
final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepositoryImpl();
});

// Application Repository
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl();
});

// Startup Repository
final startupRepositoryProvider = Provider<StartupRepository>((ref) {
  return StartupRepositoryImpl();
});
