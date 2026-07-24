import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/role_provider.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class RoleSelectionScreen extends ConsumerStatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  ConsumerState<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends ConsumerState<RoleSelectionScreen> {
  String? _selected; // 'student' or 'founder'
  bool _isLoading = false;

  Future<void> _continue() async {
    if (_selected == null) return;
    setState(() => _isLoading = true);

    try {
      // Delegate the Firestore role write to the repository.
      await ref.read(authRepositoryProvider).setUserRole(_selected!);

      if (_selected == 'student') {
        if (mounted) {
          ref.read(roleProvider.notifier).setRole(UserRole.student);
          Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.studentOnboarding, (_) => false);
        }
      } else {
        if (mounted) {
          ref.read(roleProvider.notifier).setRole(UserRole.founder);
          Navigator.of(context).pushNamedAndRemoveUntil(
            RouteNames.startupOnboarding,
            (_) => false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              Text('Who are you?', style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
              const SizedBox(height: 8),
              Text(
                'Choose your role on ALU Spark',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 48),
              _RoleCard(
                selected: _selected == 'student',
                icon: Icons.school_outlined,
                title: 'Student',
                description: 'I am looking for internship opportunities at ALU startups.',
                onTap: () => setState(() => _selected = 'student'),
              ),
              const SizedBox(height: 16),
              _RoleCard(
                selected: _selected == 'founder',
                icon: Icons.rocket_launch_outlined,
                title: 'Startup / Founder',
                description: 'I run a startup and want to post opportunities and find talent.',
                onTap: () => setState(() => _selected = 'founder'),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: (_selected == null || _isLoading) ? null : _continue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    disabledBackgroundColor: AppColors.glassWhite,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22, height: 22,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text(
                          'Continue',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final bool selected;
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _RoleCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.darkRed : AppColors.borderGlass,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? AppColors.darkRed.withValues(alpha: 0.1)
              : AppColors.glassWhite,
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.darkRed.withValues(alpha: 0.2)
                    : AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: selected ? AppColors.darkRed : AppColors.textSecondary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.darkRed : AppColors.borderGlass,
            ),
          ],
        ),
      ),
    );
  }
}
