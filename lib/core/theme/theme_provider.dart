import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../storage/storage_providers.dart';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  static const _key = 'theme_mode';

  @override
  ThemeMode build() {
    final i = ref.read(sharedPreferencesProvider).getInt(_key);
    return i == null ? ThemeMode.system : ThemeMode.values[i];
  }

  /// system -> light -> dark -> system
  void cycle() {
    final next = ThemeMode.values[(state.index + 1) % ThemeMode.values.length];
    state = next;
    ref.read(sharedPreferencesProvider).setInt(_key, next.index);
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);