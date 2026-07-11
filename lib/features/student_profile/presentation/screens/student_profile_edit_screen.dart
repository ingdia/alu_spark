import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class StudentProfileEditScreen extends ConsumerStatefulWidget {
  const StudentProfileEditScreen({super.key});

  @override
  ConsumerState<StudentProfileEditScreen> createState() => _StudentProfileEditScreenState();
}

class _StudentProfileEditScreenState extends ConsumerState<StudentProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'Alex Johnson');
  final _majorController = TextEditingController(text: 'Software Engineering');
  final _universityController = TextEditingController(text: 'African Leadership University');
  final _bioController = TextEditingController(text: 'Passionate software engineering student with a keen interest in mobile development and UI/UX design.');
  final _skillInputController = TextEditingController();
  
  final List<String> _skills = ['Flutter', 'Dart', 'Python', 'UI/UX Design', 'Firebase'];
  
  // Using final for lists to align with project conventions
  final List<Map<String, String>> _education = [
    {'degree': 'BSc in Software Engineering', 'institution': 'African Leadership University', 'period': '2023 - 2027'},
  ];
  
  final List<Map<String, String>> _experience = [
    {'role': 'UI/UX Design Intern', 'company': 'TechStart', 'period': 'Jun 2025 - Present'},
    {'role': 'Frontend Developer', 'company': 'DesignHub', 'period': 'Jan 2025 - May 2025'},
  ];

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
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _buildGlassTextField(controller: _nameController, hintText: 'Full Name', prefixIcon: Icons.person_outline),
              const SizedBox(height: 16),
              _buildGlassTextField(controller: _majorController, hintText: 'Major', prefixIcon: Icons.school_outlined),
              const SizedBox(height: 16),
              _buildGlassTextField(controller: _universityController, hintText: 'University', prefixIcon: Icons.account_balance_outlined),
              const SizedBox(height: 32),

              _buildSectionTitle('About Me'),
              const SizedBox(height: 16),
              _buildGlassTextField(controller: _bioController, hintText: 'Tell us about yourself...', prefixIcon: Icons.info_outline, maxLines: 4),
              const SizedBox(height: 32),

              _buildSectionTitle('Skills'),
              const SizedBox(height: 16),
              _buildSkillsEditor(),
              const SizedBox(height: 32),

              _buildSectionTitle('Education'),
              const SizedBox(height: 16),
              _buildEducationEditor(),
              const SizedBox(height: 32),

              _buildSectionTitle('Experience'),
              const SizedBox(height: 16),
              _buildExperienceEditor(),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      title: Text(
        'Edit Profile',
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
              onPressed: () {
                // TODO: Trigger provider to save profile
              },
              child: Text(
                'Save',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    int maxLines = 1,
  }) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.darkRed) : null,
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _skills.map((skill) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderGlass),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    skill,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {
                      setState(() => _skills.remove(skill));
                    },
                    child: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                  ),
                ],
              ),
            );
          }).toList(),
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
                    hintText: 'Add a new skill...',
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
      ],
    );
  }

  void _addSkill() {
    if (_skillInputController.text.trim().isNotEmpty) {
      setState(() {
        _skills.add(_skillInputController.text.trim());
        _skillInputController.clear();
      });
    }
  }

  Widget _buildEducationEditor() {
    return Column(
      children: [
        ..._education.asMap().entries.map((entry) {
          final index = entry.key;
          final edu = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(edu['degree']!, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                        const SizedBox(height: 4),
                        Text(edu['institution']!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(edu['period']!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.darkRed, size: 20),
                    onPressed: () {
                      setState(() => _education.removeAt(index));
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _education.add({
                  'degree': 'New Degree',
                  'institution': 'New Institution',
                  'period': '202X - 202X',
                });
              });
            },
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Add Education',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderGlass),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExperienceEditor() {
    return Column(
      children: [
        ..._experience.asMap().entries.map((entry) {
          final index = entry.key;
          final exp = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: GlassmorphicContainer(
              blur: 10,
              borderRadius: 16,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(exp['role']!, style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                        const SizedBox(height: 4),
                        Text(exp['company']!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                        const SizedBox(height: 4),
                        Text(exp['period']!, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.darkRed, size: 20),
                    onPressed: () {
                      setState(() => _experience.removeAt(index));
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _experience.add({
                  'role': 'New Role',
                  'company': 'New Company',
                  'period': '202X - Present',
                });
              });
            },
            icon: const Icon(Icons.add, color: AppColors.white),
            label: Text(
              'Add Experience',
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.borderGlass),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
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
        onPressed: () {
          // TODO: Trigger provider to save profile
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Save Changes',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}