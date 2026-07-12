import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class ApplicationsReceivedScreen extends ConsumerStatefulWidget {
  const ApplicationsReceivedScreen({super.key});

  @override
  ConsumerState<ApplicationsReceivedScreen> createState() => _ApplicationsReceivedScreenState();
}

class _ApplicationsReceivedScreenState extends ConsumerState<ApplicationsReceivedScreen> {
  String _selectedFilter = 'All';
  
  // Using final for lists to align with project conventions
  final List<String> _filters = ['All', 'New', 'Shortlisted', 'Rejected'];

  final List<Map<String, dynamic>> _applications = [
    {
      'name': 'Alex Johnson',
      'role': 'Frontend Developer',
      'date': 'Jul 10, 2026',
      'status': 'New',
      'color': AppColors.darkRed,
      'gpa': '3.8',
    },
    {
      'name': 'Sarah Lee',
      'role': 'UI/UX Designer',
      'date': 'Jul 08, 2026',
      'status': 'Shortlisted',
      'color': AppColors.darkRedLight,
      'gpa': '3.9',
    },
    {
      'name': 'Mike Chen',
      'role': 'Marketing Intern',
      'date': 'Jul 05, 2026',
      'status': 'Reviewing',
      'color': AppColors.lightGray,
      'gpa': '3.5',
    },
    {
      'name': 'Emily Davis',
      'role': 'Data Analyst',
      'date': 'Jul 01, 2026',
      'status': 'Rejected',
      'color': AppColors.textSecondary,
      'gpa': '3.2',
    },
  ];

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
            _buildSummaryStats(),
            const SizedBox(height: 24),
            _buildFilterTabs(),
            const SizedBox(height: 16),
            _buildApplicationsList(),
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
        'Received Applications',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.filter_list, color: AppColors.white, size: 20),
              onPressed: () {
                // TODO: Open advanced filter modal
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Total', '24', Icons.list_alt)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('New', '8', Icons.fiber_new)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Shortlisted', '6', Icons.star_outline)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Rejected', '10', Icons.cancel_outlined)),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.darkRed.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppColors.darkRed, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
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
                // TODO: Trigger provider to filter applications
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

  Widget _buildApplicationsList() {
    // In a real app, we would filter _applications based on _selectedFilter
    return Column(
      children: _applications.map((app) => _buildApplicationCard(app)).toList(),
    );
  }

  Widget _buildApplicationCard(Map<String, dynamic> app) {
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
                  backgroundColor: (app['color'] as Color).withValues(alpha: 0.2),
                  child: Text(
                    (app['name'] as String).substring(0, 1),
                    style: AppTextStyles.bodyLarge.copyWith(color: app['color'] as Color),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        app['name'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Applied for ${app['role']}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (app['color'] as Color).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    app['status'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: app['color'] as Color,
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
                const Icon(Icons.school_outlined, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'GPA: ${app['gpa']}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  app['date'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      // TODO: Navigate to student profile
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderGlass),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'View Profile',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Trigger provider to shortlist or message
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'Shortlist',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
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
}