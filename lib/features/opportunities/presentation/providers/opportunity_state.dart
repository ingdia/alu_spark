class OpportunityState {
  final List<Map<String, dynamic>> featured;
  final List<Map<String, dynamic>> recent;
  final List<String> categories;
  final int selectedCategoryIndex;
  final bool isLoading;

  const OpportunityState({
    this.featured = const [],
    this.recent = const [],
    this.categories = const [],
    this.selectedCategoryIndex = 0,
    this.isLoading = false,
  });

  List<Map<String, dynamic>> get filteredRecent {
    if (selectedCategoryIndex == 0) return recent;
    final category = categories[selectedCategoryIndex].toLowerCase();
    return recent.where((o) {
      final type = (o['type'] as String? ?? '').toLowerCase();
      final title = (o['title'] as String? ?? '').toLowerCase();
      return type.contains(category) || title.contains(category);
    }).toList();
  }

  OpportunityState copyWith({
    List<Map<String, dynamic>>? featured,
    List<Map<String, dynamic>>? recent,
    List<String>? categories,
    int? selectedCategoryIndex,
    bool? isLoading,
  }) {
    return OpportunityState(
      featured: featured ?? this.featured,
      recent: recent ?? this.recent,
      categories: categories ?? this.categories,
      selectedCategoryIndex: selectedCategoryIndex ?? this.selectedCategoryIndex,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
