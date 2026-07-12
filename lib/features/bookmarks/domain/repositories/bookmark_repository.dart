import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';

abstract class BookmarkRepository {
  Stream<List<Bookmark>> getBookmarksByUser(String userId);
  Future<void> addBookmark(Bookmark bookmark);
  Future<void> removeBookmark(String bookmarkId);
  Future<bool> isBookmarked(String userId, String opportunityId);
}
