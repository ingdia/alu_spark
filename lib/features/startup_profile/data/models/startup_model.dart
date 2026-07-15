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
  final String website;
  final String linkedin;
  final String stage;
  final String teamSize;

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
    this.website = '',
    this.linkedin = '',
    this.stage = '',
    this.teamSize = '',
  });

  factory StartupModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final rawMembers = data['founders'] ?? data['teamMembers'] ?? [];
    final members = (rawMembers as List).map((e) {
      if (e is Map) return Map<String, String>.from(e.map((k, v) => MapEntry(k.toString(), v.toString())));
      return <String, String>{};
    }).toList();

    return StartupModel(
      id: doc.id,
      name: data['startupName'] ?? data['name'] ?? '',
      tagline: data['tagline'] ?? '',
      industry: data['industry'] ?? '',
      description: data['description'] ?? '',
      founderId: data['uid'] ?? data['founderId'] ?? '',
      founderName: data['founderName'] ?? '',
      teamMembers: members,
      openRolesCount: data['openRolesCount'] ?? 0,
      isVerified: data['status'] == 'approved' || (data['isVerified'] ?? false),
      createdAt: (data['submittedAt'] as Timestamp?)?.toDate() ??
          (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.now(),
      website: data['website'] ?? '',
      linkedin: data['linkedin'] ?? '',
      stage: data['stage'] ?? '',
      teamSize: data['teamSize'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'startupName': name,
      'name': name,
      'tagline': tagline,
      'industry': industry,
      'description': description,
      'founderId': founderId,
      'founderName': founderName,
      'teamMembers': teamMembers,
      'openRolesCount': openRolesCount,
      'isVerified': isVerified,
      'website': website,
      'linkedin': linkedin,
      'stage': stage,
      'teamSize': teamSize,
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
      website: website,
      linkedin: linkedin,
      stage: stage,
      teamSize: teamSize,
    );
  }
}
