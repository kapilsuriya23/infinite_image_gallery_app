import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infinite_image_gallery_app/core/storage/storage_providers.dart';
import 'package:infinite_image_gallery_app/features/favorites/presentation/providers/favorites_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'gallery_notifier_test.dart' show fakeImage;

void main() {
  test('toggle adds, removes and persists favorites', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);

    final n = c.read(favoritesProvider.notifier);
    n.toggle(fakeImage(1));
    expect(c.read(favoritesProvider).length, 1);
    expect(c.read(isFavoriteProvider(1)), isTrue);

    // a fresh container reads what was persisted
    final c2 = ProviderContainer(
        overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c2.dispose);
    expect(c2.read(favoritesProvider).length, 1);

    n.toggle(fakeImage(1));
    expect(c.read(favoritesProvider), isEmpty);
  });
}
