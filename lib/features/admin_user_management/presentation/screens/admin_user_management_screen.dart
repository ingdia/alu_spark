import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/features/admin_user_management/presentation/providers/user_provider.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Student', 'Founder', 'Admin'];

  @override
  Widget build(BuildContext context) {
    final usersAsync = _selectedFilter == 'All'
        ? ref.watch(usersProvider)
        : ref.watch(usersByRoleProvider(_selectedFilter.toLowerCase()));

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
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
          'User Management',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildFilterTabs(),
          Expanded(
            child: usersAsync.when(
              loading: () => const LoadingWidget(message: 'Fetching users...'),
              error: (error, _) => ErrorStateWidget(
                message: error.toString(),
                onRetry: () => ref.invalidate(usersProvider),
              ),
              data: (users) => _buildContent(users),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => setState(() => _selectedFilter = filter),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.darkRed : AppColors.glassWhite,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppColors.darkRed : AppColors.borderGlass,
                  ),
                ),
                child: Text(
                  filter,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: isSelected ? AppColors.white : AppColors.textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(List<User> users) {
    if (users.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.people_outline,
        title: 'No Users Found',
        description: 'There are no users matching this filter yet.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return _buildUserCard(user);
      },
    );
  }

  Widget _buildUserCard(User user) {
    final roleColor = user.role == UserRole.admin ? AppColors.darkRed 
        : user.role == UserRole.founder ? AppColors.darkRedLight 
        : AppColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 16,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: roleColor.withValues(alpha: 0.2),
                  child: Text(
                    user.fullName.isNotEmpty ? user.fullName[0] : '?',
                    style: AppTextStyles.bodyLarge.copyWith(color: roleColor),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.email,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user.role.name.capitalize(),
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: roleColor,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.borderGlass, height: 1),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      user.isEmailVerified ? Icons.verified : Icons.email_outlined,
                      color: user.isEmailVerified ? AppColors.darkRed : AppColors.textSecondary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      user.isEmailVerified ? 'Verified' : 'Unverified',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () => _showUserDialog(context, user),
                  child: Text(
                    'Manage',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.darkRed,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
  void _showUserDialog(BuildContext context, User user) {
    final roleColor = user.role == UserRole.admin
        ? AppColors.darkRed
        : user.role == UserRole.founder
            ? AppColors.darkRedLight
            : AppColors.textSecondary;
    final joinedDate =
        '${user.createdAt.day}/${user.createdAt.month}/${user.createdAt.year}';

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.darkBlueLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: roleColor.withValues(alpha: 0.2),
                    backgroundImage: user.profileImageUrl != null
                        ? NetworkImage(user.profileImageUrl!)
                        : null,
                    child: user.profileImageUrl == null
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName[0] : '?',
                            style: AppTextStyles.headingMedium.copyWith(color: roleColor),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName,
                            style: AppTextStyles.headingMedium.copyWith(
                                color: AppColors.white, fontSize: 16)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: roleColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.role.name.capitalize(),
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: roleColor, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(color: AppColors.borderGlass, height: 1),
              const SizedBox(height: 16),
              _dialogRow(Icons.email_outlined, 'Email', user.email),
              if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
                _dialogRow(Icons.phone_outlined, 'Phone', user.phoneNumber!),
              if (user.university != null && user.university!.isNotEmpty)
                _dialogRow(Icons.school_outlined, 'University', user.university!),
              if (user.major != null && user.major!.isNotEmpty)
                _dialogRow(Icons.book_outlined, 'Major', user.major!),
              _dialogRow(
                user.isEmailVerified ? Icons.verified : Icons.email_outlined,
                'Verification',
                user.isEmailVerified ? 'Email verified' : 'Not verified',
              ),
              _dialogRow(Icons.calendar_today_outlined, 'Joined', joinedDate),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.darkRed.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Close',
                      style: AppTextStyles.bodyLarge
                          .copyWith(color: AppColors.darkRed)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dialogRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.darkRed, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.white, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

extension StringCasingExtension on String {
  String capitalize() => '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
}
