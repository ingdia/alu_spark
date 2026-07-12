import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class OpportunityDetailScreen extends ConsumerStatefulWidget {
  final Opportunity opportunity;
  const OpportunityDetailScreen({super.key, required this.opportunity});

  @override
  ConsumerState<OpportunityDetailScreen> createState() =>
      _OpportunityDetailScreenState();
}

class _OpportunityDetailScreenState
    extends ConsumerState<OpportunityDetailScreen> {
  bool _bookmarked = false;

  static const String _description =
      'We are looking for a passionate and skilled individual to join our growing team. You will work on cutting-edge projects, collaborate with a diverse group of professionals, and have the opportunity to make a real impact. This role offers a unique chance to grow your skills and contribute to meaningful work.';

  static const List<String> _requirements = [
    'Currently enrolled in a university',
    'Strong communication skills',
    'Basic knowledge of Flutter or React',
    'Ability to work in a team',
    'Self-motivated & proactive',
  ];

  static const List<Map<String, dynamic>> _benefits = [
    {'icon': Icons.schedule_rounded, 'text': 'Flexible working hours'},
    {'icon': Icons.home_work_rounded, 'text': 'Remote work options'},
    {'icon': Icons.star_rounded, 'text': 'Mentorship from industry experts'},
    {'icon': Icons.workspace_premium_rounded, 'text': 'Certificate of completion'},
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildSliverHeader(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(),
                      const SizedBox(height: 16),
                      _buildMetaChips(),
                      const SizedBox(height: 28),
                      _buildSection('About the Role', _buildDescription()),
                      const SizedBox(height: 28),
                      _buildSection('Requirements', _buildRequirements()),
                      const SizedBox(height: 28),
                      _buildSection('What We Offer', _buildBenefits()),
                      SizedBox(height: bottomPadding + 96),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildApplyBar(context, bottomPadding),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.darkBlue,
      leading: Padding(
        padding: const EdgeInsets.all(10),
        child: GlassmorphicContainer(
          blur: 12,
          borderRadius: 12,
          padding: EdgeInsets.zero,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 16),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: GlassmorphicContainer(
            blur: 12,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: Icon(
                _bookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: _bookmarked ? AppColors.darkRed : AppColors.white,
                size: 20,
              ),
              onPressed: () => setState(() => _bookmarked = !_bookmarked),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 10, top: 10, bottom: 10),
          child: GlassmorphicContainer(
            blur: 12,
            borderRadius: 12,
            padding: EdgeInsets.zero,
            child: IconButton(
              icon: const Icon(Icons.share_outlined, color: AppColors.white, size: 20),
              onPressed: () {},
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/detail_bg.jpg',
              fit: BoxFit.cover,
              errorBuilder: (_, __, _) => Container(
                decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.45, 1.0],
                  colors: [Color(0x330B132B), Color(0x770B132B), Color(0xFF0B132B)],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: AppColors.redGradient,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.darkRed.withValues(alpha: 0.45),
                          blurRadius: 14,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.account_balance_wallet,
                        color: AppColors.white, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.opportunity.startupName,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded,
                              color: AppColors.darkRed, size: 15),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Tech Startup • 11–50 employees',
                        style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.3),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.opportunity.title,
          style: AppTextStyles.headingLarge.copyWith(
            fontSize: 24,
            height: 1.2,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkRed.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.darkRed.withValues(alpha: 0.3)),
              ),
              child: Text(
                'ACTIVELY HIRING',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.darkRed,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.0,
                  height: 1.2,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Posted 2 days ago',
              style: AppTextStyles.bodyMedium.copyWith(fontSize: 12, height: 1.3),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetaChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _MetaChip(icon: Icons.location_on_rounded, label: 'Kigali, Rwanda'),
        _MetaChip(icon: Icons.work_rounded, label: 'Internship'),
        _MetaChip(icon: Icons.attach_money_rounded, label: '\$500–\$800/mo'),
        _MetaChip(icon: Icons.schedule_rounded, label: '3 months'),
      ],
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 18,
              decoration: BoxDecoration(
                gradient: AppColors.redGradient,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: AppTextStyles.headingMedium.copyWith(
                fontSize: 17,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        content,
      ],
    );
  }

  Widget _buildDescription() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 14,
      padding: const EdgeInsets.all(16),
      child: Text(
        _description,
        style: AppTextStyles.bodyMedium.copyWith(height: 1.65, fontSize: 14),
      ),
    );
  }

  Widget _buildRequirements() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _requirements.map((req) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.glassWhite,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.borderGlass),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: AppColors.darkRed,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                req,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.white,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBenefits() {
    return Column(
      children: _benefits.map((b) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: AppColors.redGradient,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(b['icon'] as IconData, color: AppColors.white, size: 15),
                ),
                const SizedBox(width: 12),
                Text(
                  b['text'] as String,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.white,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildApplyBar(BuildContext context, double bottomPadding) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPadding + 14),
      decoration: BoxDecoration(
        color: AppColors.darkBlue.withValues(alpha: 0.96),
        border: const Border(top: BorderSide(color: AppColors.borderGlass)),
      ),
      child: Row(
        children: [
          GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            child: const Icon(Icons.chat_bubble_outline_rounded,
                color: AppColors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: () {},
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  gradient: AppColors.redGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.darkRed.withValues(alpha: 0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Apply Now',
                      style: TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded,
                        color: AppColors.white, size: 17),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 10,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.darkRed, size: 14),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.white,
              fontSize: 13,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
