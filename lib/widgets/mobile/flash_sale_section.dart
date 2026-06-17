import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../models/product_model.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/image_helper.dart';

class FlashSaleSection extends StatelessWidget {
  final List<ProductModel> products;

  const FlashSaleSection({super.key, this.products = const []});

  @override
  Widget build(BuildContext context) {
    final visibleProducts = products.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Flash Sale',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 178,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: visibleProducts.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final product = visibleProducts[index];
              return Container(
                width: 132,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AspectRatio(
                      aspectRatio: 1.2,
                      child: ImageHelper.resolveProductImage(
                        product.resolvedImagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            CurrencyFormatter.formatCompact(product.price),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 4),
                          LinearProgressIndicator(
                            value: 0.45 + (index * 0.08),
                            minHeight: 5,
                            color: AppColors.red,
                            backgroundColor: const Color(0xFFFFE3E3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
