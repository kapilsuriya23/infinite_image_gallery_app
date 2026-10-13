import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery_app/features/gallery/data/models/pixabay_image.dart';
import 'package:infinite_image_gallery_app/features/gallery/domain/repositories/gallery_repository.dart';
import 'package:infinite_image_gallery_app/features/gallery/presentation/providers/gallery_providers.dart';

PixabayImage fakeImage(int id) => PixabayImage(
      id: id, pageUrl: '', tags: 'cat, pet', previewUrl: '', webformatUrl: '',
      largeImageUrl: '', width: 100, height: 100, user: 'u',
      views: 0, likes: 0, downloads: 0,
    );

class FakeRepo implements GalleryRepository {
  @override
  Future<PagedImages> fetchImages({
    String query = '', String? category, required int page,
  }) async =>
      PagedImages(
        images: [fakeImage((page - 1) * 2 + 1), fakeImage((page - 1) * 2 + 2)],
        totalHits: 6,
      );
}

void main() {
  test('loads first page, appends next, stops at totalHits', () async {
    final c = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(FakeRepo())]);
    addTearDown(c.dispose);

    await c.read(galleryProvider.future);
    expect(c.read(galleryProvider).value!.images.length, 2);

    await c.read(galleryProvider.notifier).loadMore();
    expect(c.read(galleryProvider).value!.images.length, 4);

    await c.read(galleryProvider.notifier).loadMore();
    final s = c.read(galleryProvider).value!;
    expect(s.images.length, 6);
    expect(s.hasMore, isFalse);
  });

  test('changing the category resets to page 1', () async {
    final c = ProviderContainer(
        overrides: [galleryRepositoryProvider.overrideWithValue(FakeRepo())]);
    addTearDown(c.dispose);

    await c.read(galleryProvider.future);
    await c.read(galleryProvider.notifier).loadMore();
    c.read(categoryProvider.notifier).state = 'nature';
    await c.read(galleryProvider.future);
    expect(c.read(galleryProvider).value!.page, 1);
  });
}
