import 'package:flutter/material.dart';

import '../../models/product_model.dart';
import 'product_card_web.dart';

class ProductGridWeb extends StatelessWidget {
  final List<ProductModel> products;

  const ProductGridWeb({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: products.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 6,
        mainAxisExtent: 370,
        crossAxisSpacing: 16,
        mainAxisSpacing: 30,
      ),
      itemBuilder: (context, index) {
        return ProductCardWeb(product: products[index]);
      },
    );
  }
}
