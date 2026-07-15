import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/services/cloudinary_service.dart';
import 'package:alu_spark/core/services/notification_service.dart';
import 'package:alu_spark/core/constants/cloudinary_config.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

// ---------------------------------------------------------------------------
// Provider: checks whether the current user already applied to this opportunity
// ---------------------------------------------------------------------------
final _hasAppliedProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, opportunityId) async {
  final uid = fb.FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return false;
  return ref
      .read(applicationRepositoryProvider)
      .hasApplied(uid, opportunityId);
});

class ApplyOpportunityScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;
  const ApplyOpportunityScreen({super.key, required this.opportunity});

  @override
  ConsumerState<ApplyOpportunityScreen> createState() => _ApplyOpportunityScreenState();
}

class _ApplyOpportunityScreenState extends ConsumerState<ApplyOpportunityScreen> {
  final PageController _pageController = PageController();
  final _motivationController = TextEditingController();
  int _currentStep = 0;
  PlatformFile? _pickedCv;
  bool _isSubmitting = false;

  static const _steps = ['Motivation', 'Resume / CV', 'Review'];

  @override
  void dispose() {
    _pageController.dispose();
    _motivationController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(step,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  bool _canProceed() {
    if (_currentStep == 0) return _motivationController.text.trim().isNotEmpty;
    return true;
  }

  Future<void> _pickCv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx'],
    );
    if (result != null) setState(() => _pickedCv = result.files.first);
  }

  Future<void> _handleSubmit() async {
    setState(() => _isSubmitting = true);
    try {
      final currentUser = fb.FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception('Not logged in');

      // Second-line guard: re-check on the server before writing.
      final alreadyApplied = await ref
          .read(applicationRepositoryProvider)
          .hasApplied(currentUser.uid, widget.opportunity.id);
      if (alreadyApplied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have already applied to this opportunity.'),
              backgroundColor: AppColors.darkRed,
            ),
          );
        }
        return;
      }

      String cvUrl = '';
      if (_pickedCv != null) {
        Uint8List? bytes = _pickedCv!.bytes;
        if (bytes == null && _pickedCv!.path != null) {
          bytes = await File(_pickedCv!.path!).readAsBytes();
        }
        if (bytes != null) {
          final url = await CloudinaryService(
            cloudName: CloudinaryConfig.cloudName,
            uploadPreset: CloudinaryConfig.cvUploadPreset,
          ).uploadFile(
            bytes: bytes,
            fileName: _pickedCv!.name,
            folder: 'cvs',
            resourceType: 'raw',
          );
          cvUrl = url ?? '';
        }
      }

      final application = Application(
        id: '',
        opportunityId: widget.opportunity.id,
        opportunityTitle: widget.opportunity.title,
        startupId: widget.opportunity.startupId,
        startupName: widget.opportunity.startupName,
        studentId: currentUser.uid,
        studentName: currentUser.displayName ?? '',
        studentEmail: currentUser.email ?? '',
        motivation: _motivationController.text.trim(),
        cvUrl: cvUrl,
        status: ApplicationStatus.pending,
        createdAt: DateTime.now(),
      );

      await ref.read(applicationRepositoryProvider).submitApplication(application);
      await ref.read(opportunityRepositoryProvider).incrementApplicationCount(widget.opportunity.id);

      // Send notification to the startup founder
      await NotificationService().notifyNewApplication(
        startupId: widget.opportunity.startupId,
        studentName: currentUser.displayName ?? currentUser.email?.split('@').first ?? 'A student',
        opportunityTitle: widget.opportunity.title,
      );

      if (mounted) _showSuccessDialog();
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

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.darkBlueLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_outline, color: AppColors.darkRed, size: 48),
              ),
              const SizedBox(height: 20),
              Text('Application Submitted!',
                  style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              Text(
                'Your application for ${widget.opportunity.title} has been sent successfully.',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // close dialog
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      RouteNames.home,
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: Text('Go to Dashboard',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check for existing application before rendering the form.
    final hasAppliedAsync =
        ref.watch(_hasAppliedProvider(widget.opportunity.id));

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
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: AppColors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Apply',
            style:
                AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        centerTitle: true,
      ),
      body: hasAppliedAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.darkRed)),
        error: (_, __) => _buildForm(),
        data: (alreadyApplied) {
          if (alreadyApplied) return _buildAlreadyApplied();
          return _buildForm();
        },
      ),
    );
  }

  // ── Already-applied banner ──────────────────────────────────────────────
  Widget _buildAlreadyApplied() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: AppColors.darkRed, size: 56),
            ),
            const SizedBox(height: 24),
            Text(
              'Already Applied',
              style: AppTextStyles.headingMedium
                  .copyWith(color: AppColors.white, fontSize: 22),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'You have already submitted an application for ${widget.opportunity.title}. '  
              'Track its status in My Applications.',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, height: 1.5),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context)
                    .pushReplacementNamed(RouteNames.applicationTracking),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
                child: Text('View My Applications',
                    style: AppTextStyles.bodyLarge
                        .copyWith(color: AppColors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Main form (unchanged layout) ────────────────────────────────────────
  Widget _buildForm() {
    return Column(
      children: [
        _buildStepIndicator(),
        Expanded(
          child: PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(),
              _buildStep2(),
              _buildStep3(),
            ],
          ),
        ),
        _buildBottomNav(),
      ],
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Row(
        children: List.generate(_steps.length, (i) {
          final isActive = i == _currentStep;
          final isDone = i < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        height: 4,
                        decoration: BoxDecoration(
                          color: isDone || isActive ? AppColors.darkRed : AppColors.borderGlass,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _steps[i],
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: isActive ? AppColors.white : AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                if (i < _steps.length - 1) const SizedBox(width: 8),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Motivation ──────────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildOpportunityCard(),
          const SizedBox(height: 24),
          Text('Why are you a great fit?',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 6),
          Text(
            'Describe your motivation, relevant skills, and what you hope to contribute.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),
          GlassmorphicContainer(
            blur: 10,
            borderRadius: 16,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _motivationController,
              maxLines: 8,
              onChanged: (_) => setState(() {}),
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Tell the startup why you are a great fit...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${_motivationController.text.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 11, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Step 2: CV Upload (optional) ────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Upload your CV', style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 6),
          Text(
            'Optional — attach your resume to strengthen your application.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: _pickCv,
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.all(24),
              child: _pickedCv == null
                  ? Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.upload_file_outlined,
                              color: AppColors.darkRed, size: 36),
                        ),
                        const SizedBox(height: 16),
                        Text('Tap to upload CV',
                            style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                        const SizedBox(height: 6),
                        Text('PDF, DOC, DOCX — optional',
                            style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    )
                  : Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.darkRed.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.description_outlined,
                              color: AppColors.darkRed, size: 28),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_pickedCv!.name,
                                  style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                                  overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 4),
                              Text(
                                '${(_pickedCv!.size / 1024).toStringAsFixed(1)} KB',
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.textSecondary, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: AppColors.textSecondary, size: 20),
                          onPressed: () => setState(() => _pickedCv = null),
                        ),
                      ],
                    ),
            ),
          ),
          if (_pickedCv != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _pickCv,
              icon: const Icon(Icons.swap_horiz, color: AppColors.darkRed, size: 18),
              label: Text('Change file',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
            ),
          ],
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Step 3: Review ──────────────────────────────────────────────────────────
  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review your application',
              style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
          const SizedBox(height: 6),
          Text('Make sure everything looks good before submitting.',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 20),
          _buildOpportunityCard(),
          const SizedBox(height: 16),
          _buildReviewSection(
            icon: Icons.edit_note,
            label: 'Motivation Letter',
            content: _motivationController.text.trim(),
            onEdit: () => _goTo(0),
          ),
          const SizedBox(height: 12),
          _buildReviewSection(
            icon: Icons.description_outlined,
            label: 'Resume / CV',
            content: _pickedCv != null ? _pickedCv!.name : 'No CV attached (optional)',
            onEdit: () => _goTo(1),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReviewSection({
    required IconData icon,
    required String label,
    required String content,
    required VoidCallback onEdit,
  }) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.darkRed, size: 18),
              const SizedBox(width: 8),
              Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: Text('Edit',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.darkRed, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: AppColors.borderGlass, height: 1),
          const SizedBox(height: 10),
          Text(
            content.isEmpty ? '—' : content,
            style: AppTextStyles.bodyMedium.copyWith(
              color: content.isEmpty ? AppColors.textSecondary : AppColors.white,
              height: 1.5,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildOpportunityCard() {
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
            child: const Icon(Icons.work_outline, color: AppColors.darkRed, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.opportunity.title,
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                const SizedBox(height: 4),
                Text(widget.opportunity.startupName,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLast = _currentStep == _steps.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => _goTo(_currentStep - 1),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.borderGlass),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text('Back',
                    style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: (!_canProceed() || _isSubmitting)
                  ? null
                  : isLast
                      ? _handleSubmit
                      : () => _goTo(_currentStep + 1),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkRed,
                disabledBackgroundColor: AppColors.darkRed.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                    )
                  : Text(
                      isLast ? 'Submit Application' : 'Continue',
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
