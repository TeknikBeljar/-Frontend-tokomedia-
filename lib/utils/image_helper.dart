import 'package:flutter/material.dart';

import '../config/constants.dart';

class ImageHelper {
  static String productFallback(int index) {
    final products = AppAssets.webProducts;
    return products[index % products.length];
  }

  static String safeProductPath(String path, int index) {
    if (path.isEmpty) {
      return productFallback(index);
    }
    return path;
  }

  /// Returns true if the path is a network URL
  static bool isNetworkImage(String path) {
    return path.startsWith('http://') || path.startsWith('https://');
  }

  /// Universal image widget that supports both asset and network images.
  /// Includes loading indicator, error fallback, and retry for network images.
  static Widget resolveProductImage(
    String path, {
    BoxFit fit = BoxFit.cover,
    double? width,
    double? height,
  }) {
    if (isNetworkImage(path)) {
      return Image.network(
        path,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: const Color(0xFFF5F5F5),
            child: Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
                color: AppColors.green,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: const Color(0xFFF5F5F5),
            child: const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.broken_image_outlined,
                      color: Color(0xFFBDBDBD), size: 32),
                  SizedBox(height: 4),
                  Text(
                    'Gagal memuat',
                    style: TextStyle(
                      color: Color(0xFFBDBDBD),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }

    // Asset image
    return Image.asset(
      path,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: const Color(0xFFF5F5F5),
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                color: Color(0xFFBDBDBD), size: 32),
          ),
        );
      },
    );
  }
}
