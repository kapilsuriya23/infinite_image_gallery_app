import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../data/models/pixabay_image.dart';
import '../screens/image_detail_screen.dart';
import 'favorite_button.dart';

class ImageTile extends StatelessWidget {
  const ImageTile({super.key, required this.image, required this.heroPrefix});
  final PixabayImage image;
  final String heroPrefix;

  @override
  Widget build(BuildContext context) {
    final heroTag = '$heroPrefix-${image.id}';
    final scheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          AspectRatio(
            aspectRatio: image.aspectRatio,
            child: Hero(
              tag: heroTag,
              child: CachedNetworkImage(
                imageUrl: image.webformatUrl,
                fit: BoxFit.cover,
                memCacheWidth: 500, // decode at thumbnail size, saves memory
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, __) =>
                    ColoredBox(color: scheme.surfaceContainerHighest),
                errorWidget: (_, __, ___) => ColoredBox(
                  color: scheme.surfaceContainerHighest,
                  child: const Center(child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) =>
                      ImageDetailScreen(image: image, heroTag: heroTag),
                )),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: FavoriteButton(image: image, overlay: true),
          ),
        ],
      ),
    );
  }
}