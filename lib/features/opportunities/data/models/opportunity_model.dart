import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/opportunities/domain/entities/opportunity.dart';

class OpportunityModel {
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

  OpportunityModel({
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

  // Convert Firestore DocumentSnapshot to Model
  factory OpportunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OpportunityModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      startupId: data['startupId'] ?? '',
      startupName: data['startupName'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      type: data['type'] ?? '',
      salary: data['salary'],
      requirements: List<String>.from(data['requirements'] ?? []),
      benefits: List<String>.from(data['benefits'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      deadline: (data['deadline'] as Timestamp?)?.toDate(),
      isActive: data['isActive'] ?? true,
      applicationsCount: data['applicationsCount'] ?? 0,
    );
  }

  // Convert Model to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'startupId': startupId,
      'startupName': startupName,
      'category': category,
      'location': location,
      'type': type,
      'salary': salary,
      'requirements': requirements,
      'benefits': benefits,
      'createdAt': Timestamp.fromDate(createdAt),
      'deadline': deadline != null ? Timestamp.fromDate(deadline!) : null,
      'isActive': isActive,
      'applicationsCount': applicationsCount,
    };
  }

  // Convert Model to Domain Entity
  Opportunity toEntity() {
    return Opportunity(
      id: id,
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
}