import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/features/opportunities/data/repositories/opportunity_repository_impl.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';
import 'package:alu_spark/features/applications/data/repositories/application_repository_impl.dart';
import 'package:alu_spark/features/applications/domain/repositories/application_repository.dart';

// Opportunity Repository
final opportunityRepositoryProvider = Provider<OpportunityRepository>((ref) {
  return OpportunityRepositoryImpl();
});

// Application Repository
final applicationRepositoryProvider = Provider<ApplicationRepository>((ref) {
  return ApplicationRepositoryImpl();
});