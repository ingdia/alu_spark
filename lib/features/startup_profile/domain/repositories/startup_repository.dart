import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';

abstract class StartupRepository {
  Stream<Startup?> getStartupById(String startupId);
  Future<void> createStartup(Startup startup);
  Future<void> updateStartup(Startup startup);
}
