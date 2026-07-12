import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/constants/dummy_data.dart';

class SearchState {
  final String query;
  final String selectedCategory;
  final String selectedLocation;
  final String selectedType;
  final List<String> categories;
  final List<String> locations;
  final List<String> types;

  const SearchState({
    this.query = '',
    this.selectedCategory = 'All',
    this.selectedLocation = 'Anywhere',
    this.selectedType = 'Any',
    this.categories = const ['All', 'Tech', 'Design', 'Marketing', 'Business', 'Finance'],
    this.locations = const ['Anywhere', 'Kigali', 'Remote', 'Nairobi', 'Cape Town'],
    this.types = const ['Any', 'Internship', 'Part-time', 'Full-time', 'Freelance'],
  });

  List<Map<String, dynamic>> get results {
    final all = List<Map<String, dynamic>>.from(DummyData.recentOpportunities);
    return all.where((o) {
      final title = (o['title'] as String? ?? '').toLowerCase();
      final startup = (o['startup'] as String? ?? '').toLowerCase();
      final location = (o['location'] as String? ?? '').toLowerCase();
      final type = (o['type'] as String? ?? '').toLowerCase();

      final matchesQuery = query.isEmpty ||
          title.contains(query.toLowerCase()) ||
          startup.contains(query.toLowerCase());

      final matchesLocation = selectedLocation == 'Anywhere' ||
          location.contains(selectedLocation.toLowerCase());

      final matchesType =
          selectedType == 'Any' || type.contains(selectedType.toLowerCase());

      return matchesQuery && matchesLocation && matchesType;
    }).toList();
  }

  SearchState copyWith({
    String? query,
    String? selectedCategory,
    String? selectedLocation,
    String? selectedType,
  }) {
    return SearchState(
      query: query ?? this.query,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      selectedType: selectedType ?? this.selectedType,
      categories: categories,
      locations: locations,
      types: types,
    );
  }
}

class SearchNotifier extends Notifier<SearchState> {
  @override
  SearchState build() => const SearchState();

  void setQuery(String query) => state = state.copyWith(query: query);
  void setCategory(String category) => state = state.copyWith(selectedCategory: category);
  void setLocation(String location) => state = state.copyWith(selectedLocation: location);
  void setType(String type) => state = state.copyWith(selectedType: type);
  void reset() => state = const SearchState();
}

final searchProvider = NotifierProvider<SearchNotifier, SearchState>(
  SearchNotifier.new,
);
