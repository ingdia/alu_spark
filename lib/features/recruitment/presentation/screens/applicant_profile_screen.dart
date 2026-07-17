import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/applications/domain/entities/application.dart';
import 'package:alu_spark/features/applications/presentation/providers/application_provider.dart';
import 'package:alu_spark/features/student_profile/presentation/providers/student_profile_provider.dart';
import 'package:alu_spark/shared/enums/application_status.dart';

class ApplicantProfileScreen extends ConsumerStatefulWidget {
  final Application application;
  const ApplicantProfileScreen({super.key, required this.application});

  @override
  ConsumerState<ApplicantProfileScreen> createState() =>
      _ApplicantProfileScreenState();
}

class _ApplicantProfileScreenState
    extends ConsumerState<ApplicantProfileScreen> {
  // Interview form controllers
  final _timeController = TextEditingController();
  final _locationController = TextEditingController();
  final _linkController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _interviewDate;
  bool _saving = false;
  bool _interviewPrefilled = false;

  // Use the passed application only as the initial/fallback value.
  // The live stream (applicationByIdProvider) is the source of truth.
  Application get app => widget.application;

  @override
  void initState() {
    super.initState();
    _prefillInterview(app);
  }

  void _prefillInterview(Application a) {
    if (_interviewPrefilled) return;
    _interviewPrefilled = true;
    _timeController.text = a.interviewTime ?? '';
    _locationController.text = a.interviewLocation ?? '';
    _linkController.text = a.meetingLink ?? '';
    _notesController.text = a.interviewNotes ?? '';
    _interviewDate = a.interviewDate;
  }

  @override
  void dispose() {
    _timeController.dispose();
    _locationController.dispose();
    _linkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Color _statusColor(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.applied:
        return const Color(0xFF60A5FA);
      case ApplicationStatus.underReview:
        return const Color(0xFFFBBF24);
      case ApplicationStatus.interview:
        return AppColors.darkRedLight;
      case ApplicationStatus.accepted:
        return const Color(0xFF34D399);
      case ApplicationStatus.rejected:
      case ApplicationStatus.withdrawn:
        return AppColors.textSecondary;
    }
  }

  String _fmt(DateTime dt) {
    const m = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${m[dt.month]} ${dt.year}';
  }

  Future<void> _updateStatus(ApplicationStatus next) async {
    setState(() => _saving = true);
    try {
      await ref
          .read(applicationRepositoryProvider)
          .updateApplicationStatus(app.id, next);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Status updated to ${next.displayName}'),
          backgroundColor: _statusColor(next),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        // Don't pop — the stream will update the UI automatically.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}'),
              backgroundColor: AppColors.darkRed,
            ));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _saveInterview() async {
    setState(() => _saving = true);
    try {
      await ref
          .read(applicationRepositoryProvider)
          .updateApplicationWithInterview(
            applicationId: app.id,
            status: ApplicationStatus.interview,
            interviewDate: _interviewDate,
            interviewTime: _timeController.text.trim().isEmpty
                ? null
                : _timeController.text.trim(),
            interviewLocation: _locationController.text.trim().isEmpty
                ? null
                : _locationController.text.trim(),
            meetingLink: _linkController.text.trim().isEmpty
                ? null
                : _linkController.text.trim(),
            interviewNotes: _notesController.text.trim().isEmpty
                ? null
                : _notesController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: const Text('Interview details saved'),
          backgroundColor: AppColors.darkRed,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ));
        // Don't pop — the stream will update the UI automatically.
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final liveAppAsync = ref.watch(applicationByIdProvider(app.id));
    final liveApp = liveAppAsync.asData?.value ?? app;
    final studentAsync = ref.watch(studentProfileProvider(liveApp.studentId));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(12),
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
        title: Text('Applicant Profile',
            style:
                AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        centerTitle: true,
      ),
      body: liveAppAsync.when(
        loading: () => const LoadingWidget(message: 'Loading...'),
        error: (e, _) => ErrorStateWidget(message: e.toString()),
        data: (_) => studentAsync.when(
          loading: () => const LoadingWidget(message: 'Loading profile...'),
          error: (_, __) => _buildBody(context, liveApp, null),
          data: (student) => _buildBody(context, liveApp, student),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, Application liveApp, dynamic student) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(liveApp, student),
          const SizedBox(height: 20),
          if (student != null) ...[
            if ((student.bio as String).isNotEmpty) ...[
              _sectionLabel('About'),
              const SizedBox(height: 8),
              GlassmorphicContainer(
                blur: 10,
                borderRadius: 14,
                padding: const EdgeInsets.all(16),
                child: Text(student.bio as String,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary, height: 1.5)),
              ),
              const SizedBox(height: 20),
            ],
            if ((student.skills as List).isNotEmpty) ...[
              _sectionLabel('Skills'),
              const SizedBox(height: 8),
              _buildSkills(student.skills as List<String>),
              const SizedBox(height: 20),
            ],
            if ((student.education as List).isNotEmpty) ...[
              _sectionLabel('Education'),
              const SizedBox(height: 8),
              ...(student.education as List<Map<String, String>>)
                  .map(_buildEduExpCard),
              const SizedBox(height: 20),
            ],
            if ((student.experience as List).isNotEmpty) ...[
              _sectionLabel('Experience'),
              const SizedBox(height: 8),
              ...(student.experience as List<Map<String, String>>)
                  .map(_buildEduExpCard),
              const SizedBox(height: 20),
            ],
          ],
          _sectionLabel('Application Details'),
          const SizedBox(height: 8),
          _buildApplicationDetails(liveApp),
          const SizedBox(height: 20),
          _sectionLabel('Motivation Letter'),
          const SizedBox(height: 8),
          _buildMotivation(liveApp),
          if (liveApp.cvUrl.isNotEmpty) ...[
            const SizedBox(height: 20),
            _sectionLabel('CV / Resume'),
            const SizedBox(height: 8),
            _buildCvLink(liveApp),
          ],
          const SizedBox(height: 20),
          _sectionLabel('Update Status'),
          const SizedBox(height: 8),
          _buildStatusActions(liveApp),
          const SizedBox(height: 20),
          _sectionLabel('Schedule / Update Interview'),
          const SizedBox(height: 8),
          _buildInterviewForm(liveApp),
        ],
      ),
    );
  }

  Widget _buildHeader(Application liveApp, dynamic student) {
    final statusColor = _statusColor(liveApp.status);
    final initials = liveApp.studentName.isNotEmpty
        ? liveApp.studentName.trim().split(' ').map((w) => w[0]).take(2).join()
        : '?';
    final photoUrl = student?.profileImageUrl as String?;

    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: statusColor.withValues(alpha: 0.2),
            backgroundImage:
                (photoUrl != null && photoUrl.isNotEmpty)
                    ? NetworkImage(photoUrl)
                    : null,
            child: (photoUrl == null || photoUrl.isEmpty)
                ? Text(initials,
                    style: AppTextStyles.headingMedium
                        .copyWith(color: statusColor, fontSize: 18))
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(liveApp.studentName,
                    style: AppTextStyles.headingMedium
                        .copyWith(color: AppColors.white, fontSize: 18)),
                const SizedBox(height: 4),
                Text(liveApp.studentEmail,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary, fontSize: 12),
                    overflow: TextOverflow.ellipsis),
                if (student?.university != null &&
                    (student.university as String).isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(children: [
                    const Icon(Icons.school_outlined,
                        color: AppColors.textSecondary, size: 13),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(student.university as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary, fontSize: 12),
                          overflow: TextOverflow.ellipsis),
                    ),
                  ]),
                ],
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(liveApp.status.displayName,
                style: AppTextStyles.bodyMedium.copyWith(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildSkills(List<String> skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills
          .map((s) => Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppColors.darkRed.withValues(alpha: 0.3)),
                ),
                child: Text(s,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.white, fontSize: 12)),
              ))
          .toList(),
    );
  }

  Widget _buildEduExpCard(Map<String, String> entry) {
    final title = entry['degree'] ?? entry['role'] ?? entry['title'] ?? '';
    final subtitle =
        entry['institution'] ?? entry['company'] ?? entry['org'] ?? '';
    final period = entry['period'] ?? entry['year'] ?? '';
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 12,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.circle_outlined,
                  color: AppColors.darkRed, size: 16),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title.isNotEmpty)
                    Text(title,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.white, fontSize: 14)),
                  if (subtitle.isNotEmpty)
                    Text(subtitle,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary, fontSize: 12)),
                  if (period.isNotEmpty)
                    Text(period,
                        style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationDetails(Application liveApp) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _detailRow(Icons.work_outline, 'Role', liveApp.opportunityTitle),
          const SizedBox(height: 10),
          _detailRow(Icons.business_outlined, 'Startup', liveApp.startupName),
          const SizedBox(height: 10),
          _detailRow(Icons.calendar_today_outlined, 'Applied', _fmt(liveApp.createdAt)),
          const SizedBox(height: 10),
          _detailRow(Icons.update_outlined, 'Last Updated', _fmt(liveApp.updatedAt)),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 15),
        const SizedBox(width: 8),
        Text('$label: ',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary, fontSize: 12)),
        Expanded(
          child: Text(value,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white, fontSize: 12),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildMotivation(Application liveApp) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Text(
        liveApp.motivation.isNotEmpty
            ? liveApp.motivation
            : 'No motivation letter provided.',
        style: AppTextStyles.bodyMedium
            .copyWith(color: AppColors.textSecondary, height: 1.6),
      ),
    );
  }

  Widget _buildCvLink(Application liveApp) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined,
                color: AppColors.darkRed, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(liveApp.cvUrl,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.white, fontSize: 12),
                overflow: TextOverflow.ellipsis),
          ),
          const Icon(Icons.open_in_new,
              color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }

  Widget _buildStatusActions(Application liveApp) {
    final validNext = liveApp.status.validTransitions
        .where((s) => s != ApplicationStatus.withdrawn)
        .toList();

    if (validNext.isEmpty) {
      return GlassmorphicContainer(
        blur: 10,
        borderRadius: 14,
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.lock_outline,
                color: AppColors.textSecondary, size: 16),
            const SizedBox(width: 8),
            Text('No further status changes available.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.textSecondary)),
          ],
        ),
      );
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: validNext.map((next) {
        final color = _statusColor(next);
        return GestureDetector(
          onTap: _saving ? null : () => _updateStatus(next),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_saving)
                  const SizedBox(width: 14, height: 14,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white))
                else
                  Icon(_statusIcon(next), color: color, size: 16),
                const SizedBox(width: 6),
                Text('Mark ${next.displayName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: color, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  IconData _statusIcon(ApplicationStatus s) {
    switch (s) {
      case ApplicationStatus.underReview:
        return Icons.rate_review_outlined;
      case ApplicationStatus.interview:
        return Icons.event_outlined;
      case ApplicationStatus.accepted:
        return Icons.check_circle_outline;
      case ApplicationStatus.rejected:
        return Icons.cancel_outlined;
      default:
        return Icons.circle_outlined;
    }
  }

  Widget _buildInterviewForm(Application liveApp) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Date picker
          GestureDetector(
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _interviewDate ?? DateTime.now(),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (ctx, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.darkRed,
                      surface: AppColors.darkBlueLight,
                    ),
                  ),
                  child: child!,
                ),
              );
              if (picked != null) setState(() => _interviewDate = picked);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGlass),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today_outlined,
                      color: AppColors.textSecondary, size: 16),
                  const SizedBox(width: 10),
                  Text(
                    _interviewDate != null
                        ? _fmt(_interviewDate!)
                        : 'Select interview date',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: _interviewDate != null
                          ? AppColors.white
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          _formField(_timeController, 'Time (e.g. 10:00 AM)',
              Icons.access_time_outlined),
          const SizedBox(height: 10),
          _formField(_locationController, 'Location / Room',
              Icons.location_on_outlined),
          const SizedBox(height: 10),
          _formField(
              _linkController, 'Meeting Link', Icons.videocam_outlined),
          const SizedBox(height: 10),
          _formField(_notesController, 'Recruiter Notes',
              Icons.notes_outlined,
              maxLines: 3),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _saving ? null : _saveInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkRed,
                disabledBackgroundColor:
                    AppColors.darkRed.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2))
                  : Text(
                      liveApp.status == ApplicationStatus.interview
                          ? 'Update Interview'
                          : 'Schedule Interview',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _formField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
        filled: true,
        fillColor: AppColors.glassWhite,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGlass),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.borderGlass),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.darkRed),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(label,
        style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
            letterSpacing: 0.5));
  }
}
