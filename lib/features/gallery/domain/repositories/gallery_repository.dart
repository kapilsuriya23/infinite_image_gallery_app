import '../../data/models/pixabay_image.dart';

abstract interface class GalleryRepository {
  Future<PagedImages> fetchImages({
    String query = '',
    String? category,
    required int page,
  });
}