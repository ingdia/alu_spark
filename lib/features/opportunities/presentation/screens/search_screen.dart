import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/features/opportunities/presentation/providers/search_provider.dart';
import 'package:alu_spark/features/opportunities/presentation/widgets/opportunity_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(searchProvider).query,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit(String value) {
    ref.read(searchProvider.notifier).commitSearch(value);
  }

  void _applyRecent(String query) {
    _controller.text = query;
    _controller.selection =
        TextSelection.collapsed(offset: query.length);
    ref.read(searchProvider.notifier).commitSearch(query);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchProvider);
    final notifier = ref.read(searchProvider.notifier);
    final results = state.results;
    final showRecent =
        state.query.isEmpty && state.recentSearches.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      body: SafeArea(
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Search Opportunities',
                      style: AppTextStyles.headingLarge
                          .copyWith(color: AppColors.white)),
                  _SortButton(
                    current: state.sortOrder,
                    onSelected: notifier.setSortOrder,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Search bar ───────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GlassmorphicContainer(
                blur: 10,
                borderRadius: 16,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        color: AppColors.textSecondary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        style: AppTextStyles.bodyLarge
                            .copyWith(color: AppColors.white),
                        decoration: InputDecoration(
                          hintText: 'Search roles, startups, or skills...',
                          hintStyle: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.textSecondary),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onChanged: notifier.setQuery,
                        onSubmitted: _onSubmit,
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    if (state.query.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear,
                            color: AppColors.textSecondary, size: 20),
                        onPressed: () {
                          _controller.clear();
                          notifier.setQuery('');
                        },
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Filters row ──────────────────────────────────────────────
            _FiltersRow(state: state, notifier: notifier),
            const SizedBox(height: 8),

            // ── Body ─────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent searches
                    if (showRecent) ...[
                      _RecentSearches(
                        searches: state.recentSearches,
                        onTap: _applyRecent,
                        onRemove: notifier.removeRecentSearch,
                        onClearAll: notifier.clearRecentSearches,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Category chips
                    _SectionTitle(title: 'Categories'),
                    const SizedBox(height: 12),
                    _CategoryChips(
                      categories: state.categories,
                      selected: state.selectedCategory,
                      onSelect: notifier.setCategory,
                    ),
                    const SizedBox(height: 24),

                    // Advanced filters
                    _SectionTitle(title: 'Filters'),
                    const SizedBox(height: 12),
                    _AdvancedFilters(state: state, notifier: notifier),
                    const SizedBox(height: 24),

                    // Results header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _SectionTitle(
                          title: state.query.isEmpty && !state.hasActiveFilters
                              ? 'All Opportunities'
                              : 'Results',
                        ),
                        Row(
                          children: [
                            Text(
                              '${results.length} found',
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.textSecondary),
                            ),
                            if (state.hasActiveFilters) ...[
                              const SizedBox(width: 8),
                              GestureDetector(
                                onTap: notifier.reset,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.darkRed.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                        color: AppColors.darkRed
                                            .withValues(alpha: 0.4)),
                                  ),
                                  child: Text('Clear',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                          color: AppColors.darkRed,
                                          fontSize: 11)),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Results list or empty state
                    if (results.isEmpty)
                      EmptyStateWidget(
                        icon: Icons.search_off_outlined,
                        title: 'No Results Found',
                        description: state.query.isNotEmpty
                            ? 'No opportunities match "${state.query}". Try different keywords or adjust your filters.'
                            : 'No opportunities match your current filters.',
                      )
                    else
                      ...results.map((o) => Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: OpportunityCard(
                              opportunity: o,
                              onTap: () {
                                notifier.commitSearch(state.query);
                                Navigator.of(context).pushNamed(
                                  RouteNames.opportunityDetail,
                                  arguments: o,
                                );
                              },
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

// ── Sort button ───────────────────────────────────────────────────────────────

class _SortButton extends StatelessWidget {
  final SearchSortOrder current;
  final ValueChanged<SearchSortOrder> onSelected;

  const _SortButton({required this.current, required this.onSelected});

  String get _label {
    switch (current) {
      case SearchSortOrder.newest:
        return 'Newest';
      case SearchSortOrder.oldest:
        return 'Oldest';
      case SearchSortOrder.mostApplicants:
        return 'Popular';
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<SearchSortOrder>(
      color: AppColors.darkBlueLight,
      onSelected: onSelected,
      child: GlassmorphicContainer(
        blur: 10,
        borderRadius: 20,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.sort, color: AppColors.white, size: 16),
            const SizedBox(width: 6),
            Text(_label,
                style:
                    AppTextStyles.bodyMedium.copyWith(color: AppColors.white)),
          ],
        ),
      ),
      itemBuilder: (_) => [
        _sortItem(SearchSortOrder.newest, 'Newest First', current),
        _sortItem(SearchSortOrder.oldest, 'Oldest First', current),
        _sortItem(SearchSortOrder.mostApplicants, 'Most Popular', current),
      ],
    );
  }

  PopupMenuItem<SearchSortOrder> _sortItem(
      SearchSortOrder value, String label, SearchSortOrder current) {
    final selected = current == value;
    return PopupMenuItem(
      value: value,
      child: Row(children: [
        Icon(Icons.check,
            size: 16,
            color: selected ? AppColors.darkRed : Colors.transparent),
        const SizedBox(width: 8),
        Text(label,
            style: AppTextStyles.bodyMedium.copyWith(
                color: selected ? AppColors.white : AppColors.textSecondary)),
      ]),
    );
  }
}

// ── Horizontal filter chips row ───────────────────────────────────────────────

class _FiltersRow extends StatelessWidget {
  final SearchState state;
  final SearchNotifier notifier;

  const _FiltersRow({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: [
          _FilterChip(
            label: state.selectedLocation == 'Anywhere'
                ? 'Location'
                : state.selectedLocation,
            icon: Icons.location_on_outlined,
            active: state.selectedLocation != 'Anywhere',
            items: state.locations,
            onSelected: notifier.setLocation,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: state.selectedType == 'Any' ? 'Type' : state.selectedType,
            icon: Icons.work_outline,
            active: state.selectedType != 'Any',
            items: state.types,
            onSelected: notifier.setType,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label:
                state.selectedSalary == 'Any' ? 'Salary' : state.selectedSalary,
            icon: Icons.attach_money,
            active: state.selectedSalary != 'Any',
            items: state.salaryRanges,
            onSelected: notifier.setSalary,
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final List<String> items;
  final ValueChanged<String> onSelected;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.active,
    required this.items,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: AppColors.darkBlueLight,
      onSelected: onSelected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.darkRed : AppColors.glassWhite,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: active ? AppColors.darkRed : AppColors.borderGlass,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 14,
                color: active ? AppColors.white : AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: active ? AppColors.white : AppColors.textSecondary,
                  fontSize: 12,
                )),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down,
                size: 14,
                color: active ? AppColors.white : AppColors.textSecondary),
          ],
        ),
      ),
      itemBuilder: (_) => items
          .map((item) => PopupMenuItem(
                value: item,
                child: Text(item,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.white)),
              ))
          .toList(),
    );
  }
}

// ── Recent searches ───────────────────────────────────────────────────────────

class _RecentSearches extends StatelessWidget {
  final List<String> searches;
  final ValueChanged<String> onTap;
  final ValueChanged<String> onRemove;
  final VoidCallback onClearAll;

  const _RecentSearches({
    required this.searches,
    required this.onTap,
    required this.onRemove,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Recent Searches',
                style:
                    AppTextStyles.headingMedium.copyWith(color: AppColors.white)),
            GestureDetector(
              onTap: onClearAll,
              child: Text('Clear all',
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.darkRed, fontSize: 12)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...searches.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GlassmorphicContainer(
                blur: 10,
                borderRadius: 12,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    const Icon(Icons.history,
                        color: AppColors.textSecondary, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => onTap(s),
                        child: Text(s,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.white)),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => onRemove(s),
                      child: const Icon(Icons.close,
                          color: AppColors.textSecondary, size: 16),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }
}

// ── Section title ─────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(title,
        style: AppTextStyles.headingMedium.copyWith(color: AppColors.white));
  }
}

// ── Category chips ────────────────────────────────────────────────────────────

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                    color: isSelected
                        ? AppColors.white
                        : AppColors.textSecondary,
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

// ── Advanced filters (location / type / salary dropdowns) ────────────────────

class _AdvancedFilters extends StatelessWidget {
  final SearchState state;
  final SearchNotifier notifier;

  const _AdvancedFilters({required this.state, required this.notifier});

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
            onChanged: (v) => notifier.setLocation(v!),
          ),
          const Divider(color: AppColors.borderGlass, height: 24),
          _FilterDropdown(
            label: 'Job Type',
            icon: Icons.work_outline,
            value: state.selectedType,
            items: state.types,
            onChanged: (v) => notifier.setType(v!),
          ),
          const Divider(color: AppColors.borderGlass, height: 24),
          _FilterDropdown(
            label: 'Salary',
            icon: Icons.attach_money,
            value: state.selectedSalary,
            items: state.salaryRanges,
            onChanged: (v) => notifier.setSalary(v!),
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
