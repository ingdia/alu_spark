import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';

final bookmarksProvider = StreamProvider.family<List<Bookmark>, String>((ref, userId) {
  final repository = ref.watch(bookmarkRepositoryProvider);
  return repository.getBookmarksByUser(userId);
});
