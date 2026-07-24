import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/bookmarks/data/models/bookmark_model.dart';
import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';
import 'package:alu_spark/features/bookmarks/domain/repositories/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final FirebaseFirestore _firestore;

  BookmarkRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _col(String userId) =>
      _firestore.collection('bookmarks').doc(userId).collection('opportunities');

  @override
  Stream<List<Bookmark>> getBookmarksByUser(String userId) {
    return _col(userId).snapshots().map((snapshot) {
      final list = snapshot.docs
          .map((doc) => BookmarkModel.fromFirestore(doc).toEntity())
          .toList();
      list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return list;
    });
  }

  @override
  Future<void> addBookmark(Bookmark bookmark) async {
    final model = BookmarkModel(
      id: bookmark.opportunityId,
      userId: bookmark.userId,
      opportunityId: bookmark.opportunityId,
      opportunityTitle: bookmark.opportunityTitle,
      startupName: bookmark.startupName,
      category: bookmark.category,
      location: bookmark.location,
      createdAt: bookmark.createdAt,
    );
    await _col(bookmark.userId)
        .doc(bookmark.opportunityId)
        .set(model.toFirestore());
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    // bookmarkId format: "{userId}_{opportunityId}"
    final parts = bookmarkId.split('_');
    final userId = parts.first;
    final opportunityId = parts.sublist(1).join('_');
    await _col(userId).doc(opportunityId).delete();
  }

  @override
  Future<bool> isBookmarked(String userId, String opportunityId) async {
    final doc = await _col(userId).doc(opportunityId).get();
    return doc.exists;
  }
}
