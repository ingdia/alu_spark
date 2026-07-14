import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

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

  // Using final for lists to align with project conventions
  final List<String> _categories = ['Tech', 'Design', 'Marketing', 'Business', 'Finance'];
  final List<String> _locations = ['Kigali', 'Remote', 'Nairobi', 'Cape Town', 'Lagos'];
  final List<String> _types = ['Internship', 'Part-time', 'Full-time', 'Freelance'];

  final List<String> _requirements = [];
  final List<String> _benefits = [];
  
  bool _isPosting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _reqInputController.dispose();
    _benInputController.dispose();
    super.dispose();
  }

  Future<void> _handlePostOpportunity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isPosting = true);

    try {
      final authState = ref.read(authStateProvider);
      final currentUser = authState.value;
      if (currentUser == null) throw Exception('Not logged in');

      // Read startup info from Firestore for the logged-in founder
      final startupDoc = await FirebaseFirestore.instance
          .collection('startups')
          .doc(currentUser.id)
          .get();
      final startupData = startupDoc.data();
      final startupId = currentUser.id;
      final startupName = startupData?['startupName'] as String? ?? currentUser.fullName;

      final opportunity = Opportunity(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        startupId: startupId,
        startupName: startupName,
        category: _selectedCategory,
        location: _selectedLocation,
        type: _selectedType,
        salary: _salaryController.text.trim().isEmpty ? null : _salaryController.text.trim(),
        requirements: _requirements,
        benefits: _benefits,
        createdAt: DateTime.now(),
      );

      await ref.read(opportunityRepositoryProvider).createOpportunity(opportunity);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text('Opportunity posted successfully!',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
            ]),
            backgroundColor: const Color(0xFF1B5E20),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
        _titleController.clear();
        _descriptionController.clear();
        _salaryController.clear();
        setState(() { _requirements.clear(); _benefits.clear(); });
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Expanded(child: Text('Failed to post: $e',
                  style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white))),
            ]),
            backgroundColor: AppColors.darkRed,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
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
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 16),
              _buildGlassTextField(
                controller: _titleController,
                hintText: 'Opportunity Title (e.g., Frontend Developer)',
                prefixIcon: Icons.work_outline,
                required: true,
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
                required: true,
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
        onPressed: _isPosting ? null : _handlePostOpportunity,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.darkRed,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: _isPosting
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2,
                ),
              )
            : Text(
                'Post Opportunity',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              ),
      ),
    );
  }
}