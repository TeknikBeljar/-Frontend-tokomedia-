import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokomedia/models/product_model.dart';
import 'package:tokomedia/widgets/web/product_card_web.dart';

void main() {
  testWidgets('renders the reference discount and price badge', (tester) async {
    const product = ProductModel(
      id: 'web-price-badge-test',
      name: 'Produk Test',
      description: '',
      imagePath: 'assets/images/web_ref/product_10.png',
      price: 289000,
      originalPrice: 749000,
      rating: 4.9,
      sold: 100,
      soldLabel: '100+',
      location: 'Toko Test',
      discount: 61,
      promoText: 'Hemat s.d 15% Pakai Bonus',
      usePriceBadge: true,
      metaIcon: ProductMetaIcon.officialStore,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 188,
            height: 370,
            child: ProductCardWeb(product: product),
          ),
        ),
      ),
    );

    expect(find.text('61%'), findsOneWidget);
    expect(find.text('Rp289.000'), findsOneWidget);
    expect(find.text('Hemat s.d 15% Pakai Bonus'), findsOneWidget);
    expect(find.text('4.9 \u00B7 100+ terjual'), findsOneWidget);
    expect(find.byKey(const Key('web-discount-ticket-icon')), findsOneWidget);
    expect(find.byIcon(Icons.discount_outlined), findsNothing);
  });

  testWidgets('renders the crown city icon', (tester) async {
    const product = ProductModel(
      id: 'web-crown-test',
      name: 'Produk Test',
      description: '',
      imagePath: 'assets/images/web_ref/product_11.png',
      price: 100000,
      originalPrice: 100000,
      rating: 5,
      sold: 2,
      location: 'Kota Bandung',
      promoText: '',
      metaIcon: ProductMetaIcon.powerMerchant,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 188,
            height: 370,
            child: ProductCardWeb(product: product),
          ),
        ),
      ),
    );

    expect(
      find.byKey(const Key('web-power-merchant-icon-web-crown-test')),
      findsOneWidget,
    );
  });
}
