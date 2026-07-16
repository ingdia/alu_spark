import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:alu_spark/app/router/app_router.dart';
import 'package:alu_spark/app/theme/app_colors.dart';
import 'package:alu_spark/app/theme/app_text_styles.dart';
import 'package:alu_spark/core/widgets/glassmorphism_container.dart';
import 'package:alu_spark/core/widgets/loading_widget.dart';
import 'package:alu_spark/core/widgets/empty_state_widget.dart';
import 'package:alu_spark/core/widgets/error_state_widget.dart';
import 'package:alu_spark/core/providers/firebase_providers.dart';
import 'package:alu_spark/core/providers/repository_providers.dart';
import 'package:alu_spark/features/bookmarks/presentation/providers/bookmark_provider.dart';
import 'package:alu_spark/features/bookmarks/domain/entities/bookmark.dart';

class BookmarksScreen extends ConsumerWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBlue,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            blur: 10,
            borderRadius: 12,
            padding: const EdgeInsets.all(0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.white, size: 18),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ),
        title: Text(
          'Bookmarks',
          style: AppTextStyles.headingMedium.copyWith(color: AppColors.white),
        ),
        centerTitle: true,
      ),
      body: authState.when(
        loading: () => const LoadingWidget(),
        error: (error, _) => ErrorStateWidget(
          message: 'Failed to load user',
        ),
        data: (user) {
          if (user == null) {
            return const EmptyStateWidget(
              icon: Icons.lock,
              title: 'Not Logged In',
              description: 'Please log in to view bookmarks.',
            );
          }
          
          final bookmarksAsync = ref.watch(bookmarksProvider(user.id));
          
          return bookmarksAsync.when(
            loading: () => const LoadingWidget(message: 'Loading bookmarks...'),
            error: (error, _) => ErrorStateWidget(
              message: 'Failed to load bookmarks.',
              onRetry: () => ref.invalidate(bookmarksProvider(user.id)),
            ),
            data: (bookmarks) => _buildContent(context, ref, bookmarks),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, List<Bookmark> bookmarks) {
    if (bookmarks.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.bookmark_border,
        title: 'No Saved Opportunities',
        description: 'Tap the bookmark icon on any opportunity to save it here for later.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: bookmarks.length,
      itemBuilder: (context, index) => _buildBookmarkCard(context, ref, bookmarks[index]),
    );
  }

  Widget _buildBookmarkCard(BuildContext context, WidgetRef ref, Bookmark bookmark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Dismissible(
        key: Key(bookmark.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: Colors.red.shade900,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_outline, color: AppColors.white),
        ),
        onDismissed: (_) {
          ref.read(bookmarkRepositoryProvider).removeBookmark(bookmark.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bookmark removed'),
              backgroundColor: AppColors.darkRed,
            ),
          );
        },
        child: GestureDetector(
          onTap: () async {
            final opportunity = await ref
                .read(opportunityRepositoryProvider)
                .getOpportunityById(bookmark.opportunityId);
            if (opportunity != null && context.mounted) {
              Navigator.of(context).pushNamed(
                RouteNames.opportunityDetail,
                arguments: opportunity,
              );
            }
          },
          child: GlassmorphicContainer(
          blur: 10,
          borderRadius: 16,
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkRed.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bookmark, color: AppColors.darkRed, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bookmark.opportunityTitle,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bookmark.startupName,
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: [
                        _buildTag(bookmark.category),
                        _buildTag(bookmark.location),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.glassWhite,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.borderGlass),
      ),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.white,
          fontSize: 10,
        ),
      ),
    );
  }
}
