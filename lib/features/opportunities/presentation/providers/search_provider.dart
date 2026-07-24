import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';
import 'package:alu_spark/features/opportunities/domain/repositories/opportunity_repository.dart';

enum SearchSortOrder { newest, oldest, deadline }

class SearchState {
  final String query;
  final String selectedCategory;
  final String selectedLocation;
  final String selectedType;
  final String selectedSalary;
  final SearchSortOrder sortOrder;
  final List<String> recentSearches;

  static const categories = ['All', 'Tech', 'Design', 'Marketing', 'Business', 'Finance'];
  static const locations = ['Anywhere', 'Kigali', 'Remote', 'Nairobi', 'Cape Town', 'Lagos'];
  static const types = ['Any', 'Internship', 'Part-time', 'Full-time', 'Freelance'];
  static const salaryRanges = ['Any', 'Paid', 'Unpaid'];

  const SearchState({
    this.query = '',
    this.selectedCategory = 'All',
    this.selectedLocation = 'Anywhere',
    this.selectedType = 'Any',
    this.selectedSalary = 'Any',
    this.sortOrder = SearchSortOrder.newest,
    this.recentSearches = const [],
  });

  bool get hasActiveFilters =>
      selectedCategory != 'All' ||
      selectedLocation != 'Anywhere' ||
      selectedType != 'Any' ||
      selectedSalary != 'Any' ||
      query.isNotEmpty;

  /// Firestore-level filters (equality only — safe without composite indexes).
  OpportunitySearchFilters get firestoreFilters => OpportunitySearchFilters(
        category: selectedCategory == 'All' ? null : selectedCategory,
        location: selectedLocation == 'Anywhere' ? null : selectedLocation,
        type: selectedType == 'Any' ? null : selectedType,
      );

  SearchState copyWith({
    String? query,
    String? selectedCategory,
    String? selectedLocation,
    String? selectedType,
    String? selectedSalary,
    SearchSortOrder? sortOrder,
    List<String>? recentSearches,
  }) =>
      SearchState(
        query: query ?? this.query,
        selectedCategory: selectedCategory ?? this.selectedCategory,
        selectedLocation: selectedLocation ?? this.selectedLocation,
        selectedType: selectedType ?? this.selectedType,
        selectedSalary: selectedSalary ?? this.selectedSalary,
        sortOrder: sortOrder ?? this.sortOrder,
        recentSearches: recentSearches ?? this.recentSearches,
      );
}

class SearchNotifier extends Notifier<SearchState> {
  static const int _maxRecent = 8;

  @override
  SearchState build() => const SearchState();

  void setQuery(String query) => state = state.copyWith(query: query);

  void commitSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final updated = [q, ...state.recentSearches.where((s) => s != q)]
        .take(_maxRecent)
        .toList();
    state = state.copyWith(query: q, recentSearches: updated);
  }

  void removeRecentSearch(String query) => state = state.copyWith(
        recentSearches: state.recentSearches.where((s) => s != query).toList(),
      );

  void clearRecentSearches() => state = state.copyWith(recentSearches: []);

  void setCategory(String v) => state = state.copyWith(selectedCategory: v);
  void setLocation(String v) => state = state.copyWith(selectedLocation: v);
  void setType(String v) => state = state.copyWith(selectedType: v);
  void setSalary(String v) => state = state.copyWith(selectedSalary: v);
  void setSortOrder(SearchSortOrder v) => state = state.copyWith(sortOrder: v);

  void reset() => state = state.copyWith(
        query: '',
        selectedCategory: 'All',
        selectedLocation: 'Anywhere',
        selectedType: 'Any',
        selectedSalary: 'Any',
        sortOrder: SearchSortOrder.newest,
      );
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(SearchNotifier.new);

/// Streams results from Firestore using equality filters, then applies
/// client-side text search, salary filter, and sort.
final searchResultsProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  final state = ref.watch(searchProvider);
  final repo = ref.watch(opportunityRepositoryProvider);

  return repo.searchOpportunities(state.firestoreFilters).map((list) {
    // Client-side: text search
    var filtered = list.where((o) {
      final q = state.query.toLowerCase();
      if (q.isEmpty) return true;
      return o.title.toLowerCase().contains(q) ||
          o.startupName.toLowerCase().contains(q) ||
          o.description.toLowerCase().contains(q) ||
          o.requirements.any((r) => r.toLowerCase().contains(q));
    }).toList();

    // Client-side: salary filter
    if (state.selectedSalary != 'Any') {
      filtered = filtered.where((o) {
        final paid = o.salary != null &&
            o.salary!.isNotEmpty &&
            !o.salary!.toLowerCase().contains('unpaid');
        return state.selectedSalary == 'Paid' ? paid : !paid;
      }).toList();
    }

    // Sort
    switch (state.sortOrder) {
      case SearchSortOrder.newest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case SearchSortOrder.oldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
      case SearchSortOrder.deadline:
        filtered.sort((a, b) {
          if (a.deadline == null && b.deadline == null) return 0;
          if (a.deadline == null) return 1;
          if (b.deadline == null) return -1;
          return a.deadline!.compareTo(b.deadline!);
        });
    }

    return filtered;
  });
});
