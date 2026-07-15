import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';
import 'package:alu_spark/features/startup_profile/presentation/providers/startup_provider.dart';

class StartupProfileEditScreen extends ConsumerStatefulWidget {
  const StartupProfileEditScreen({super.key});

  @override
  ConsumerState<StartupProfileEditScreen> createState() =>
      _StartupProfileEditScreenState();
}

class _StartupProfileEditScreenState
    extends ConsumerState<StartupProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic info controllers
  final _nameController = TextEditingController();
  final _taglineController = TextEditingController();
  final _industryController = TextEditingController();
  final _websiteController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Team member add-form controllers
  final _memberNameController = TextEditingController();
  final _memberRoleController = TextEditingController();

  List<Map<String, String>> _teamMembers = [];

  bool _loading = true;
  bool _saving = false;
  Startup? _original; // keep immutable fields (id, founderId, etc.)

  @override
  void initState() {
    super.initState();
    _loadStartup();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _industryController.dispose();
    _websiteController.dispose();
    _linkedinController.dispose();
    _descriptionController.dispose();
    _memberNameController.dispose();
    _memberRoleController.dispose();
    super.dispose();
  }

  Future<void> _loadStartup() async {
    final uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    // One-time read — we don't need a live stream for an edit form.
    final startup =
        await ref.read(startupRepositoryProvider).getStartupById(uid).first;
    if (!mounted) return;
    if (startup != null) {
      _original = startup;
      _nameController.text = startup.name;
      _taglineController.text = startup.tagline;
      _industryController.text = startup.industry;
      _websiteController.text = startup.website;
      _linkedinController.text = startup.linkedin;
      _descriptionController.text = startup.description;
      _teamMembers =
          startup.teamMembers.map((m) => Map<String, String>.from(m)).toList();
    }
    setState(() => _loading = false);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_original == null) return;

    setState(() => _saving = true);
    try {
      final updated = Startup(
        id: _original!.id,
        name: _nameController.text.trim(),
        tagline: _taglineController.text.trim(),
        industry: _industryController.text.trim(),
        description: _descriptionController.text.trim(),
        founderId: _original!.founderId,
        founderName: _original!.founderName,
        teamMembers: _teamMembers,
        openRolesCount: _original!.openRolesCount,
        isVerified: _original!.isVerified,
        createdAt: _original!.createdAt,
        website: _websiteController.text.trim(),
        linkedin: _linkedinController.text.trim(),
        stage: _original!.stage,
        teamSize: _original!.teamSize,
      );

      await ref.read(startupRepositoryProvider).updateStartup(updated);

      // Invalidate the cached provider so StartupProfileScreen refreshes.
      ref.invalidate(startupDetailProvider(_original!.id));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline,
                  color: AppColors.white, size: 18),
              const SizedBox(width: 10),
              Text('Profile updated!',
                  style:
                      AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            ]),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  e.toString().replaceFirst('Exception: ', ''),
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.white),
                ),
              ),
            ]),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _addTeamMember() {
    final name = _memberNameController.text.trim();
    final role = _memberRoleController.text.trim();
    if (name.isEmpty || role.isEmpty) return;
    setState(() {
      _teamMembers.add({'name': name, 'role': role});
      _memberNameController.clear();
      _memberRoleController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: Center(
            child: CircularProgressIndicator(color: AppColors.darkRed)),
      );
    }

    if (_original == null) {
      return Scaffold(
        backgroundColor: AppColors.darkBlue,
        appBar: _buildAppBar(),
        body: Center(
          child: Text(
            'Startup profile not found.',
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _glassField(
                controller: _nameController,
                hint: 'Startup Name',
                icon: Icons.business_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _glassField(
                controller: _taglineController,
                hint: 'Tagline',
                icon: Icons.flag_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _glassField(
                controller: _industryController,
                hint: 'Industry',
                icon: Icons.category_outlined,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 14),
              _glassField(
                controller: _websiteController,
                hint: 'Website (optional)',
                icon: Icons.language_rounded,
              ),
              const SizedBox(height: 14),
              _glassField(
                controller: _linkedinController,
                hint: 'LinkedIn URL (optional)',
                icon: Icons.link_rounded,
              ),
              const SizedBox(height: 32),
              _sectionTitle('About Your Startup'),
              const SizedBox(height: 16),
              _glassField(
                controller: _descriptionController,
                hint: 'Tell students about your startup, mission, and vision...',
                icon: Icons.description_outlined,
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              _sectionTitle('Team Members'),
              const SizedBox(height: 16),
              _buildTeamMembersEditor(),
              const SizedBox(height: 40),
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
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
        'Edit Startup Profile',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: TextButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: AppColors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Save',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.white),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _sectionTitle(String title) => Text(
        title,
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      );

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        validator: validator,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.darkRed) : null,
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildTeamMembersEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ..._teamMembers.asMap().entries.map((entry) {
          final index = entry.key;
          final member = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: AppColors.darkRed.withValues(alpha: 0.2),
                    child: Text(
                      (member['name'] ?? '?').isNotEmpty
                          ? member['name']![0]
                          : '?',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.darkRed),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name'] ?? '',
                          style: AppTextStyles.bodyLarge
                              .copyWith(color: AppColors.white),
                        ),
                        Text(
                          member['role'] ?? '',
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.darkRed, size: 20),
                    onPressed: () =>
                        setState(() => _teamMembers.removeAt(index)),
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Team Member',
                style:
                    AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _memberNameController,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const Divider(color: AppColors.borderGlass, height: 1),
              TextField(
                controller: _memberRoleController,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Role (e.g. CTO, Lead Designer)',
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addTeamMember,
                  icon: const Icon(Icons.add,
                      color: AppColors.white, size: 18),
                  label: Text(
                    'Add Member',
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding:
                        const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _saving ? null : _save,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          disabledBackgroundColor: AppColors.glassWhite,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: _saving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                    color: AppColors.white, strokeWidth: 2),
              )
            : Text(
                'Save Changes',
                style:
                    AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
      ),
    );
  }
}
