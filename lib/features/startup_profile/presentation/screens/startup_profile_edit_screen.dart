import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class StartupProfileEditScreen extends ConsumerStatefulWidget {
  const StartupProfileEditScreen({super.key});

  @override
  ConsumerState<StartupProfileEditScreen> createState() => _StartupProfileEditScreenState();
}

class _StartupProfileEditScreenState extends ConsumerState<StartupProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController(text: 'TechStart');
  final _taglineController = TextEditingController(text: 'Empowering students through technology');
  final _industryController = TextEditingController(text: 'EdTech');
  final _descriptionController = TextEditingController(text: 'TechStart is a student-led startup focused on building innovative educational tools. We aim to bridge the gap between academic learning and industry requirements.');
  final _teamMemberNameController = TextEditingController();
  final _teamMemberRoleController = TextEditingController();
  
  // Using final for lists to align with project conventions
  final List<Map<String, String>> _teamMembers = [
    {'name': 'John Doe', 'role': 'CEO & Founder'},
    {'name': 'Jane Smith', 'role': 'CTO'},
    {'name': 'Alice Brown', 'role': 'Lead Designer'},
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _taglineController.dispose();
    _industryController.dispose();
    _descriptionController.dispose();
    _teamMemberNameController.dispose();
    _teamMemberRoleController.dispose();
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
              _buildGlassTextField(controller: _nameController, hintText: 'Startup Name', prefixIcon: Icons.business_outlined),
              const SizedBox(height: 16),
              _buildGlassTextField(controller: _taglineController, hintText: 'Tagline', prefixIcon: Icons.flag_outlined),
              const SizedBox(height: 16),
              _buildGlassTextField(controller: _industryController, hintText: 'Industry', prefixIcon: Icons.category_outlined),
              const SizedBox(height: 32),

              _buildSectionTitle('About Your Startup'),
              const SizedBox(height: 16),
              _buildGlassTextField(
                controller: _descriptionController, 
                hintText: 'Tell students about your startup, mission, and vision...', 
                prefixIcon: Icons.description_outlined, 
                maxLines: 5
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Team Members'),
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
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
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
              onPressed: () {
                // TODO: Trigger provider to save startup profile
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
                    backgroundColor: AppColors.darkRed.withOpacity(0.2),
                    child: Text(
                      member['name']!.substring(0, 1),
                      style: AppTextStyles.bodyLarge.copyWith(color: AppColors.darkRed),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          member['name']!,
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                        ),
                        Text(
                          member['role']!,
                          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColors.darkRed, size: 20),
                    onPressed: () {
                      setState(() => _teamMembers.removeAt(index));
                    },
                  ),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 16),
        GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add New Team Member',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _teamMemberNameController,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Name',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const Divider(color: AppColors.borderGlass, height: 1),
              TextField(
                controller: _teamMemberRoleController,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Role (e.g., CTO, Lead Designer)',
                  hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 8),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addTeamMember,
                  icon: const Icon(Icons.add, color: AppColors.white, size: 18),
                  label: Text(
                    'Add Member',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _addTeamMember() {
    if (_teamMemberNameController.text.trim().isNotEmpty && 
        _teamMemberRoleController.text.trim().isNotEmpty) {
      setState(() {
        _teamMembers.add({
          'name': _teamMemberNameController.text.trim(),
          'role': _teamMemberRoleController.text.trim(),
        });
        _teamMemberNameController.clear();
        _teamMemberRoleController.clear();
      });
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Trigger provider to save startup profile
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