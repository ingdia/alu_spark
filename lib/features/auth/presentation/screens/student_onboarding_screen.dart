import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/role_provider.dart';
import 'package:alu_spark/features/student_profile/domain/entities/student.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class StudentOnboardingScreen extends ConsumerStatefulWidget {
  const StudentOnboardingScreen({super.key});

  @override
  ConsumerState<StudentOnboardingScreen> createState() => _StudentOnboardingScreenState();
}

class _StudentOnboardingScreenState extends ConsumerState<StudentOnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;

  // University is fixed for this ALU-only platform.
  static const _university = 'African Leadership University';

  static const _programmes = [
    'Global Challenges',
    'Business & Entrepreneurship',
    'Software Engineering',
  ];

  final _step1Key = GlobalKey<FormState>();
  String _programme = _programmes[0];
  final _bioController = TextEditingController();

  final _skillInputController = TextEditingController();
  final List<String> _skills = [];

  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    _bioController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_step == 0 && !(_step1Key.currentState?.validate() ?? false)) return;
    if (_step == 1 && _skills.isEmpty) {
      _showToast('Please add at least one skill', isError: true);
      return;
    }
    setState(() => _step++);
    _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOutCubic);
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOutCubic);
    }
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isNotEmpty && !_skills.contains(skill)) {
      setState(() => _skills.add(skill));
      _skillInputController.clear();
    }
  }

  Future<void> _submit() async {
    setState(() => _isLoading = true);
    try {
      final fbUser = fb.FirebaseAuth.instance.currentUser;
      final uid = fbUser?.uid;
      final email = fbUser?.email ?? '';
      final fullName = fbUser?.displayName ?? '';
      if (uid == null) return;

      await fbUser?.getIdToken(true);

      final student = Student(
        id: uid,
        fullName: fullName,
        email: email,
        university: _university,
        major: _programme,
        bio: _bioController.text.trim(),
        skills: _skills,
        education: [],
        experience: [],
      );

      await ref.read(studentRepositoryProvider).saveStudent(student);

      // Delegate the users doc update to the repository — no direct Firestore.
      await ref.read(authRepositoryProvider).completeStudentProfile();

      ref.read(roleProvider.notifier).setRole(UserRole.student);

      if (!mounted) return;
      _showToast('Profile created! Welcome to ALU Spark 🎉');
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pushNamedAndRemoveUntil(RouteNames.home, (_) => false);
    } catch (e) {
      if (mounted) {
        _showToast(e.toString().replaceFirst('Exception: ', ''), isError: true);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: AppColors.white,
              size: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(message,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            ),
          ],
        ),
        backgroundColor: isError ? AppColors.darkRed : const Color(0xFF1B5E20),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildStepIndicator(),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2(), _buildStep3()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Your Programme', 'Your Skills', 'Almost Done!'];
    final subtitles = [
      'Tell us about yourself',
      'What are you good at?',
      'Review and complete your profile',
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          if (_step > 0)
            GestureDetector(
              onTap: _prevStep,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.borderGlass),
                ),
                child: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 16),
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titles[_step], style: AppTextStyles.headingMedium.copyWith(fontSize: 20)),
                Text(subtitles[_step],
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
              ],
            ),
          ),
          Text('${_step + 1}/3',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(3, (i) {
          final active = i <= _step;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                height: 4,
                decoration: BoxDecoration(
                  gradient: active ? AppColors.redGradient : null,
                  color: active ? null : AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _step1Key,
        child: Column(
          children: [
            // University is pre-filled and read-only — this is an ALU-only platform.
            GlassmorphicContainer(
              blur: 10,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.account_balance_outlined,
                      color: AppColors.darkRed, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('University',
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.textSecondary, fontSize: 11)),
                        const SizedBox(height: 2),
                        Text(_university,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.white)),
                      ],
                    ),
                  ),
                  const Icon(Icons.lock_outline,
                      color: AppColors.textSecondary, size: 14),
                ],
              ),
            ),
            const SizedBox(height: 14),
            // ALU Programme dropdown
            Container(
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderGlass),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: DropdownButtonFormField<String>(
                initialValue: _programme,
                dropdownColor: AppColors.darkBlueLight,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.school_outlined, color: AppColors.darkRed, size: 20),
                  labelText: 'ALU Programme *',
                  labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  border: InputBorder.none,
                ),
                items: _programmes.map((p) => DropdownMenuItem(
                  value: p,
                  child: Text(p, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                )).toList(),
                onChanged: (v) => setState(() => _programme = v!),
              ),
            ),
            const SizedBox(height: 14),
            _buildBioField(),
            const SizedBox(height: 28),
            _buildPrimaryButton(label: 'Next', onTap: _nextStep),
          ],
        ),
      ),
    );
  }

  Widget _buildBioField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderGlass),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _bioController,
        maxLines: 4,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: 'Short bio — what are you passionate about? (optional)',
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 13),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Add your skills', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
          const SizedBox(height: 4),
          Text('e.g. Flutter, Python, Design, Marketing...',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderGlass),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _skillInputController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    decoration: InputDecoration(
                      hintText: 'Type a skill and press add...',
                      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onSubmitted: (_) => _addSkill(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, color: AppColors.darkRed),
                  onPressed: _addSkill,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_skills.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skills.map((skill) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(skill,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.white, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => setState(() => _skills.remove(skill)),
                        child: const Icon(Icons.close, color: AppColors.white, size: 14),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 28),
          _buildPrimaryButton(label: 'Next', onTap: _nextStep),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.glassWhite,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderGlass),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _reviewRow(Icons.account_balance_outlined, 'University', _university),
                const SizedBox(height: 12),
                _reviewRow(Icons.school_outlined, 'Programme', _programme),
                if (_bioController.text.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _reviewRow(Icons.info_outline, 'Bio', _bioController.text),
                ],
                const SizedBox(height: 12),
                _reviewRow(Icons.bolt_rounded, 'Skills', _skills.join(', ')),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: AppColors.darkRed, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'You can update your profile anytime from the Profile tab.',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          _buildPrimaryButton(label: 'Complete Profile', onTap: _isLoading ? null : _submit, isLoading: _isLoading),
        ],
      ),
    );
  }

  Widget _reviewRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppColors.darkRed, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 11)),
              Text(value.isEmpty ? '—' : value,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({required String label, required VoidCallback? onTap, bool isLoading = false}) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          disabledBackgroundColor: AppColors.glassWhite,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
            : Text(label, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }
}
