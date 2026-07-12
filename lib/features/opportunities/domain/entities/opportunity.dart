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
  });

  Opportunity copyWith({String? id}) => Opportunity(
        id: id ?? this.id,
        title: title,
        description: description,
        startupId: startupId,
        startupName: startupName,
        category: category,
        location: location,
        type: type,
        salary: salary,
        requirements: requirements,
        benefits: benefits,
        createdAt: createdAt,
        deadline: deadline,
        isActive: isActive,
        applicationsCount: applicationsCount,
      );
}