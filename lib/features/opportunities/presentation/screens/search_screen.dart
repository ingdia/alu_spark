import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/search_provider.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';

class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            _SearchHeader(onFilterTap: notifier.reset),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SearchBar(
                      query: state.query,
                      onChanged: notifier.setQuery,
                      onClear: () => notifier.setQuery(''),
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Categories'),
                    const SizedBox(height: 12),
                    _CategoryChips(
                      categories: state.categories,
                      selected: state.selectedCategory,
                      onSelect: notifier.setCategory,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Advanced Filters'),
                    const SizedBox(height: 12),
                    _AdvancedFilters(
                      state: state,
                      onLocationChanged: notifier.setLocation,
                      onTypeChanged: notifier.setType,
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(title: 'Results (${state.results.length})'),
                    const SizedBox(height: 12),
                    ...state.results.map((o) => Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: OpportunityCard(
                            opportunity: o,
                            onTap: () => Navigator.of(context).pushNamed(
                              RouteNames.opportunityDetail,
                              arguments: o,
                            ),
                          ),
                        )),
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
}

class _SearchHeader extends StatelessWidget {
  final VoidCallback onFilterTap;
  const _SearchHeader({required this.onFilterTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Search Opportunities',
              style: AppTextStyles.headingLarge.copyWith(color: AppColors.white)),
          GestureDetector(
            onTap: onFilterTap,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.glassWhite,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.borderGlass),
              ),
              child: const Icon(Icons.tune, color: AppColors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatefulWidget {
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  const _SearchBar({
    required this.query,
    required this.onChanged,
    required this.onClear,
  });

  @override
  State<_SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<_SearchBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              controller: _controller,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'Search roles, startups, or skills...',
                hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: widget.onChanged,
            ),
          ),
          if (_controller.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
              onPressed: () {
                _controller.clear();
                widget.onClear();
              },
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final String selected;
  final ValueChanged<String> onSelect;

  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selected == category;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () => onSelect(category),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
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
}

class _AdvancedFilters extends StatelessWidget {
  final SearchState state;
  final ValueChanged<String> onLocationChanged;
  final ValueChanged<String> onTypeChanged;

  const _AdvancedFilters({
    required this.state,
    required this.onLocationChanged,
    required this.onTypeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      blur: 10,
      borderRadius: 16,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _FilterDropdown(
            label: 'Location',
            icon: Icons.location_on_outlined,
            value: state.selectedLocation,
            items: state.locations,
            onChanged: (v) => onLocationChanged(v!),
          ),
          const Divider(color: AppColors.borderGlass, height: 24),
          _FilterDropdown(
            label: 'Job Type',
            icon: Icons.work_outline,
            value: state.selectedType,
            items: state.types,
            onChanged: (v) => onTypeChanged(v!),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _FilterDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.darkRed, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              dropdownColor: AppColors.darkBlueLight,
              style: AppTextStyles.bodyLarge.copyWith(color: AppColors.white),
              icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.white),
              items: items
                  .map((item) => DropdownMenuItem(
                        value: item,
                        child: Text(item,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.white)),
                      ))
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
