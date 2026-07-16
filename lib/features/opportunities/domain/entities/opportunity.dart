enum OpportunityStatus { active, closed, archived }

class Opportunity {
  final String id;
  final String title;
  final String description;
  final String startupId;
  final String startupName;
  final String category;
  final String location;
  final String type;
  final String? salary;
  final List<String> requirements;
  final List<String> benefits;
  final DateTime createdAt;
  final DateTime? deadline;
  final bool isActive;
  final int applicationsCount;
  final OpportunityStatus status;

  Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.startupId,
    required this.startupName,
    required this.category,
    required this.location,
    required this.type,
    this.salary,
    required this.requirements,
    required this.benefits,
    required this.createdAt,
    this.deadline,
    this.isActive = true,
    this.applicationsCount = 0,
    this.status = OpportunityStatus.active,
  });

  Opportunity copyWith({
    String? id,
    String? title,
    String? description,
    String? startupId,
    String? startupName,
    String? category,
    String? location,
    String? type,
    String? salary,
    List<String>? requirements,
    List<String>? benefits,
    DateTime? createdAt,
    DateTime? deadline,
    bool? isActive,
    int? applicationsCount,
    OpportunityStatus? status,
  }) =>
      Opportunity(
        id: id ?? this.id,
        title: title ?? this.title,
        description: description ?? this.description,
        startupId: startupId ?? this.startupId,
        startupName: startupName ?? this.startupName,
        category: category ?? this.category,
        location: location ?? this.location,
        type: type ?? this.type,
        salary: salary ?? this.salary,
        requirements: requirements ?? this.requirements,
        benefits: benefits ?? this.benefits,
        createdAt: createdAt ?? this.createdAt,
        deadline: deadline ?? this.deadline,
        isActive: isActive ?? this.isActive,
        applicationsCount: applicationsCount ?? this.applicationsCount,
        status: status ?? this.status,
      );
}
