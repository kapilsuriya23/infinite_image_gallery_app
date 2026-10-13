import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../gallery/data/models/pixabay_image.dart';

class FavoritesLocalDataSource {
  FavoritesLocalDataSource(this._prefs);
  final SharedPreferences _prefs;
  static const _key = 'favorites_v1';

  List<PixabayImage> load() {
    final raw = _prefs.getStringList(_key) ?? const [];
    final out = <PixabayImage>[];
    for (final s in raw) {
      try {
        out.add(PixabayImage.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {/* skip corrupted entry */}
    }
    return out;
  }

  Future<void> save(List<PixabayImage> items) => _prefs.setStringList(
        _key,
        items.map((e) => jsonEncode(e.toJson())).toList(),
      );
}