import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';

class StartupPendingScreen extends ConsumerWidget {
  const StartupPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: uid != null
              ? FirebaseFirestore.instance.collection('users').doc(uid).snapshots()
              : const Stream.empty(),
          builder: (context, snapshot) {
            final data = snapshot.data?.data() as Map<String, dynamic>?;
            final status = data?['startupProfileStatus'] as String? ?? 'pending';

            // Auto-redirect to home when admin approves
            if (status == 'approved') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    RouteNames.home, (_) => false);
                }
              });
            }

            final isRejected = status == 'rejected';

            return Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      gradient: isRejected ? null : AppColors.redGradient,
                      color: isRejected ? AppColors.glassWhite : null,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isRejected ? [] : [
                        BoxShadow(
                          color: AppColors.darkRed.withValues(alpha: 0.4),
                          blurRadius: 28,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Icon(
                      isRejected ? Icons.cancel_outlined : Icons.hourglass_top_rounded,
                      color: isRejected ? AppColors.textSecondary : AppColors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    isRejected ? 'Application Rejected' : 'Under Review',
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 22),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isRejected
                        ? 'Your startup application was not approved. Please contact support or re-apply with updated documents.'
                        : 'Your startup profile has been submitted and is awaiting admin approval. This usually takes 24–48 hours.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: GestureDetector(
                      onTap: () async {
                        await ref.read(authRepositoryProvider).signOut();
                        if (context.mounted) {
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            RouteNames.login, (_) => false);
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.glassWhite,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppColors.borderGlass),
                        ),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
