import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplyOpportunityScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const ApplyOpportunityScreen({super.key, required this.opportunity});

  @override
  ConsumerState<ApplyOpportunityScreen> createState() =>
      _ApplyOpportunityScreenState();
}

class _ApplyOpportunityScreenState
    extends ConsumerState<ApplyOpportunityScreen> {
  final _motivationController = TextEditingController();
  final _cvController = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _motivationController.dispose();
    _cvController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final motivation = _motivationController.text.trim();
    if (motivation.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please write a motivation letter.'),
          backgroundColor: AppColors.darkRed,
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      if (fbUser == null) throw Exception('Not authenticated.');

      // Load student profile for name + email
      final student = await ref
          .read(studentRepositoryProvider)
          .getStudent(fbUser.uid);

      final now = DateTime.now();
      final application = Application(
        id: '${fbUser.uid}_${widget.opportunity.id}',
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        startupId: widget.opportunity.startupId,
        startupName: widget.opportunity.startupName,
        studentId: fbUser.uid,
        studentName: student?.fullName ?? fbUser.displayName ?? 'Student',
        studentEmail: student?.email ?? fbUser.email ?? '',
        motivation: motivation,
        cvUrl: _cvController.text.trim(),
        status: ApplicationStatus.applied,
        createdAt: now,
        updatedAt: now,
      );

      await ref
          .read(applicationRepositoryProvider)
          .submitApplication(application);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Application submitted successfully!'),
            backgroundColor: Color(0xFF22C55E),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.darkRed,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOpportunitySummary(),
            const SizedBox(height: 24),
            _buildSectionTitle('Your Motivation'),
            const SizedBox(height: 12),
            _buildMotivationField(),
            const SizedBox(height: 24),
            _buildSectionTitle('CV / Resume Link'),
            const SizedBox(height: 12),
            _buildCvField(),
            const SizedBox(height: 32),
            _buildSubmitButton(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: const EdgeInsets.all(0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        'Apply',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildOpportunitySummary() {
    return GlassmorphicContainer(
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
            child: const Icon(Icons.work_outline,
                color: AppColors.darkRed, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.opportunity.title,
                  style:
                      AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.opportunity.startupName,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildMotivationField() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _motivationController,
        maxLines: 6,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText:
              'Tell the startup why you are a great fit for this role...',
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildCvField() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: TextField(
        controller: _cvController,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Paste a link to your CV (Google Drive, Dropbox…)',
          hintStyle: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.textSecondary),
          prefixIcon:
              const Icon(Icons.link, color: AppColors.darkRed, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _submitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _submitting
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: AppColors.white, strokeWidth: 2),
              )
            : Text(
                'Submit Application',
                style:
                    AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
      ),
    );
  }
}
