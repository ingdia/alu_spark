import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';

abstract class StartupRepository {
  Stream<Startup?> getStartupById(String startupId);
  Stream<List<Startup>> getUnverifiedStartups();
  Future<void> createStartup(Startup startup);
  Future<void> updateStartup(Startup startup);
  Future<void> verifyStartup(String startupId, bool isVerified);
  Future<void> updateLogoUrl(String startupId, String? logoUrl);
}
