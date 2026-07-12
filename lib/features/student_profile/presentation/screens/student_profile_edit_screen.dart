import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/student_profile/domain/entities/student.dart';
import 'package:alu_spark/features/student_profile/presentation/providers/student_profile_provider.dart';

class StudentProfileEditScreen extends ConsumerStatefulWidget {
  const StudentProfileEditScreen({super.key});

  @override
  ConsumerState<StudentProfileEditScreen> createState() => _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends ConsumerState<StudentProfileEditScreen> {
  final _nameController = TextEditingController();
  final _majorController = TextEditingController();
  final _universityController = TextEditingController();
  final _bioController = TextEditingController();
  final _skillInputController = TextEditingController();

  List<String> _skills = [];
  List<Map<String, String>> _education = [];
  List<Map<String, String>> _experience = [];

  bool _loading = true;
  bool _saving = false;
  String? _uid;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _uid = fb.FirebaseAuth.instance.currentUser?.uid;
    if (_uid == null) return;
    final student = await ref.read(studentRepositoryProvider).getStudent(_uid!);
    if (student != null && mounted) {
      _nameController.text = student.fullName;
      _majorController.text = student.major;
      _universityController.text = student.university;
      _bioController.text = student.bio;
      setState(() {
        _skills = List.from(student.skills);
        _education = student.education.map((e) => Map<String, String>.from(e)).toList();
        _experience = student.experience.map((e) => Map<String, String>.from(e)).toList();
        _loading = false;
      });
    } else {
      setState(() => _loading = false);
    }
  }

  Future<void> _save() async {
    if (_uid == null) return;
    setState(() => _saving = true);
    try {
      await fb.FirebaseAuth.instance.currentUser?.getIdToken(true);
      final student = Student(
        id: _uid!,
        fullName: _nameController.text.trim(),
        email: fb.FirebaseAuth.instance.currentUser?.email ?? '',
        university: _universityController.text.trim(),
        major: _majorController.text.trim(),
        bio: _bioController.text.trim(),
        skills: _skills,
        education: _education,
        experience: _experience,
      );
      await ref.read(studentRepositoryProvider).saveStudent(student);
      ref.invalidate(studentProfileProvider(_uid!));
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.darkRed),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _majorController.dispose();
    _universityController.dispose();
    _bioController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppColors.darkBlue,
        body: Center(child: CircularProgressIndicator(color: AppColors.darkRed)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(10),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 16),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text('Edit Profile', style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 12,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextButton(
                onPressed: _saving ? null : _save,
                child: _saving
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                    : Text('Save', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _glassField(_nameController, 'Full Name', Icons.person_outline),
            const SizedBox(height: 12),
            _glassField(_majorController, 'Major', Icons.school_outlined),
            const SizedBox(height: 12),
            _glassField(_universityController, 'University', Icons.account_balance_outlined),
            const SizedBox(height: 28),
            _sectionTitle('About Me'),
            const SizedBox(height: 16),
            _glassField(_bioController, 'Tell us about yourself...', Icons.info_outline, maxLines: 4),
            const SizedBox(height: 28),
            _sectionTitle('Skills'),
            const SizedBox(height: 16),
            _buildSkillsEditor(),
            const SizedBox(height: 28),
            _sectionTitle('Education'),
            const SizedBox(height: 16),
            _buildListEditor(
              items: _education,
              titleKey: 'degree',
              subtitleKey: 'institution',
              onAdd: () => setState(() => _education.add({'degree': '', 'institution': '', 'period': ''})),
              onRemove: (i) => setState(() => _education.removeAt(i)),
              addLabel: 'Add Education',
            ),
            const SizedBox(height: 28),
            _sectionTitle('Experience'),
            const SizedBox(height: 16),
            _buildListEditor(
              items: _experience,
              titleKey: 'role',
              subtitleKey: 'company',
              onAdd: () => setState(() => _experience.add({'role': '', 'company': '', 'period': ''})),
              onRemove: (i) => setState(() => _experience.removeAt(i)),
              addLabel: 'Add Experience',
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.darkRed,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                    : Text('Save Changes', style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white, fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) => Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));

  Widget _glassField(TextEditingController controller, String hint, IconData icon, {int maxLines = 1}) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: Icon(icon, color: AppColors.darkRed),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildSkillsEditor() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_skills.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _skills.map((skill) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGlass),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(skill, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => setState(() => _skills.remove(skill)),
                    child: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                  ),
                ],
              ),
            )).toList(),
          ),
        const SizedBox(height: 12),
        GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _skillInputController,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: 'Add a skill...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => _addSkill(),
                ),
              ),
              IconButton(icon: const Icon(Icons.add_circle_outline, color: AppColors.darkRed), onPressed: _addSkill),
            ],
          ),
        ),
      ],
    );
  }

  void _addSkill() {
    final s = _skillInputController.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() => _skills.add(s));
      _skillInputController.clear();
    }
  }

  Widget _buildListEditor({
    required List<Map<String, String>> items,
    required String titleKey,
    required String subtitleKey,
    required VoidCallback onAdd,
    required void Function(int) onRemove,
    required String addLabel,
  }) {
    return Column(
      children: [
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 14,
              padding: const EdgeInsets.all(14),
              child: Column(
                children: [
                  _inlineField(item, titleKey, titleKey == 'degree' ? 'Degree / Certificate' : 'Role / Position'),
                  const SizedBox(height: 8),
                  _inlineField(item, subtitleKey, subtitleKey == 'institution' ? 'Institution' : 'Company'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(child: _inlineField(item, 'period', 'Period (e.g. 2023 - 2025)')),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: AppColors.darkRed, size: 20),
                        onPressed: () => onRemove(i),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(addLabel, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderGlass),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _inlineField(Map<String, String> map, String key, String hint) {
    return TextField(
      controller: TextEditingController(text: map[key])
        ..addListener(() {}),
      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white, fontSize: 13),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
        border: InputBorder.none,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 4),
      ),
      onChanged: (v) => map[key] = v,
    );
  }
}
