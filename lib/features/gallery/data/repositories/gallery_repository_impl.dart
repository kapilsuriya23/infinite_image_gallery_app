import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/gallery_repository.dart';
import '../datasources/pixabay_remote_data_source.dart';
import '../models/pixabay_image.dart';

class GalleryRepositoryImpl implements GalleryRepository {
  GalleryRepositoryImpl(this._remote);
  final PixabayRemoteDataSource _remote;

  @override
  Future<PagedImages> fetchImages({
    String query = '',
    String? category,
    required int page,
  }) =>
      _remote.fetch(
        query: query,
        category: category,
        page: page,
        perPage: AppConstants.pageSize,
      );
}