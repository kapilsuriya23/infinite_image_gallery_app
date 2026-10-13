import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../download/presentation/download_provider.dart';
import '../../data/models/pixabay_image.dart';
import '../widgets/favorite_button.dart';

class ImageDetailScreen extends ConsumerWidget {
  const ImageDetailScreen({super.key, required this.image, required this.heroTag});
  final PixabayImage image;
  final String heroTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final download = ref.watch(downloadProvider(image));

    ref.listen<DownloadState>(downloadProvider(image), (prev, next) {
      if (prev?.status == next.status) return;
      if (next.status == DownloadStatus.success ||
          next.status == DownloadStatus.failure) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(next.message ?? '')));
      }
    });

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: 'Share',
            icon: const Icon(Icons.share),
            onPressed: () => Share.share('${image.title} – ${image.pageUrl}'),
          ),
          FavoriteButton(image: image),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              Hero(
                tag: heroTag,
                child: AspectRatio(
                  aspectRatio: image.width / image.height,
                  child: CachedNetworkImage(
                    imageUrl: image.largeImageUrl,
                    fit: BoxFit.cover,
                    // Already-cached grid thumbnail shows instantly while HD loads.
                    placeholder: (_, __) => CachedNetworkImage(
                        imageUrl: image.webformatUrl, fit: BoxFit.cover),
                    errorWidget: (_, __, ___) =>
                        const Center(child: Icon(Icons.broken_image_outlined, size: 48)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(image.title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 8),
                    Text(image.description, style: theme.textTheme.bodyLarge),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final t in image.tagList) Chip(label: Text(t)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _Stat(Icons.visibility_outlined, image.views),
                        _Stat(Icons.thumb_up_outlined, image.likes),
                        _Stat(Icons.download_outlined, image.downloads),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (download.isDownloading)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: LinearProgressIndicator(value: download.progress),
                      ),
                    FilledButton.icon(
                      onPressed: download.isDownloading
                          ? null
                          : () => ref.read(downloadProvider(image).notifier).start(),
                      icon: Icon(download.status == DownloadStatus.success
                          ? Icons.check
                          : Icons.download),
                      label: Text(switch (download.status) {
                        DownloadStatus.downloading =>
                          'Downloading ${(download.progress * 100).round()}%',
                        DownloadStatus.success => 'Saved – download again',
                        _ => 'Download image',
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.icon, this.value);
  final IconData icon;
  final int value;

  @override
  Widget build(BuildContext context) => Column(
        children: [Icon(icon), const SizedBox(height: 4), Text('$value')],
      );
}