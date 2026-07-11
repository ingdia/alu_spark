import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class PostOpportunityScreen extends ConsumerStatefulWidget {
  const PostOpportunityScreen({super.key});

  @override
  ConsumerState<PostOpportunityScreen> createState() => _PostOpportunityScreenState();
}

class _PostOpportunityScreenState extends ConsumerState<PostOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _salaryController = TextEditingController();
  final _reqInputController = TextEditingController();
  final _benInputController = TextEditingController();

  String _selectedCategory = 'Tech';
  String _selectedLocation = 'Kigali';
  String _selectedType = 'Internship';

  final List<String> _categories = ['Tech', 'Design', 'Marketing', 'Business', 'Finance'];
  final List<String> _locations = ['Kigali', 'Remote', 'Nairobi', 'Cape Town', 'Lagos'];
  final List<String> _types = ['Internship', 'Part-time', 'Full-time', 'Freelance'];

  final List<String> _requirements = [];
  final List<String> _benefits = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _reqInputController.dispose();
    _benInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _buildGlassTextField(
                controller: _titleController,
                hintText: 'Opportunity Title (e.g., Frontend Developer)',
                prefixIcon: Icons.work_outline,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGlassDropdown(
                      label: 'Category',
                      value: _selectedCategory,
                      items: _categories,
                      onChanged: (val) => setState(() => _selectedCategory = val!),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGlassDropdown(
                      label: 'Type',
                      value: _selectedType,
                      items: _types,
                      onChanged: (val) => setState(() => _selectedType = val!),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildGlassDropdown(
                label: 'Location',
                value: _selectedLocation,
                items: _locations,
                onChanged: (val) => setState(() => _selectedLocation = val!),
              ),
              const SizedBox(height: 16),
              _buildGlassTextField(
                controller: _salaryController,
                hintText: 'Compensation (e.g., \$500/month or Unpaid)',
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 32),
              
              _buildSectionTitle('Description'),
              const SizedBox(height: 16),
              _buildGlassTextField(
                controller: _descriptionController,
                hintText: 'Describe the role, responsibilities, and goals...',
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Requirements'),
              const SizedBox(height: 16),
              _buildAddItemField(
                controller: _reqInputController,
                hintText: 'Add a requirement...',
                items: _requirements,
                onAdd: _addRequirement,
                onRemove: _removeRequirement,
              ),
              const SizedBox(height: 32),

              _buildSectionTitle('Benefits'),
              const SizedBox(height: 16),
              _buildAddItemField(
                controller: _benInputController,
                hintText: 'Add a benefit...',
                items: _benefits,
                onAdd: _addBenefit,
                onRemove: _removeBenefit,
              ),
              const SizedBox(height: 40),

              _buildSubmitButton(),
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
        'Post Opportunity',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
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

  Widget _buildGlassDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: AppColors.darkBlueLight,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
          isExpanded: true,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildAddItemField({
    required TextEditingController controller,
    required String hintText,
    required List<String> items,
    required VoidCallback onAdd,
    required ValueChanged<int> onRemove,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlassmorphicContainer(
          blur: 10,
          borderRadius: 12,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onSubmitted: (_) => onAdd(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline, color: AppColors.darkRed),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (items.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(items.length, (index) {
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
                      items[index],
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => onRemove(index),
                      child: const Icon(Icons.close, color: AppColors.textSecondary, size: 16),
                    ),
                  ],
                ),
              );
            }),
          ),
      ],
    );
  }

  void _addRequirement() {
    if (_reqInputController.text.trim().isNotEmpty) {
      setState(() {
        _requirements.add(_reqInputController.text.trim());
        _reqInputController.clear();
      });
    }
  }

  void _removeRequirement(int index) {
    setState(() => _requirements.removeAt(index));
  }

  void _addBenefit() {
    if (_benInputController.text.trim().isNotEmpty) {
      setState(() {
        _benefits.add(_benInputController.text.trim());
        _benInputController.clear();
      });
    }
  }

  void _removeBenefit(int index) {
    setState(() => _benefits.removeAt(index));
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () {
          // TODO: Trigger provider to post opportunity
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Post Opportunity',
          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
        ),
      ),
    );
  }
}