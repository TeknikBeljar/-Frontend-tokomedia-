import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tokomedia/models/product_model.dart';
import 'package:tokomedia/widgets/mobile/product_card_mobile.dart';

void main() {
  testWidgets('renders the reference-style mobile discount icon', (
    tester,
  ) async {
    const product = ProductModel(
      id: 'mobile-test',
      name: 'Produk Mobile',
      description: '',
      imagePath: 'assets/images/products/mobile/1.jpeg',
      price: 10000,
      originalPrice: 20000,
      rating: 4.9,
      sold: 10,
      location: 'Jakarta',
      discount: 20,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 400,
            child: ProductCardMobile(product: product),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('mobile-discount-ticket-icon')), findsOneWidget);
    expect(find.text('Harga Diskon'), findsOneWidget);
    expect(find.byIcon(Icons.discount), findsNothing);
  });

  testWidgets('renders Power Shop badge inline for product 2', (tester) async {
    const product = ProductModel(
      id: 'm-2',
      name: 'MINI PC Gaming Intel Twin Lake N150 GMKtec',
      description: '',
      imagePath: 'assets/images/products/mobile/2.jpeg',
      price: 4829630,
      originalPrice: 5999000,
      rating: 4.9,
      sold: 88,
      location: 'Jakarta Utara',
      discount: 19,
      freeShipping: true,
      isPowerShop: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 400,
            child: ProductCardMobile(product: product),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('mobile-power-shop-icon')), findsOneWidget);
    expect(find.textContaining('Power Shop'), findsOneWidget);
    expect(
      find.textContaining('MINI PC Gaming Intel Twin Lake N150 GMKtec'),
      findsOneWidget,
    );
  });

  testWidgets('renders Power Shop badge inline for product 3', (tester) async {
    const product = ProductModel(
      id: 'm-3',
      name: 'VANCE HINES # 1800-1656 BIG RADIUS CHROME',
      description: '',
      imagePath: 'assets/images/products/mobile/3.jpeg',
      price: 33300000,
      originalPrice: 36900000,
      rating: 5.0,
      sold: 2,
      location: 'Kota Bandung',
      discount: 3,
      freeShipping: true,
      isPowerShop: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 400,
            child: ProductCardMobile(product: product),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('mobile-power-shop-icon')), findsOneWidget);
    expect(find.textContaining('Power Shop'), findsOneWidget);
    expect(
      find.textContaining('VANCE HINES # 1800-1656 BIG RADIUS CHROME'),
      findsOneWidget,
    );
  });

  testWidgets('wraps product 4 Mall badge and name into two tidy lines', (
    tester,
  ) async {
    const product = ProductModel(
      id: 'm-4',
      name: 'Barber Daily Acne Care & Oil Control Face Wash',
      description: '',
      imagePath: 'assets/images/products/mobile/4.jpeg',
      price: 40500,
      originalPrice: 45900,
      rating: 4.8,
      sold: 12000,
      location: 'Barber Daily Official',
      discount: 11,
      isOfficial: true,
      freeShipping: true,
    );

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 400,
            child: ProductCardMobile(product: product),
          ),
        ),
      ),
    );

    final title = tester.widget<RichText>(
      find
          .descendant(
            of: find.byKey(const Key('mobile-mall-product-title')),
            matching: find.byType(RichText),
          )
          .first,
    );

    expect(title.maxLines, 2);
    expect(title.overflow, TextOverflow.ellipsis);
    expect(
      find.textContaining('Barber Daily Acne Care & Oil Control Face Wash'),
      findsOneWidget,
    );
  });

  for (final productId in ['m-6', 'm-7']) {
    testWidgets('places discount beside price for $productId', (tester) async {
      final product = ProductModel(
        id: productId,
        name: productId == 'm-6'
            ? 'Boney Kapsul Kesehatan Tulang Kandungan Organik'
            : 'Scarlett Whitening Eau De Parfum Sweet Memories 30 ml',
        description: '',
        imagePath: productId == 'm-6'
            ? 'assets/images/products/mobile/6.jpeg'
            : 'assets/images/products/mobile/7.jpeg',
        price: productId == 'm-6' ? 91550 : 29449,
        originalPrice: productId == 'm-6' ? 299000 : 76000,
        rating: productId == 'm-6' ? 4.8 : 4.9,
        sold: productId == 'm-6' ? 3200 : 100000,
        location: productId == 'm-6'
            ? 'Tangerang Selatan'
            : 'Scarlett Whitening',
        discount: productId == 'm-6' ? 69 : 61,
        isOfficial: true,
        freeShipping: true,
        showDiscountBesidePrice: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 180,
              height: 400,
              child: ProductCardMobile(product: product),
            ),
          ),
        ),
      );

      expect(
        find.byKey(const Key('mobile-price-with-discount')),
        findsOneWidget,
      );
      final priceCenter = tester.getCenter(
        find.byKey(const Key('mobile-product-price')),
      );
      final discountCenter = tester.getCenter(
        find.byKey(const Key('mobile-discount-pill')),
      );
      expect((priceCenter.dy - discountCenter.dy).abs(), lessThan(2));
    });
  }
}
