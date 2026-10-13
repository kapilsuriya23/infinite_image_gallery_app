import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/widgets/error_view.dart';
import '../../../favorites/presentation/screens/favorites_screen.dart';
import '../providers/gallery_providers.dart';
import '../providers/gallery_state.dart';
import '../widgets/category_chips.dart';
import '../widgets/image_tile.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  final _scroll = ScrollController();
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(() {
      if (_scroll.position.extentAfter < 600) _loadMoreIfNeeded();
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _loadMoreIfNeeded() {
    final s = ref.read(galleryProvider).valueOrNull;
    if (s == null || !s.hasMore || s.isLoadingMore || s.loadMoreError != null) {
      return;
    }
    ref.read(galleryProvider.notifier).loadMore();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(galleryProvider);
    try {
      await ref.read(galleryProvider.future);
    } catch (_) {/* error UI handles it */}
  }

  void _search(String value) =>
      ref.read(searchQueryProvider.notifier).state = value.trim();

  IconData _themeIcon(ThemeMode m) => switch (m) {
        ThemeMode.system => Icons.brightness_auto,
        ThemeMode.light => Icons.light_mode,
        ThemeMode.dark => Icons.dark_mode,
      };

  @override
  Widget build(BuildContext context) {
    final gallery = ref.watch(galleryProvider);
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 12,
        title: TextField(
          controller: _searchCtrl,
          textInputAction: TextInputAction.search,
          onSubmitted: _search,
          decoration: InputDecoration(
            hintText: 'Search images',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                _search('');
              },
            ),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Theme',
            icon: Icon(_themeIcon(themeMode)),
            onPressed: () => ref.read(themeModeProvider.notifier).cycle(),
          ),
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const FavoritesScreen())),
          ),
        ],
      ),
      body: Column(
        children: [
          const CategoryChips(),
          Expanded(
            child: gallery.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: errorMessage(e),
                onRetry: () => ref.invalidate(galleryProvider),
              ),
              data: _buildContent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(GalleryState state) {
    if (state.images.isEmpty) {
      return const Center(child: Text('No images found. Try another search.'));
    }

    // If the first page doesn't fill the viewport (tablets), keep loading.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients && _scroll.position.maxScrollExtent == 0) {
        _loadMoreIfNeeded();
      }
    });

    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            onRefresh: _onRefresh,
            child: MasonryGridView.builder(
              controller: _scroll,
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverSimpleGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemCount: state.images.length,
              itemBuilder: (_, i) =>
                  ImageTile(image: state.images[i], heroPrefix: 'gallery'),
            ),
          ),
        ),
        _Footer(state: state),
      ],
    );
  }
}

class _Footer extends ConsumerWidget {
  const _Footer({required this.state});
  final GalleryState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (state.isLoadingMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: SizedBox(
            width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 3)),
      );
    }
    if (state.loadMoreError != null) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Expanded(child: Text(state.loadMoreError!.message)),
            TextButton(
              onPressed: () => ref.read(galleryProvider.notifier).loadMore(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (!state.hasMore) {
      return const Padding(
        padding: EdgeInsets.all(12),
        child: Text("You've reached the end"),
      );
    }
    return const SizedBox.shrink();
  }
}