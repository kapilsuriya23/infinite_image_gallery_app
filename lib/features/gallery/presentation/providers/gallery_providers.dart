import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_provider.dart';
import '../../data/datasources/pixabay_remote_data_source.dart';
import '../../data/repositories/gallery_repository_impl.dart';
import '../../domain/repositories/gallery_repository.dart';
import 'gallery_state.dart';

final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryProvider = StateProvider<String?>((ref) => null);

final galleryRepositoryProvider = Provider<GalleryRepository>((ref) {
  return GalleryRepositoryImpl(PixabayRemoteDataSource(ref.watch(dioProvider)));
});

/// Watches query + category, so changing either resets to page 1 automatically.
final galleryProvider =
    AsyncNotifierProvider<GalleryNotifier, GalleryState>(GalleryNotifier.new);

class GalleryNotifier extends AsyncNotifier<GalleryState> {
  int _generation = 0; // discards responses from superseded loads

  @override
  Future<GalleryState> build() async {
    _generation++;
    final query = ref.watch(searchQueryProvider);
    final category = ref.watch(categoryProvider);
    final result = await ref
        .read(galleryRepositoryProvider)
        .fetchImages(query: query, category: category, page: 1);
    return GalleryState(
      images: result.images,
      page: 1,
      hasMore: result.images.isNotEmpty && result.images.length < result.totalHits,
    );
  }

  Future<void> loadMore() async {
    final current = state.valueOrNull;
    if (current == null || current.isLoadingMore || !current.hasMore) return;

    final generation = _generation;
    final query = ref.read(searchQueryProvider);
    final category = ref.read(categoryProvider);

    state = AsyncData(current.copyWith(isLoadingMore: true, clearError: true));
    try {
      final nextPage = current.page + 1;
      final result = await ref
          .read(galleryRepositoryProvider)
          .fetchImages(query: query, category: category, page: nextPage);
      if (generation != _generation) return;

      final seen = current.images.map((e) => e.id).toSet();
      final fresh = result.images.where((e) => seen.add(e.id)).toList();
      final all = [...current.images, ...fresh];

      state = AsyncData(current.copyWith(
        images: all,
        page: nextPage,
        hasMore: result.images.isNotEmpty && all.length < result.totalHits,
        isLoadingMore: false,
        clearError: true,
      ));
    } on AppException catch (e) {
      if (generation != _generation) return;
      state = AsyncData(current.copyWith(isLoadingMore: false, loadMoreError: e));
    }
  }
}