import 'package:flutter/material.dart';

import '../../utils/dummy_data.dart';

class CategoryTabs extends StatelessWidget {
  const CategoryTabs({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: DummyData.categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final category = DummyData.categories[index];
          return SizedBox(
            width: 72,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor: category.color.withValues(alpha: 0.12),
                  child: Icon(category.icon, color: category.color),
                ),
                const SizedBox(height: 8),
                Text(
                  category.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
