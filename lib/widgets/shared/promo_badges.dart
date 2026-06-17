import 'package:flutter/material.dart';

import '../../config/constants.dart';

class PromoBadges extends StatelessWidget {
  final int discount;
  final bool freeShipping;
  final bool official;

  const PromoBadges({
    super.key,
    required this.discount,
    required this.freeShipping,
    required this.official,
  });

  @override
  Widget build(BuildContext context) {
    final badges = <Widget>[
      if (discount > 0) _Badge(label: '$discount%', color: AppColors.red),
      if (freeShipping)
        const _Badge(label: 'Gratis ongkir', color: AppColors.green),
      if (official) const _Badge(label: 'Official', color: AppColors.blue),
    ];

    return Wrap(spacing: 4, runSpacing: 4, children: badges);
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ),
    );
  }
}
