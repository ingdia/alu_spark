import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Using final for lists to align with project conventions
  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'John Doe',
      'role': 'CEO at TechStart',
      'lastMessage': 'Thanks for applying! We reviewed your portfolio and would love to schedule an interview.',
      'time': '2m ago',
      'unread': 3,
      'color': AppColors.darkRed,
    },
    {
      'name': 'DesignHub Team',
      'role': 'Startup',
      'lastMessage': 'The design mockups look great. Can we schedule a call to discuss the next steps?',
      'time': '1h ago',
      'unread': 1,
      'color': AppColors.darkRedLight,
    },
    {
      'name': 'Sarah Lee',
      'role': 'Student',
      'lastMessage': 'Hey! Are you also working on the Flutter project? I had a question about state management.',
      'time': '3h ago',
      'unread': 0,
      'color': AppColors.lightGray,
    },
    {
      'name': 'GrowthLab',
      'role': 'Startup',
      'lastMessage': 'Welcome to the team! Your onboarding documents are ready.',
      'time': '1d ago',
      'unread': 0,
      'color': AppColors.textSecondary,
    },
    {
      'name': 'Mike Chen',
      'role': 'Frontend Developer',
      'lastMessage': 'Sure, I can help you with that React component. Let me send you the code.',
      'time': '2d ago',
      'unread': 0,
      'color': AppColors.borderGlass,
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
            _buildSectionTitle('Recent Conversations'),
            const SizedBox(height: 16),
            _buildConversationsList(),
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
        'Messages',
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
              icon: const Icon(Icons.edit_outlined, color: AppColors.white, size: 20),
              onPressed: () {
                // TODO: Open new chat dialog
              },
            ),
          ),
        ),
      ],
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
                hintText: 'Search conversations...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Trigger provider to search conversations
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
    );
  }

  Widget _buildConversationsList() {
    // In a real app, we would filter _conversations based on _searchController.text
    return Column(
      children: _conversations.map((conv) => _buildConversationCard(conv)).toList(),
    );
  }

  Widget _buildConversationCard(Map<String, dynamic> conv) {
    final bool hasUnread = (conv['unread'] as int) > 0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          // TODO: Navigate to chat detail screen
        },
        child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    backgroundColor: (conv['color'] as Color).withOpacity(0.2),
                    child: Text(
                      (conv['name'] as String).substring(0, 1),
                      style: AppTextStyles.headingMedium.copyWith(color: conv['color'] as Color),
                    ),
                  ),
                  if (hasUnread)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: AppColors.darkRed,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.darkBlue, width: 2),
                        ),
                        child: Text(
                          '${conv['unread']}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
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
                            conv['name'] as String,
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: AppColors.white,
                              fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          conv['time'] as String,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: hasUnread ? AppColors.darkRed : AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      conv['role'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      conv['lastMessage'] as String,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: hasUnread ? AppColors.white : AppColors.textSecondary,
                        fontWeight: hasUnread ? FontWeight.w500 : FontWeight.normal,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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