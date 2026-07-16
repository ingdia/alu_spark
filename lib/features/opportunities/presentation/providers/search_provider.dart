import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

enum SearchSortOrder { newest, oldest, mostApplicants }

class SearchState {
  final String query;
  final String selectedCategory;
  final String selectedLocation;
  final String selectedType;
  final String selectedSalary;
  final SearchSortOrder sortOrder;
  final List<String> categories;
  final List<String> locations;
  final List<String> types;
  final List<String> salaryRanges;
  final List<Opportunity> allOpportunities;
  final List<String> recentSearches;

  const SearchState({
    this.query = '',
    this.selectedCategory = 'All',
    this.selectedLocation = 'Anywhere',
    this.selectedType = 'Any',
    this.selectedSalary = 'Any',
    this.sortOrder = SearchSortOrder.newest,
    this.categories = const ['All', 'Tech', 'Design', 'Marketing', 'Business', 'Finance'],
    this.locations = const ['Anywhere', 'Kigali', 'Remote', 'Nairobi', 'Cape Town', 'Lagos'],
    this.types = const ['Any', 'Internship', 'Part-time', 'Full-time', 'Freelance'],
    this.salaryRanges = const ['Any', 'Paid', 'Unpaid'],
    this.allOpportunities = const [],
    this.recentSearches = const [],
  });

  List<Opportunity> get results {
    var list = allOpportunities.where((o) {
      final q = query.toLowerCase();
      final matchesQuery = q.isEmpty ||
          o.title.toLowerCase().contains(q) ||
          o.startupName.toLowerCase().contains(q) ||
          o.description.toLowerCase().contains(q) ||
          o.requirements.any((r) => r.toLowerCase().contains(q));
      final matchesCategory = selectedCategory == 'All' ||
          o.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesLocation = selectedLocation == 'Anywhere' ||
          o.location.toLowerCase().contains(selectedLocation.toLowerCase());
      final matchesType = selectedType == 'Any' ||
          o.type.toLowerCase().contains(selectedType.toLowerCase());
      final matchesSalary = selectedSalary == 'Any' ||
          (selectedSalary == 'Paid'
              ? (o.salary != null &&
                  o.salary!.isNotEmpty &&
                  !o.salary!.toLowerCase().contains('unpaid'))
              : (o.salary == null ||
                  o.salary!.isEmpty ||
                  o.salary!.toLowerCase().contains('unpaid')));
      return matchesQuery && matchesCategory && matchesLocation && matchesType && matchesSalary;
    }).toList();

    switch (sortOrder) {
      case SearchSortOrder.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SearchSortOrder.oldest:
        list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SearchSortOrder.mostApplicants:
        list.sort((a, b) => b.applicationsCount.compareTo(a.applicationsCount));
    }
    return list;
  }

  bool get hasActiveFilters =>
      selectedCategory != 'All' ||
      selectedLocation != 'Anywhere' ||
      selectedType != 'Any' ||
      selectedSalary != 'Any';

  SearchState copyWith({
    String? query,
    String? selectedCategory,
    String? selectedLocation,
    String? selectedType,
    String? selectedSalary,
    SearchSortOrder? sortOrder,
    List<Opportunity>? allOpportunities,
    List<String>? recentSearches,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedType: selectedType ?? this.selectedType,
      selectedSalary: selectedSalary ?? this.selectedSalary,
      sortOrder: sortOrder ?? this.sortOrder,
      categories: categories,
      locations: locations,
      types: types,
      salaryRanges: salaryRanges,
      allOpportunities: allOpportunities ?? this.allOpportunities,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  static const int _maxRecent = 8;

  @override
  SearchState build() {
    final opportunitiesAsync = ref.watch(_allOpportunitiesProvider);
    opportunitiesAsync.whenData((list) {
      if (state.allOpportunities != list) {
        state = state.copyWith(allOpportunities: list);
      }
    });
    return const SearchState();
  }

  void setQuery(String query) => state = state.copyWith(query: query);

  /// Call when user submits a search (presses enter / taps result).
  void commitSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [q, ...state.recentSearches.where((s) => s != q)]
        .take(_maxRecent)
        .toList();
    state = state.copyWith(query: q, recentSearches: updated);
  }

  void removeRecentSearch(String query) {
    state = state.copyWith(
      recentSearches: state.recentSearches.where((s) => s != query).toList(),
    );
  }

  void clearRecentSearches() => state = state.copyWith(recentSearches: []);

  void setCategory(String category) =>
      state = state.copyWith(selectedCategory: category);
  void setLocation(String location) =>
      state = state.copyWith(selectedLocation: location);
  void setType(String type) => state = state.copyWith(selectedType: type);
  void setSalary(String salary) => state = state.copyWith(selectedSalary: salary);
  void setSortOrder(SearchSortOrder order) =>
      state = state.copyWith(sortOrder: order);

  void reset() => state = state.copyWith(
        query: '',
        selectedCategory: 'All',
        selectedLocation: 'Anywhere',
        selectedType: 'Any',
        selectedSalary: 'Any',
        sortOrder: SearchSortOrder.newest,
      );
}

final _allOpportunitiesProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).getOpportunities();
});

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
