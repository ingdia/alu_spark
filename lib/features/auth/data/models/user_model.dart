import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/auth/domain/entities/user.dart';
import 'package:alu_spark/shared/enums/user_role.dart';

class UserModel extends User {
  final bool isApproved;
  final String? startupProfileStatus;

  UserModel({
    required super.id,
    required super.email,
    required super.fullName,
    required super.role,
    required super.createdAt,
    required super.isEmailVerified,
    super.phoneNumber,
    super.profileImageUrl,
    super.university,
    super.major,
    this.isApproved = true,
    this.startupProfileStatus,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      fullName: data['fullName'] as String? ?? '',
      role: UserRole.values.firstWhere(
        (r) => r.name == (data['role'] as String? ?? ''),
        orElse: () => UserRole.student,
      ),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isEmailVerified: data['isEmailVerified'] as bool? ?? false,
      phoneNumber: data['phoneNumber'] as String?,
      profileImageUrl: data['profileImageUrl'] as String?,
      university: data['university'] as String?,
      major: data['major'] as String?,
      isApproved: data['isApproved'] as bool? ?? true,
      startupProfileStatus: data['startupProfileStatus'] as String?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'id': id,
        'email': email,
        'fullName': fullName,
        'role': role.name,
        'createdAt': FieldValue.serverTimestamp(),
        'isEmailVerified': isEmailVerified,
        'isApproved': isApproved,
        if (startupProfileStatus != null) 'startupProfileStatus': startupProfileStatus,
        if (phoneNumber != null) 'phoneNumber': phoneNumber,
        if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
        if (university != null) 'university': university,
        if (major != null) 'major': major,
      };
}
