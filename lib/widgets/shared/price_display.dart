import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../utils/currency_formatter.dart';

class PriceDisplay extends StatelessWidget {
  final int price;
  final int originalPrice;
  final bool compact;

  const PriceDisplay({
    super.key,
    required this.price,
    required this.originalPrice,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDiscount = originalPrice > price;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          compact
              ? CurrencyFormatter.formatCompact(price)
              : CurrencyFormatter.format(price),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        if (hasDiscount)
          Text(
            CurrencyFormatter.format(originalPrice),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }
}
