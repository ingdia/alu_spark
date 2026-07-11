import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/constants/dummy_data.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  
  String _selectedCategory = 'All';
  String _selectedLocation = 'Anywhere';
  String _selectedType = 'Any';

  // Using final for lists to align with project conventions
  final List<String> _categories = ['All', 'Tech', 'Design', 'Marketing', 'Business', 'Finance'];
  final List<String> _locations = ['Anywhere', 'Kigali', 'Remote', 'Nairobi', 'Cape Town'];
  final List<String> _types = ['Any', 'Internship', 'Part-time', 'Full-time', 'Freelance'];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSearchBar(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Categories'),
                    const SizedBox(height: 12),
                    _buildCategoryChips(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Advanced Filters'),
                    const SizedBox(height: 12),
                    _buildAdvancedFilters(),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Results (${DummyData.recentOpportunities.length})'),
                    const SizedBox(height: 12),
                    _buildSearchResults(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Search Opportunities',
            style: AppTextStyles.headingLarge.copyWith(color: AppColors.white),
          ),
          GestureDetector(
            onTap: () {
              // TODO: Open advanced filter modal or reset filters
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGlass),
              ),
              child: const Icon(
                Icons.tune,
                color: AppColors.white,
                size: 24,
              ),
            ),
          ),
        ],
      ),
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
                hintText: 'Search roles, startups, or skills...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                // TODO: Trigger search provider
                setState(() {}); // Rebuild to show/hide clear icon
              },
            ),
          ),
          if (_searchController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                _searchController.clear();
                // TODO: Trigger search provider
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

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedCategory = category;
                });
                // TODO: Trigger search provider
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
                  category,
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

  Widget _buildAdvancedFilters() {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildFilterDropdown(
            'Location', 
            _selectedLocation, 
            _locations, 
            Icons.location_on_outlined, 
            (val) {
              setState(() => _selectedLocation = val!);
              // TODO: Trigger search provider
            }
          ),
          const Divider(color: AppColors.borderGlass, height: 24),
          _buildFilterDropdown(
            'Job Type', 
            _selectedType, 
            _types, 
            Icons.work_outline, 
            (val) {
              setState(() => _selectedType = val!);
              // TODO: Trigger search provider
            }
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown(
    String label, 
    String currentValue, 
    List<String> items, 
    IconData icon, 
    ValueChanged<String?> onChanged
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: currentValue,
              dropdownColor: AppColors.darkBlueLight,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item, 
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.white)
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Column(
      children: DummyData.recentOpportunities.map((o) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: OpportunityCard(
            title: o['title'],
            startup: o['startup'],
            location: o['location'],
            type: o['type'],
            logo: o['logo'],
            postedDays: o['postedDays'],
          ),
        );
      }).toList(),
    );
  }
}