class Opportunity {
  final String id;
  final String title;
  final String startupName;
  final String location;
  final String type;
  final String description;
  final String salary;
  final List<String> requirements;
  final List<String> benefits;

  const Opportunity({
    required this.id,
    required this.title,
    required this.startupName,
    required this.location,
    required this.type,
    this.description = '',
    this.salary = '',
    this.requirements = const [],
    this.benefits = const [],
  });
}
