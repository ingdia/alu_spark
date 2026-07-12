import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/constants/dummy_data.dart';
import 'opportunity_state.dart';

class OpportunityNotifier extends Notifier<OpportunityState> {
  @override
  OpportunityState build() {
    return OpportunityState(
      featured: DummyData.featuredOpportunities,
      recent: List<Map<String, dynamic>>.from(DummyData.recentOpportunities),
      categories: DummyData.categories,
      selectedCategoryIndex: 0,
    );
  }

  void selectCategory(int index) {
    state = state.copyWith(selectedCategoryIndex: index);
  }
}

final opportunityProvider =
    NotifierProvider<OpportunityNotifier, OpportunityState>(
  OpportunityNotifier.new,
);
