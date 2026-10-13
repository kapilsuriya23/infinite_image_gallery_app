import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../providers/gallery_providers.dart';

class CategoryChips extends ConsumerWidget {
  const CategoryChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(categoryProvider);
    final items = <String?>[null, ...AppConstants.categories];

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final c = items[i];
          final label = c == null ? 'All' : c[0].toUpperCase() + c.substring(1);
          return ChoiceChip(
            label: Text(label),
            selected: selected == c,
            onSelected: (_) => ref.read(categoryProvider.notifier).state = c,
          );
        },
      ),
    );
  }
}