import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/startup_profile/domain/entities/startup.dart';

class StartupModel {
  final String id;
  final String name;
  final String tagline;
  final String industry;
  final String description;
  final String founderId;
  final String founderName;
  final List<Map<String, String>> teamMembers;
  final int openRolesCount;
  final bool isVerified;
  final DateTime createdAt;

  StartupModel({
    required this.id,
    required this.name,
    required this.tagline,
    required this.industry,
    required this.description,
    required this.founderId,
    required this.founderName,
    required this.teamMembers,
    required this.openRolesCount,
    required this.isVerified,
    required this.createdAt,
  });

  factory StartupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StartupModel(
      id: doc.id,
      name: data['name'] ?? '',
      tagline: data['tagline'] ?? '',
      industry: data['industry'] ?? '',
      description: data['description'] ?? '',
      founderId: data['founderId'] ?? '',
      founderName: data['founderName'] ?? '',
      teamMembers: List<Map<String, String>>.from(data['teamMembers'] ?? []),
      openRolesCount: data['openRolesCount'] ?? 0,
      isVerified: data['isVerified'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'tagline': tagline,
      'industry': industry,
      'description': description,
      'founderId': founderId,
      'founderName': founderName,
      'teamMembers': teamMembers,
      'openRolesCount': openRolesCount,
      'isVerified': isVerified,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Startup toEntity() {
    return Startup(
      id: id,
      name: name,
      tagline: tagline,
      industry: industry,
      description: description,
      founderId: founderId,
      founderName: founderName,
      teamMembers: teamMembers,
      openRolesCount: openRolesCount,
      isVerified: isVerified,
      createdAt: createdAt,
    );
  }
}
