import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/auth/presentation/widgets/auth_widgets.dart';

class ProfileSetupScreen extends StatefulWidget {
  final String name;
  final String email;

  const ProfileSetupScreen({super.key, required this.name, required this.email});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  final _phoneController = TextEditingController();

  // Role
  String _role = 'student'; // 'student' or 'founder'

  // Student fields
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  final _skillInputController = TextEditingController();
  final List<String> _skills = [];

  // Founder fields
  final _startupNameController = TextEditingController();
  final _startupTaglineController = TextEditingController();
  String _industry = 'Technology';

  // Photo
  File? _photo;
  bool _isLoading = false;

  static const _industries = [
    'Technology', 'FinTech', 'HealthTech', 'EdTech',
    'AgriTech', 'E-Commerce', 'Social Impact', 'Other',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.name);
    _emailController = TextEditingController(text: widget.email);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _skillInputController.dispose();
    _startupNameController.dispose();
    _startupTaglineController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  void _addSkill() {
    final s = _skillInputController.text.trim();
    if (s.isNotEmpty && !_skills.contains(s)) {
      setState(() => _skills.add(s));
      _skillInputController.clear();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == 'student' && _skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Please add at least one skill'),
        backgroundColor: AppColors.darkRed,
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final uid = fb.FirebaseAuth.instance.currentUser!.uid;

      // Upload photo if selected
      String? photoUrl;
      if (_photo != null) {
        final ref = FirebaseStorage.instance.ref('profile_photos/$uid.jpg');
        await ref.putFile(_photo!);
        photoUrl = await ref.getDownloadURL();
      }

      final batch = FirebaseFirestore.instance.batch();
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);

      // Base user update
      batch.update(userRef, {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'role': _role,
        'photoUrl': photoUrl,
        'profileComplete': true,
      });

      if (_role == 'student') {
        final studentRef = FirebaseFirestore.instance.collection('students').doc(uid);
        batch.set(studentRef, {
          'id': uid,
          'fullName': _nameController.text.trim(),
          'email': widget.email,
          'phone': _phoneController.text.trim(),
          'university': _universityController.text.trim(),
          'major': _majorController.text.trim(),
          'skills': _skills,
          'photoUrl': photoUrl,
          'bio': '',
          'education': [],
          'experience': [],
          'createdAt': FieldValue.serverTimestamp(),
        });
      } else {
        final startupRef = FirebaseFirestore.instance.collection('startups').doc(uid);
        batch.set(startupRef, {
          'uid': uid,
          'founderName': _nameController.text.trim(),
          'email': widget.email,
          'phone': _phoneController.text.trim(),
          'startupName': _startupNameController.text.trim(),
          'tagline': _startupTaglineController.text.trim(),
          'industry': _industry,
          'photoUrl': photoUrl,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          AppRouter.generateRoute(const RouteSettings(name: RouteNames.home)),
          (_) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.darkRed),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                Text('Set Up Your Profile',
                    style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
                const SizedBox(height: 6),
                Text('Complete your profile to get started',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
                const SizedBox(height: 28),

                // Photo picker
                Center(
                  child: GestureDetector(
                    onTap: _pickPhoto,
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: AppColors.glassWhite,
                          backgroundImage: _photo != null ? FileImage(_photo!) : null,
                          child: _photo == null
                              ? const Icon(Icons.person_outline, color: AppColors.textSecondary, size: 40)
                              : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: AppColors.white, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Center(
                  child: Text('Photo (optional)',
                      style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary, fontSize: 12)),
                ),
                const SizedBox(height: 24),

                // Name — pre-filled, read-only
                _ReadOnlyField(
                  label: _nameController.text,
                  icon: Icons.person_outline,
                  hint: 'Full Name',
                ),
                const SizedBox(height: 14),

                // Email — pre-filled, read-only
                _ReadOnlyField(
                  label: widget.email,
                  icon: Icons.email_outlined,
                  hint: 'Email',
                ),
                const SizedBox(height: 14),

                // Phone
                AuthTextField(
                  controller: _phoneController,
                  hintText: 'Phone Number *',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) => v == null || v.isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: 24),

                // Role selector
                Text('I am a...',
                    style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _RoleChip(
                        label: 'Student',
                        icon: Icons.school_outlined,
                        selected: _role == 'student',
                        onTap: () => setState(() => _role = 'student'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _RoleChip(
                        label: 'Founder',
                        icon: Icons.rocket_launch_outlined,
                        selected: _role == 'founder',
                        onTap: () => setState(() => _role = 'founder'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Role-specific fields
                if (_role == 'student') ..._buildStudentFields(),
                if (_role == 'founder') ..._buildFounderFields(),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      disabledBackgroundColor: AppColors.glassWhite,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? const SizedBox(width: 22, height: 22,
                            child: CircularProgressIndicator(color: AppColors.white, strokeWidth: 2))
                        : Text('Complete & Go to Dashboard',
                            style: AppTextStyles.bodyLarge.copyWith(
                                color: AppColors.white, fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildStudentFields() {
    return [
      AuthTextField(
        controller: _universityController,
        hintText: 'University *',
        prefixIcon: Icons.account_balance_outlined,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _majorController,
        hintText: 'Major / Program *',
        prefixIcon: Icons.school_outlined,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 14),
      Text('Skills *',
          style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.white, fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
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
                  hintText: 'e.g. Flutter, Python, Design...',
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
      if (_skills.isNotEmpty) ...[
        const SizedBox(height: 10),
        Wrap(
          spacing: 8, runSpacing: 8,
          children: _skills.map((s) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: AppColors.redGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(s, style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white, fontWeight: FontWeight.w600)),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => setState(() => _skills.remove(s)),
                  child: const Icon(Icons.close, color: AppColors.white, size: 14),
                ),
              ],
            ),
          )).toList(),
        ),
      ],
    ];
  }

  List<Widget> _buildFounderFields() {
    return [
      AuthTextField(
        controller: _startupNameController,
        hintText: 'Startup Name *',
        prefixIcon: Icons.business_rounded,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 14),
      AuthTextField(
        controller: _startupTaglineController,
        hintText: 'Tagline *',
        prefixIcon: Icons.lightbulb_outline,
        validator: (v) => v == null || v.isEmpty ? 'Required' : null,
      ),
      const SizedBox(height: 14),
      GlassmorphicContainer(
        blur: 10,
        borderRadius: 12,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: DropdownButtonFormField<String>(
          value: _industry,
          dropdownColor: AppColors.darkBlueLight,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.category_rounded, color: AppColors.darkRed, size: 18),
            labelText: 'Industry',
            labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary, fontSize: 12),
            border: InputBorder.none,
          ),
          items: _industries.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
          )).toList(),
          onChanged: (v) => setState(() => _industry = v!),
        ),
      ),
    ];
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String hint;

  const _ReadOnlyField({required this.label, required this.icon, required this.hint});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, color: AppColors.darkRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
          ),
          const Icon(Icons.lock_outline, color: AppColors.textSecondary, size: 16),
        ],
      ),
    );
  }
}

class _RoleChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _RoleChip({
    required this.label, required this.icon,
    required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.darkRed : AppColors.borderGlass,
            width: selected ? 2 : 1,
          ),
          color: selected ? AppColors.darkRed.withValues(alpha: 0.12) : AppColors.glassWhite,
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.darkRed : AppColors.textSecondary, size: 26),
            const SizedBox(height: 6),
            Text(label, style: AppTextStyles.bodyMedium.copyWith(
              color: selected ? AppColors.white : AppColors.textSecondary,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
            )),
          ],
        ),
      ),
    );
  }
}
