import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  String _selectedFilter = 'All';
  
  // Using final for lists to align with project conventions
  final List<String> _filters = ['All', 'Unread', 'Applications', 'Messages', 'System'];

  final List<Map<String, dynamic>> _notifications = [
    {
      'type': 'application',
      'title': 'Application Status Updated',
      'description': 'Your application to Frontend Developer at TechStart has been moved to Interview stage.',
      'time': '5 min ago',
      'unread': true,
      'icon': Icons.work_outline,
      'color': AppColors.darkRed,
    },
    {
      'type': 'message',
      'title': 'New Message from John Doe',
      'description': 'Thanks for applying! We reviewed your portfolio and would love to schedule an interview.',
      'time': '15 min ago',
      'unread': true,
      'icon': Icons.message_outlined,
      'color': AppColors.darkRedLight,
    },
    {
      'type': 'application',
      'title': 'New Opportunity Match',
      'description': 'DesignHub just posted a UI/UX Designer position that matches your skills.',
      'time': '1 hour ago',
      'unread': true,
      'icon': Icons.star_outline,
      'color': AppColors.darkRed,
    },
    {
      'type': 'system',
      'title': 'Profile Verification Complete',
      'description': 'Your student profile has been successfully verified. You can now apply to opportunities.',
      'time': '3 hours ago',
      'unread': false,
      'icon': Icons.verified_outlined,
      'color': AppColors.lightGray,
    },
    {
      'type': 'message',
      'title': 'New Message from DesignHub Team',
      'description': 'The design mockups look great. Can we schedule a call to discuss the next steps?',
      'time': '5 hours ago',
      'unread': false,
      'icon': Icons.message_outlined,
      'color': AppColors.darkRedLight,
    },
    {
      'type': 'application',
      'title': 'Application Accepted',
      'description': 'Congratulations! Your application to Marketing Intern at GrowthLab has been accepted.',
      'time': '1 day ago',
      'unread': false,
      'icon': Icons.check_circle_outline,
      'color': AppColors.darkRed,
    },
    {
      'type': 'system',
      'title': 'Platform Update',
      'description': 'We\'ve added new features to help you find opportunities faster. Check out the updated search filters!',
      'time': '2 days ago',
      'unread': false,
      'icon': Icons.info_outline,
      'color': AppColors.textSecondary,
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
            _buildFilterTabs(),
            const SizedBox(height: 20),
            _buildSectionTitle('Notifications (${_notifications.length})'),
            const SizedBox(height: 16),
            _buildNotificationsList(),
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
        'Notifications',
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
            child: TextButton(
              onPressed: () {
                // TODO: Mark all as read
              },
              child: Text(
                'Mark All Read',
                style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white),
              ),
            ),
          ),
        ),
      ],
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
                // TODO: Trigger provider to filter notifications
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

  Widget _buildNotificationsList() {
    // In a real app, we would filter _notifications based on _selectedFilter
    return Column(
      children: _notifications.map((notif) => _buildNotificationCard(notif)).toList(),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notif) {
    final bool isUnread = notif['unread'] as bool;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // TODO: Mark as read and navigate to relevant screen
          setState(() {
            notif['unread'] = false;
          });
        },
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (notif['color'] as Color).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notif['icon'] as IconData,
                  color: notif['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            notif['title'] as String,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.darkRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notif['description'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notif['time'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: isUnread ? AppColors.darkRed : AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}