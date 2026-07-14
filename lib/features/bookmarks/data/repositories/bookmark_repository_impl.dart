import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:alu_spark/features/bookmarks/data/models/bookmark_model.dart';
import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';
import 'package:alu_spark/features/bookmarks/domain/repositories/bookmark_repository.dart';

class BookmarkRepositoryImpl implements BookmarkRepository {
  final FirebaseFirestore _firestore;
  final String _collectionPath = 'bookmarks';

  BookmarkRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Bookmark>> getBookmarksByUser(String userId) {
    return _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
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
      id: '',
      userId: bookmark.userId,
      opportunityId: bookmark.opportunityId,
      opportunityTitle: bookmark.opportunityTitle,
      startupName: bookmark.startupName,
      category: bookmark.category,
      location: bookmark.location,
      createdAt: bookmark.createdAt,
    );
    await _firestore.collection(_collectionPath).add(model.toFirestore());
  }

  @override
  Future<void> removeBookmark(String bookmarkId) async {
    await _firestore.collection(_collectionPath).doc(bookmarkId).delete();
  }

  @override
  Future<bool> isBookmarked(String userId, String opportunityId) async {
    final snapshot = await _firestore
        .collection(_collectionPath)
        .where('userId', isEqualTo: userId)
        .where('opportunityId', isEqualTo: opportunityId)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
