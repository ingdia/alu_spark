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
  final OpportunityStatus status;

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
    this.status = OpportunityStatus.active,
  });

  static OpportunityStatus _statusFromString(String? s) {
    switch (s) {
      case 'closed':
        return OpportunityStatus.closed;
      case 'archived':
        return OpportunityStatus.archived;
      default:
        return OpportunityStatus.active;
    }
  }

  static String _statusToString(OpportunityStatus s) {
    switch (s) {
      case OpportunityStatus.closed:
        return 'closed';
      case OpportunityStatus.archived:
        return 'archived';
      case OpportunityStatus.active:
        return 'active';
    }
  }

  factory OpportunityModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final statusStr = data['status'] as String?;
    // Legacy: if no status field, derive from isActive
    final isActive = data['isActive'] as bool? ?? true;
    final status = statusStr != null
        ? _statusFromString(statusStr)
        : (isActive ? OpportunityStatus.active : OpportunityStatus.closed);
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
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      deadline: data['deadline'] != null
          ? (data['deadline'] as Timestamp).toDate()
          : null,
      isActive: isActive,
      applicationsCount: data['applicationsCount'] ?? 0,
      status: status,
    );
  }

  Map<String, dynamic> toFirestore() => {
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
        'isActive': status == OpportunityStatus.active,
        'applicationsCount': applicationsCount,
        'status': _statusToString(status),
      };

  Opportunity toEntity() => Opportunity(
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
        status: status,
      );
}
