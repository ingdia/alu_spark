import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class SearchState {
  final String query;
  final String selectedCategory;
  final String selectedLocation;
  final String selectedType;
  final List<String> categories;
  final List<String> locations;
  final List<String> types;
  final List<Opportunity> allOpportunities;

  const SearchState({
    this.query = '',
    this.selectedCategory = 'All',
    this.selectedLocation = 'Anywhere',
    this.selectedType = 'Any',
    this.categories = const ['All', 'Tech', 'Design', 'Marketing', 'Business', 'Finance'],
    this.locations = const ['Anywhere', 'Kigali', 'Remote', 'Nairobi', 'Cape Town'],
    this.types = const ['Any', 'Internship', 'Part-time', 'Full-time', 'Freelance'],
    this.allOpportunities = const [],
  });

  List<Opportunity> get results {
    return allOpportunities.where((o) {
      final matchesQuery = query.isEmpty ||
          o.title.toLowerCase().contains(query.toLowerCase()) ||
          o.startupName.toLowerCase().contains(query.toLowerCase());
      final matchesLocation = selectedLocation == 'Anywhere' ||
          o.location.toLowerCase().contains(selectedLocation.toLowerCase());
      final matchesType = selectedType == 'Any' ||
          o.type.toLowerCase().contains(selectedType.toLowerCase());
      return matchesQuery && matchesLocation && matchesType;
    }).toList();
  }

  SearchState copyWith({
    String? query,
    String? selectedCategory,
    String? selectedLocation,
    String? selectedType,
    List<Opportunity>? allOpportunities,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedType: selectedType ?? this.selectedType,
      categories: categories,
      locations: locations,
      types: types,
      allOpportunities: allOpportunities ?? this.allOpportunities,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() {
    // ref.watch on a StreamProvider — Riverpod manages the subscription
    // lifetime automatically. No manual listen() / cancel() needed.
    final opportunitiesAsync = ref.watch(
      // Reuse the existing autoDispose stream provider so we share the
      // single Firestore listener already open for DiscoverScreen.
      _allOpportunitiesProvider,
    );

    opportunitiesAsync.whenData((list) {
      // Only update if the list actually changed to avoid spurious rebuilds.
      if (state.allOpportunities != list) {
        state = state.copyWith(allOpportunities: list);
      }
    });

    return const SearchState();
  }

  void setQuery(String query) => state = state.copyWith(query: query);
  void setCategory(String category) => state = state.copyWith(selectedCategory: category);
  void setLocation(String location) => state = state.copyWith(selectedLocation: location);
  void setType(String type) => state = state.copyWith(selectedType: type);
  void reset() => state = state.copyWith(
        query: '',
        selectedCategory: 'All',
        selectedLocation: 'Anywhere',
        selectedType: 'Any',
      );
}

// Private provider — shares the Firestore stream with DiscoverScreen's
// recentOpportunitiesProvider without opening a second listener.
final _allOpportunitiesProvider = StreamProvider.autoDispose<List<Opportunity>>((ref) {
  return ref.watch(opportunityRepositoryProvider).getOpportunities();
});

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
