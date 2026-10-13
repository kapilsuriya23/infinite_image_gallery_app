import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../gallery/presentation/widgets/image_tile.dart';
import '../providers/favorites_provider.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favorites = ref.watch(favoritesProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Favorites (${favorites.length})')),
      body: favorites.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No favorites yet.\nTap the heart on any image to save it here.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : MasonryGridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: favorites.length,
              itemBuilder: (_, i) =>
                  ImageTile(image: favorites[i], heroPrefix: 'fav'),
            ),
    );
  }
}