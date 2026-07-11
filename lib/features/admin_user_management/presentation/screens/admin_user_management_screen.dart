import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class AdminUserManagementScreen extends ConsumerStatefulWidget {
  const AdminUserManagementScreen({super.key});

  @override
  ConsumerState<AdminUserManagementScreen> createState() => _AdminUserManagementScreenState();
}

class _AdminUserManagementScreenState extends ConsumerState<AdminUserManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  
  // Using final for lists to align with project conventions
  final List<String> _filters = ['All', 'Students', 'Founders', 'Admins'];

  final List<Map<String, dynamic>> _users = [
    {
      'name': 'Alex Johnson',
      'email': 'alex.johnson@alu.edu',
      'role': 'Student',
      'joinDate': 'Jan 15, 2026',
      'status': 'Active',
      'color': AppColors.darkRed,
    },
    {
      'name': 'John Doe',
      'email': 'john@techstart.com',
      'role': 'Founder',
      'joinDate': 'Mar 20, 2026',
      'status': 'Active',
      'color': AppColors.darkRedLight,
    },
    {
      'name': 'Sarah Lee',
      'email': 'sarah.lee@alu.edu',
      'role': 'Student',
      'joinDate': 'Feb 10, 2026',
      'status': 'Active',
      'color': AppColors.darkRed,
    },
    {
      'name': 'Jane Smith',
      'email': 'jane@finflow.com',
      'role': 'Founder',
      'joinDate': 'Apr 05, 2026',
      'status': 'Inactive',
      'color': AppColors.textSecondary,
    },
    {
      'name': 'Admin User',
      'email': 'admin@aluspark.com',
      'role': 'Admin',
      'joinDate': 'Jan 01, 2026',
      'status': 'Active',
      'color': AppColors.lightGray,
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchBar(),
            const SizedBox(height: 20),
            _buildFilterTabs(),
            const SizedBox(height: 20),
            _buildSectionTitle('All Users (${_users.length})'),
            const SizedBox(height: 16),
            _buildUsersList(),
            const SizedBox(height: 20),
          ],
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
        'User Management',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search users by name or email...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Trigger provider to search users
                setState(() {});
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                _searchController.clear();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                });
                // TODO: Trigger provider to filter users
              },
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildUsersList() {
    // In a real app, we would filter _users based on _selectedFilter and _searchController.text
    return Column(
      children: _users.map((user) => _buildUserCard(user)).toList(),
    );
  }

  Widget _buildUserCard(Map<String, dynamic> user) {
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
                CircleAvatar(
                  backgroundColor: (user['color'] as Color).withOpacity(0.2),
                  child: Text(
                    (user['name'] as String).substring(0, 1),
                    style: AppTextStyles.bodyLarge.copyWith(color: user['color'] as Color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user['name'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user['email'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (user['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    user['role'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: user['color'] as Color,
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
              children: [
                const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Joined ${user['joinDate']}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: user['status'] == 'Active' 
                        ? AppColors.darkRedLight.withOpacity(0.2) 
                        : AppColors.textSecondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: user['status'] == 'Active' 
                              ? AppColors.darkRedLight 
                              : AppColors.textSecondary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        user['status'] as String,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: user['status'] == 'Active' 
                              ? AppColors.darkRedLight 
                              : AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to user profile
                    },
                    icon: const Icon(Icons.person_outline, size: 18),
                    label: Text(
                      'View Profile',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderGlass),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.glassWhite,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderGlass),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.more_vert, color: AppColors.white, size: 20),
                    onPressed: () {
                      // TODO: Show action menu (edit role, deactivate, etc.)
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}