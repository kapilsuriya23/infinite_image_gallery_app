class PixabayImage {
  const PixabayImage({
    required this.id,
    required this.pageUrl,
    required this.tags,
    required this.previewUrl,
    required this.webformatUrl,
    required this.largeImageUrl,
    required this.width,
    required this.height,
    required this.user,
    required this.views,
    required this.likes,
    required this.downloads,
  });

  final int id;
  final String pageUrl;
  final String tags;
  final String previewUrl;
  final String webformatUrl;
  final String largeImageUrl;
  final int width;
  final int height;
  final String user;
  final int views;
  final int likes;
  final int downloads;

  factory PixabayImage.fromJson(Map<String, dynamic> j) => PixabayImage(
        id: j['id'] as int,
        pageUrl: j['pageURL'] as String? ?? '',
        tags: j['tags'] as String? ?? '',
        previewUrl: j['previewURL'] as String? ?? '',
        webformatUrl: j['webformatURL'] as String? ?? '',
        largeImageUrl:
            (j['largeImageURL'] ?? j['webformatURL'] ?? '') as String,
        width: (j['webformatWidth'] as num?)?.toInt() ?? 1,
        height: (j['webformatHeight'] as num?)?.toInt() ?? 1,
        user: j['user'] as String? ?? 'Unknown',
        views: (j['views'] as num?)?.toInt() ?? 0,
        likes: (j['likes'] as num?)?.toInt() ?? 0,
        downloads: (j['downloads'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'pageURL': pageUrl,
        'tags': tags,
        'previewURL': previewUrl,
        'webformatURL': webformatUrl,
        'largeImageURL': largeImageUrl,
        'webformatWidth': width,
        'webformatHeight': height,
        'user': user,
        'views': views,
        'likes': likes,
        'downloads': downloads,
      };

  List<String> get tagList =>
      tags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

  String get title {
    final first = tagList.isEmpty ? 'Untitled' : tagList.first;
    return first[0].toUpperCase() + first.substring(1);
  }

  /// Pixabay has no description field, so one is composed from its metadata.
  String get description =>
      'A photo by $user on Pixabay'
      '${tagList.isEmpty ? '' : ', featuring ${tagList.join(', ')}'}. '
      'Original size: $width × $height px.';

  /// Clamped so extreme panoramas/portraits don't break the masonry layout.
  double get aspectRatio => (width / height).clamp(0.6, 1.8);

  @override
  bool operator ==(Object other) => other is PixabayImage && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class PagedImages {
  const PagedImages({required this.images, required this.totalHits});
  final List<PixabayImage> images;
  final int totalHits;
}