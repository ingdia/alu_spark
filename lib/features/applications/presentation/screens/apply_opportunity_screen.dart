import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplyOpportunityScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const ApplyOpportunityScreen({super.key, required this.opportunity});

  @override
  ConsumerState<ApplyOpportunityScreen> createState() => _ApplyOpportunityScreenState();
}

class _ApplyOpportunityScreenState extends ConsumerState<ApplyOpportunityScreen> {
  final _motivationController = TextEditingController();
  final String _selectedCv = 'Alex_Johnson_CV_2025.pdf';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _motivationController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (_motivationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write a motivation letter.')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      const studentId = 'dummy_student_id_123';
      const studentName = 'Alex Johnson';
      const studentEmail = 'alex.johnson@alu.edu';

      final application = Application(
        id: '',
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        startupId: widget.opportunity.startupId,
        startupName: widget.opportunity.startupName,
        studentId: studentId,
        studentName: studentName,
        studentEmail: studentEmail,
        motivation: _motivationController.text.trim(),
        cvUrl: 'https://res.cloudinary.com/dummy/cv.pdf',
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref.read(applicationRepositoryProvider).submitApplication(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: AppColors.darkRed,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to submit: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Apply',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.work_outline, color: AppColors.darkRed, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.opportunity.title,
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.opportunity.startupName,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your Motivation',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 12),
            GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _motivationController,
                maxLines: 6,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Tell the startup why you are a great fit...',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Resume / CV',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
            ),
            const SizedBox(height: 12),
            GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.darkRed.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.description_outlined, color: AppColors.darkRed, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Selected CV',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedCv,
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Change',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _handleSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: AppColors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        'Submit Application',
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
