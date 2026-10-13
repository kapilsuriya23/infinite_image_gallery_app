import '../../../../core/error/app_exception.dart';
import '../../data/models/pixabay_image.dart';

class GalleryState {
  const GalleryState({
    required this.images,
    required this.page,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  });

  final List<PixabayImage> images;
  final int page;
  final bool hasMore;
  final bool isLoadingMore;
  final AppException? loadMoreError;

  GalleryState copyWith({
    List<PixabayImage>? images,
    int? page,
    bool? hasMore,
    bool? isLoadingMore,
    AppException? loadMoreError,
    bool clearError = false,
  }) =>
      GalleryState(
        images: images ?? this.images,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        loadMoreError: clearError ? null : (loadMoreError ?? this.loadMoreError),
      );
}