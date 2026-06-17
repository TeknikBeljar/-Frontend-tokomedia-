import 'package:flutter/material.dart';

import '../../config/constants.dart';

class HeroBannerWeb extends StatelessWidget {
  const HeroBannerWeb({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: AspectRatio(
        aspectRatio: 1208 / 267,
        child: Image.asset(AppAssets.heroPromo, fit: BoxFit.cover),
      ),
    );
  }
}
