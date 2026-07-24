import 'package:flutter_test/flutter_test.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/auth_wrapper.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

void main() {
  group('resolvePostLoginDestination', () {
    test('sends students straight to home', () {
      final destination = resolvePostLoginDestination(
        role: UserRole.student,
        profileComplete: false,
        startupStatus: null,
      );

      expect(destination, RouteNames.home);
    });

    test('sends incomplete founders to role selection', () {
      final destination = resolvePostLoginDestination(
        role: UserRole.founder,
        profileComplete: false,
        startupStatus: null,
      );

      expect(destination, RouteNames.roleSelection);
    });

    test('sends pending founders to startup pending', () {
      final destination = resolvePostLoginDestination(
        role: UserRole.founder,
        profileComplete: true,
        startupStatus: 'pending',
      );

      expect(destination, RouteNames.startupPending);
    });

    test('sends complete founders to home', () {
      final destination = resolvePostLoginDestination(
        role: UserRole.founder,
        profileComplete: true,
        startupStatus: 'approved',
      );

      expect(destination, RouteNames.home);
    });
  });
}
