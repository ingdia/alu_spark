import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_provider.dart';
import 'package:alu_spark/features/auth/presentation/providers/auth_state.dart';
import 'package:alu_spark/features/auth/presentation/widgets/auth_widgets.dart';

class StartupOnboardingScreen extends ConsumerStatefulWidget {
  const StartupOnboardingScreen({super.key});

  @override
  ConsumerState<StartupOnboardingScreen> createState() =>
      _StartupOnboardingScreenState();
}

class _StartupOnboardingScreenState
    extends ConsumerState<StartupOnboardingScreen> {
  final _pageController = PageController();
  int _step = 0;

  // Step 1 — Startup Info
  final _step1Key = GlobalKey<FormState>();
  final _startupNameController = TextEditingController();
  final _startupTaglineController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  String _selectedIndustry = 'Technology';
  String _selectedStage = 'Idea';
  String _selectedSize = '1–5';

  // Step 2 — Founders
  final _step2Key = GlobalKey<FormState>();
  late final List<_FounderEntry> _founders;
  // Locked values for Founder #1 — read directly from FirebaseAuth synchronously.
  late final String _founderOneName;
  late final String _founderOneEmail;

  // Step 3 — Proof document link
  final _proofLinkController = TextEditingController();
  final _descController = TextEditingController();

  static const _industries = [
    'Technology', 'FinTech', 'HealthTech', 'EdTech',
    'AgriTech', 'E-Commerce', 'Social Impact', 'Other',
  ];
  static const _stages = ['Idea', 'MVP', 'Early Stage', 'Growth', 'Scale'];
  static const _sizes = ['1–5', '6–10', '11–20', '21–50', '50+'];

  @override
  void initState() {
    super.initState();
    // Read the current Firebase user synchronously — always available here
    // because the user must be logged in to reach this screen.
    final firebaseUser = fb.FirebaseAuth.instance.currentUser;
    _founderOneName  = firebaseUser?.displayName ?? firebaseUser?.email?.split('@').first ?? '';
    _founderOneEmail = firebaseUser?.email ?? '';

    // Pre-fill Founder #1 controllers so _submit() can read them normally.
    final firstEntry = _FounderEntry();
    firstEntry.nameController.text  = _founderOneName;
    firstEntry.emailController.text = _founderOneEmail;
    _founders = [firstEntry];
  }

  @override
  void dispose() {
    _pageController.dispose();
    _startupNameController.dispose();
    _startupTaglineController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _proofLinkController.dispose();
    _descController.dispose();
    for (final f in _founders) {
      f.dispose();
    }
    super.dispose();
  }

  void _onStateChange(AuthState? previous, AuthState next) {
    if (next.status == AuthStatus.success) {
      ref.read(authNotifierProvider.notifier).reset();
      _showSuccessDialog();
    } else if (next.status == AuthStatus.error) {
      final msg = next.errorMessage ?? 'An error occurred. Please try again.';
      ref.read(authNotifierProvider.notifier).reset();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.darkBlueLight,
          title: Text('Submission Failed',
              style: AppTextStyles.headingMedium.copyWith(fontSize: 16)),
          content: Text(msg,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK',
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.darkRed)),
            ),
          ],
        ),
      );
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: AppColors.darkBlueLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.redGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkRed.withValues(alpha: 0.4),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    color: AppColors.white, size: 36),
              ),
              const SizedBox(height: 20),
              Text(
                'Application Submitted!',
                style: AppTextStyles.headingMedium.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                'Your startup profile is under review. Our admin team will verify your documents and approve your account within 24–48 hours.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.55,
                  fontSize: 13,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: GestureDetector(
                  onTap: () => Navigator.pushNamedAndRemoveUntil(
                      context, RouteNames.startupPending, (_) => false),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.redGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text('View Status',
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          )),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _nextStep() {
    if (_step == 0 && !(_step1Key.currentState?.validate() ?? false)) return;
    if (_step == 1) {
      if (!(_step2Key.currentState?.validate() ?? false)) return;
      if (_founders.length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add at least 2 founders.'),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        return;
      }
    }
    if (_step < 2) {
      setState(() => _step++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _prevStep() {
    if (_step > 0) {
      setState(() => _step--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _submit() {
    final url = _proofLinkController.text.trim();
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('A proof document link is required.'),
          backgroundColor: AppColors.darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    if (!url.startsWith('https://') && !url.startsWith('http://')) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter a valid URL (must start with https://).'),
          backgroundColor: AppColors.darkRed,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          margin: const EdgeInsets.all(16),
        ),
      );
      return;
    }
    ref.read(authNotifierProvider.notifier).registerStartup(
      startupName: _startupNameController.text.trim(),
      tagline: _startupTaglineController.text.trim(),
      website: _websiteController.text.trim(),
      linkedin: _linkedinController.text.trim(),
      industry: _selectedIndustry,
      stage: _selectedStage,
      teamSize: _selectedSize,
      founders: _founders
          .map((f) => {
                'name': f.nameController.text.trim(),
                'role': f.roleController.text.trim(),
                'email': f.emailController.text.trim(),
              })
          .toList(),
      description: _descController.text.trim(),
      proofDocumentUrl: url,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, _onStateChange);
    final isLoading = ref.watch(authNotifierProvider).isLoading;

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
                children: [
                  _buildStep1(),
                  _buildStep2(),
                  _buildStep3(isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = ['Startup Info', 'Founders', 'Verification'];
    final subtitles = [
      'Tell us about your startup',
      'Who are the founding team?',
      'Share a link to your proof document',
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          if (_step > 0)
            GestureDetector(
              onTap: _prevStep,
              child: GlassmorphicContainer(
                blur: 10,
                borderRadius: 10,
                padding: const EdgeInsets.all(10),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.white, size: 16),
              ),
            )
          else
            const SizedBox(width: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(titles[_step],
                    style: AppTextStyles.headingMedium.copyWith(fontSize: 20)),
                Text(subtitles[_step],
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    )),
              ],
            ),
          ),
          Text(
            '${_step + 1}/3',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Row(
        children: List.generate(3, (i) {
          final done = i < _step;
          final active = i == _step;
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 6 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 280),
                height: 4,
                decoration: BoxDecoration(
                  gradient: active || done ? AppColors.redGradient : null,
                  color: active || done ? null : AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ── Step 1: Startup Info ──────────────────────────────────────────────────
  Widget _buildStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Form(
        key: _step1Key,
        child: Column(
          children: [
            AuthTextField(
              controller: _startupNameController,
              hintText: 'Startup Name *',
              prefixIcon: Icons.business_rounded,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _startupTaglineController,
              hintText: 'Tagline (e.g. "Connecting Africa\'s talent")',
              prefixIcon: Icons.lightbulb_outline,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _websiteController,
              hintText: 'Website (optional)',
              prefixIcon: Icons.language_rounded,
              keyboardType: TextInputType.url,
              validator: (_) => null,
            ),
            const SizedBox(height: 14),
            AuthTextField(
              controller: _linkedinController,
              hintText: 'LinkedIn URL (optional)',
              prefixIcon: Icons.link_rounded,
              keyboardType: TextInputType.url,
              validator: (_) => null,
            ),
            const SizedBox(height: 14),
            _DropdownField(
              label: 'Industry',
              icon: Icons.category_rounded,
              value: _selectedIndustry,
              items: _industries,
              onChanged: (v) => setState(() => _selectedIndustry = v!),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _DropdownField(
                    label: 'Stage',
                    icon: Icons.trending_up_rounded,
                    value: _selectedStage,
                    items: _stages,
                    onChanged: (v) => setState(() => _selectedStage = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DropdownField(
                    label: 'Team Size',
                    icon: Icons.group_rounded,
                    value: _selectedSize,
                    items: _sizes,
                    onChanged: (v) => setState(() => _selectedSize = v!),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _PrimaryButton(label: 'Next: Founders', onTap: _nextStep),
          ],
        ),
      ),
    );
  }

  // ── Step 2: Founders ──────────────────────────────────────────────────────
  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Form(
        key: _step2Key,
        child: Column(
          children: [
            ..._founders.asMap().entries.map((entry) {
              final i = entry.key;
              final f = entry.value;
              return _FounderCard(
                index: i,
                entry: f,
                canRemove: _founders.length > 1 && i > 0,
                onRemove: () => setState(() => _founders.removeAt(i)),
              );
            }),
            const SizedBox(height: 12),
            if (_founders.length < 5)
              GestureDetector(
                onTap: () => setState(() => _founders.add(_FounderEntry())),
                child: GlassmorphicContainer(
                  blur: 10,
                  borderRadius: 12,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_circle_outline,
                          color: AppColors.darkRed, size: 18),
                      const SizedBox(width: 8),
                      Text('Add Another Founder',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.darkRed,
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 28),
            _PrimaryButton(label: 'Next: Verification', onTap: _nextStep),
          ],
        ),
      ),
    );
  }

  // ── Step 3: Proof Document Link ───────────────────────────────────────────
  Widget _buildStep3(bool isLoading) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.darkRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.admin_panel_settings_rounded,
                      color: AppColors.darkRed, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Admin Review Required',
                          style: AppTextStyles.bodyLarge.copyWith(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          )),
                      const SizedBox(height: 3),
                      Text(
                        'Your documents will be reviewed by our admin team before your startup goes live.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text('Proof Document Link *',  // required
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              )),
          const SizedBox(height: 6),
          Text(
            'Paste a link to your business registration certificate, pitch deck, or any official document that verifies your startup (Google Drive, Dropbox, OneDrive, etc.).',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 14),

          GlassmorphicContainer(
            blur: 10,
            borderRadius: 14,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextFormField(
              controller: _proofLinkController,
              keyboardType: TextInputType.url,
              autocorrect: false,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.white, fontSize: 13),
              decoration: InputDecoration(
                hintText: 'https://drive.google.com/...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                prefixIcon: const Icon(Icons.link_rounded,
                    color: AppColors.darkRed, size: 20),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                final t = v.trim();
                if (!t.startsWith('https://') && !t.startsWith('http://')) {
                  return 'Must be a valid URL (https://...)';
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _linkChip('Google Drive', Icons.add_to_drive_outlined),
              _linkChip('Dropbox', Icons.cloud_outlined),
              _linkChip('OneDrive', Icons.cloud_queue_outlined),
              _linkChip('Notion', Icons.article_outlined),
            ],
          ),
          const SizedBox(height: 20),

          GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextFormField(
              controller: _descController,
              maxLines: 4,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Brief description of your startup (optional)',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 28),

          _PrimaryButton(
            label: 'Submit for Review',
            onTap: isLoading ? null : _submit,
            isLoading: isLoading,
            icon: Icons.send_rounded,
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _linkChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.textSecondary),
          const SizedBox(width: 5),
          Text(label,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.textSecondary, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Founder card ──────────────────────────────────────────────────────────────
class _FounderCard extends StatelessWidget {
  final int index;
  final _FounderEntry entry;
  final bool canRemove;
  final VoidCallback onRemove;

  const _FounderCard({
    required this.index,
    required this.entry,
    required this.canRemove,
    required this.onRemove,
  });

  // Founder #1 (index 0) is the logged-in verified ALU user.
  // Their name and email are locked; only the role is editable.
  bool get _isLeadFounder => index == 0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(
                      color: AppColors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  index == 0 ? 'Lead Founder (You)' : 'Co-Founder ${index + 1}',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                if (canRemove)
                  GestureDetector(
                    onTap: onRemove,
                    child: const Icon(Icons.remove_circle_outline,
                        color: AppColors.darkRed, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 14),

            // Name
            if (_isLeadFounder)
              _ReadOnlyField(
                label: 'Full Name',
                value: entry.nameController.text,
                icon: Icons.person_outline,
              )
            else
              AuthTextField(
                controller: entry.nameController,
                hintText: 'Full Name *',
                prefixIcon: Icons.person_outline,
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
            const SizedBox(height: 12),

            // Role (editable for everyone)
            AuthTextField(
              controller: entry.roleController,
              hintText: 'Role (e.g. CEO, CTO) *',
              prefixIcon: Icons.work_outline,
              validator: (v) => v == null || v.isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 12),

            // Email
            if (_isLeadFounder)
              _ReadOnlyField(
                label: 'Email',
                value: entry.emailController.text,
                icon: Icons.email_outlined,
              )
            else
              AuthTextField(
                controller: entry.emailController,
                hintText: 'Email *',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  if (!v.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
          ],
        ),
      ),
    );
  }
}

// ── Read-only display field ───────────────────────────────────────────────────
class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary, fontSize: 10)),
                const SizedBox(height: 2),
                Text(
                  value.isEmpty ? '—' : value,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                ),
              ],
            ),
          ),
          const Icon(Icons.lock_outline,
              color: AppColors.textSecondary, size: 14),
        ],
      ),
    );
  }
}

// ── Dropdown field ────────────────────────────────────────────────────────────
class _DropdownField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        dropdownColor: AppColors.darkBlueLight,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        icon: const Icon(Icons.keyboard_arrow_down_rounded,
            color: AppColors.textSecondary),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppColors.darkRed, size: 18),
          labelText: label,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          border: InputBorder.none,
          isDense: true,
        ),
        items: items
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e,
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.white)),
                ))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }
}

// ── Primary button ────────────────────────────────────────────────────────────
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final IconData? icon;

  const _PrimaryButton({
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            gradient: onTap != null ? AppColors.redGradient : null,
            color: onTap == null ? AppColors.glassWhite : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: onTap != null
                ? [
                    BoxShadow(
                        color: AppColors.darkRed.withValues(alpha: 0.4),
                        blurRadius: 20,
                        offset: const Offset(0, 8))
                  ]
                : [],
          ),
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(label,
                          style: AppTextStyles.bodyLarge.copyWith(
                            color: AppColors.white,
                            fontWeight: FontWeight.w700,
                          )),
                      if (icon != null) ...[
                        const SizedBox(width: 8),
                        Icon(icon, color: AppColors.white, size: 18),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Founder entry data ────────────────────────────────────────────────────────
class _FounderEntry {
  final nameController = TextEditingController();
  final roleController = TextEditingController();
  final emailController = TextEditingController();

  void dispose() {
    nameController.dispose();
    roleController.dispose();
    emailController.dispose();
  }
}
