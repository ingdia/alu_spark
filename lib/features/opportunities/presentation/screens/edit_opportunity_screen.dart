import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class EditOpportunityScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;

  const EditOpportunityScreen({super.key, required this.opportunity});

  @override
  ConsumerState<EditOpportunityScreen> createState() => _EditOpportunityScreenState();
}

class _EditOpportunityScreenState extends ConsumerState<EditOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _salaryController;
  final _reqInputController = TextEditingController();
  final _benInputController = TextEditingController();

  late String _selectedCategory;
  late String _selectedLocation;
  late String _selectedType;

  final List<String> _categories = ['Tech', 'Design', 'Marketing', 'Business', 'Finance'];
  final List<String> _locations = ['Kigali', 'Remote', 'Nairobi', 'Cape Town', 'Lagos'];
  final List<String> _types = ['Internship', 'Part-time', 'Full-time', 'Freelance'];

  late List<String> _requirements;
  late List<String> _benefits;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final o = widget.opportunity;
    _titleController = TextEditingController(text: o.title);
    _descriptionController = TextEditingController(text: o.description);
    _salaryController = TextEditingController(text: o.salary ?? '');
    _selectedCategory = _categories.contains(o.category) ? o.category : _categories.first;
    _selectedLocation = _locations.contains(o.location) ? o.location : _locations.first;
    _selectedType = _types.contains(o.type) ? o.type : _types.first;
    _requirements = List<String>.from(o.requirements);
    _benefits = List<String>.from(o.benefits);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _reqInputController.dispose();
    _benInputController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updated = widget.opportunity.copyWith(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _selectedCategory,
        location: _selectedLocation,
        type: _selectedType,
        salary: _salaryController.text.trim().isEmpty ? null : _salaryController.text.trim(),
        requirements: List<String>.from(_requirements),
        benefits: List<String>.from(_benefits),
      );
      await ref.read(opportunityRepositoryProvider).updateOpportunity(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('Opportunity updated!',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            ]),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update: $e',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
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
              _sectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _glassTextField(
                controller: _titleController,
                hintText: 'Opportunity Title',
                prefixIcon: Icons.work_outline,
                required: true,
              ),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: _glassDropdown(
                    label: 'Category',
                    value: _selectedCategory,
                    items: _categories,
                    onChanged: (v) => setState(() => _selectedCategory = v!),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _glassDropdown(
                    label: 'Type',
                    value: _selectedType,
                    items: _types,
                    onChanged: (v) => setState(() => _selectedType = v!),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              _glassDropdown(
                label: 'Location',
                value: _selectedLocation,
                items: _locations,
                onChanged: (v) => setState(() => _selectedLocation = v!),
              ),
              const SizedBox(height: 16),
              _glassTextField(
                controller: _salaryController,
                hintText: 'Compensation (e.g., \$500/month or Unpaid)',
                prefixIcon: Icons.attach_money,
              ),
              const SizedBox(height: 32),
              _sectionTitle('Description'),
              const SizedBox(height: 16),
              _glassTextField(
                controller: _descriptionController,
                hintText: 'Describe the role...',
                prefixIcon: Icons.description_outlined,
                maxLines: 5,
                required: true,
              ),
              const SizedBox(height: 32),
              _sectionTitle('Requirements'),
              const SizedBox(height: 16),
              _addItemField(
                controller: _reqInputController,
                hintText: 'Add a requirement...',
                items: _requirements,
                onAdd: () {
                  if (_reqInputController.text.trim().isNotEmpty) {
                    setState(() {
                      _requirements.add(_reqInputController.text.trim());
                      _reqInputController.clear();
                    });
                  }
                },
                onRemove: (i) => setState(() => _requirements.removeAt(i)),
              ),
              const SizedBox(height: 32),
              _sectionTitle('Benefits'),
              const SizedBox(height: 16),
              _addItemField(
                controller: _benInputController,
                hintText: 'Add a benefit...',
                items: _benefits,
                onAdd: () {
                  if (_benInputController.text.trim().isNotEmpty) {
                    setState(() {
                      _benefits.add(_benInputController.text.trim());
                      _benInputController.clear();
                    });
                  }
                },
                onRemove: (i) => setState(() => _benefits.removeAt(i)),
              ),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _handleSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.darkRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2),
                        )
                      : Text('Save Changes',
                          style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white)),
                ),
              ),
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
      title: Text('Edit Opportunity',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
      centerTitle: true,
    );
  }

  Widget _sectionTitle(String title) =>
      Text(title, style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));

  Widget _glassTextField({
    required TextEditingController controller,
    required String hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    bool required = false,
  }) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty) ? 'This field is required' : null
            : null,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppColors.darkRed) : null,
          border: InputBorder.none,
          errorStyle: const TextStyle(color: Color(0xFFFF6B6B)),
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _glassDropdown({
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
          items: items
              .map((item) => DropdownMenuItem<String>(value: item, child: Text(item)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _addItemField({
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
                    hintStyle:
                        AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                    Text(items[index],
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
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
}
