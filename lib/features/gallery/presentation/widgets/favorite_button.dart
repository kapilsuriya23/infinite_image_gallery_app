import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../favorites/presentation/providers/favorites_provider.dart';
import '../../data/models/pixabay_image.dart';

class FavoriteButton extends ConsumerWidget {
  const FavoriteButton({super.key, required this.image, this.overlay = false});
  final PixabayImage image;
  final bool overlay; // dark circular backdrop when drawn over a photo

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavoriteProvider(image.id));
    return IconButton(
      tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
      onPressed: () => ref.read(favoritesProvider.notifier).toggle(image),
      style: overlay
          ? IconButton.styleFrom(backgroundColor: Colors.black38)
          : null,
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.redAccent : (overlay ? Colors.white : null),
      ),
    );
  }
}