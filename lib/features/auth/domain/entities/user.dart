import 'package:alu_spark/shared/enums/user_role.dart';

class User {
  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final DateTime createdAt;
  final bool isEmailVerified;
  final String? phoneNumber;
  final String? profileImageUrl;
  final String? university;
  final String? major;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    required this.createdAt,
    required this.isEmailVerified,
    this.phoneNumber,
    this.profileImageUrl,
    this.university,
    this.major,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'role': role.name,
      'createdAt': createdAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'phoneNumber': phoneNumber,
      'profileImageUrl': profileImageUrl,
      'university': university,
      'major': major,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      fullName: map['fullName'] ?? '',
      role: UserRole.values.firstWhere(
        (e) => e.name == map['role'],
        orElse: () => UserRole.student,
      ),
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
      isEmailVerified: map['isEmailVerified'] ?? false,
      phoneNumber: map['phoneNumber'],
      profileImageUrl: map['profileImageUrl'],
      university: map['university'],
      major: map['major'],
    );
  }

  User copyWith({
    String? id,
    String? email,
    String? fullName,
    UserRole? role,
    DateTime? createdAt,
    bool? isEmailVerified,
    String? phoneNumber,
    String? profileImageUrl,
    String? university,
    String? major,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      university: university ?? this.university,
      major: major ?? this.major,
    );
  }
}
