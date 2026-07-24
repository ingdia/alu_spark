import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';

class BookmarkModel {
  final String id;
  final String userId;
  final String opportunityId;
  final String opportunityTitle;
  final String startupName;
  final String category;
  final String location;
  final DateTime createdAt;

  BookmarkModel({
    required this.id,
    required this.userId,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupName,
    required this.category,
    required this.location,
    required this.createdAt,
  });

  factory BookmarkModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final userId = data['userId'] as String? ?? '';
    return BookmarkModel(
      id: '${userId}_${doc.id}',
      userId: userId,
      opportunityId: data['opportunityId'] ?? '',
      opportunityTitle: data['opportunityTitle'] ?? '',
      startupName: data['startupName'] ?? '',
      category: data['category'] ?? '',
      location: data['location'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'opportunityId': opportunityId,
      'opportunityTitle': opportunityTitle,
      'startupName': startupName,
      'category': category,
      'location': location,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  Bookmark toEntity() {
    return Bookmark(
      id: id,
      userId: userId,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupName: startupName,
      category: category,
      location: location,
      createdAt: createdAt,
    );
  }
}
