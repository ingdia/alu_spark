import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class AdminVerificationScreen extends ConsumerStatefulWidget {
  const AdminVerificationScreen({super.key});

  @override
  ConsumerState<AdminVerificationScreen> createState() => _AdminVerificationScreenState();
}

class _AdminVerificationScreenState extends ConsumerState<AdminVerificationScreen> {
  String _selectedFilter = 'Pending';
  
  // Using final for lists to align with project conventions
  final List<String> _filters = ['Pending', 'Approved', 'Rejected', 'All'];

  final List<Map<String, dynamic>> _verifications = [
    {
      'name': 'EcoTech Solutions',
      'founder': 'John Doe',
      'email': 'john@ecotech.com',
      'industry': 'GreenTech',
      'date': 'Jul 10, 2026',
      'status': 'Pending',
      'color': AppColors.darkRed,
      'description': 'Sustainable technology solutions for African markets',
    },
    {
      'name': 'FinFlow',
      'founder': 'Jane Smith',
      'email': 'jane@finflow.com',
      'industry': 'FinTech',
      'date': 'Jul 08, 2026',
      'status': 'Pending',
      'color': AppColors.darkRed,
      'description': 'Financial management tools for students and young professionals',
    },
    {
      'name': 'HealthPlus',
      'founder': 'Alice Brown',
      'email': 'alice@healthplus.com',
      'industry': 'HealthTech',
      'date': 'Jul 05, 2026',
      'status': 'Approved',
      'color': AppColors.darkRedLight,
      'description': 'Telemedicine platform connecting patients with healthcare providers',
    },
    {
      'name': 'EduConnect',
      'founder': 'Bob Wilson',
      'email': 'bob@educonnect.com',
      'industry': 'EdTech',
      'date': 'Jul 01, 2026',
      'status': 'Rejected',
      'color': AppColors.textSecondary,
      'description': 'Peer-to-peer learning platform for university students',
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
            _buildVerificationsList(),
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
        'Startup Verification',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSummaryStats() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildStatCard('Pending', '7', Icons.hourglass_empty)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Approved', '42', Icons.check_circle)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildStatCard('Rejected', '15', Icons.cancel)),
            const SizedBox(width: 12),
            Expanded(child: _buildStatCard('Total', '64', Icons.business)),
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
              color: AppColors.darkRed.withOpacity(0.2),
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
                // TODO: Trigger provider to filter verifications
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

  Widget _buildVerificationsList() {
    // In a real app, we would filter _verifications based on _selectedFilter
    return Column(
      children: _verifications.map((v) => _buildVerificationCard(v)).toList(),
    );
  }

  Widget _buildVerificationCard(Map<String, dynamic> v) {
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
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (v['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.business, color: v['color'] as Color, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        v['name'] as String,
                        style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'By ${v['founder']} • ${v['industry']}',
                        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (v['color'] as Color).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    v['status'] as String,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: v['color'] as Color,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              v['description'] as String,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(color: AppColors.borderGlass, height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: AppColors.textSecondary, size: 14),
                const SizedBox(width: 6),
                Text(
                  'Submitted ${v['date']}',
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
                      // TODO: Navigate to startup detail view
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.borderGlass),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: Text(
                      'View Details',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Trigger provider to approve startup
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
                      'Approve',
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