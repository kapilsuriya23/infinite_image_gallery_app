import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/storage/storage_providers.dart';
import '../../../gallery/data/models/pixabay_image.dart';
import '../../data/favorites_local_data_source.dart';

final favoritesLocalDataSourceProvider = Provider(
  (ref) => FavoritesLocalDataSource(ref.watch(sharedPreferencesProvider)),
);

class FavoritesNotifier extends Notifier<List<PixabayImage>> {
  @override
  List<PixabayImage> build() => ref.read(favoritesLocalDataSourceProvider).load();

  void toggle(PixabayImage image) {
    final exists = state.any((e) => e.id == image.id);
    state = exists
        ? state.where((e) => e.id != image.id).toList()
        : [image, ...state];
    ref.read(favoritesLocalDataSourceProvider).save(state);
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<PixabayImage>>(FavoritesNotifier.new);

/// Rebuilds a widget only when this one image's favorite status flips.
final isFavoriteProvider = Provider.family<bool, int>((ref, id) {
  return ref.watch(favoritesProvider.select((l) => l.any((e) => e.id == id)));
});