import 'package:flutter/material.dart';

import '../../config/constants.dart';

class RatingWidget extends StatelessWidget {
  final double rating;
  final int sold;

  const RatingWidget({super.key, required this.rating, required this.sold});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star, size: 14, color: Color(0xFFFFB300)),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            '$rating | terjual $sold',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
