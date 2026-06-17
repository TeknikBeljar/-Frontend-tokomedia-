import 'package:flutter_test/flutter_test.dart';
import 'package:tokomedia/models/product_model.dart';
import 'package:tokomedia/providers/product_provider.dart';

void main() {
  test('catalog starts empty without bundled products', () {
    final provider = ProductProvider();

    expect(provider.products, isEmpty);
    expect(provider.apiProducts, isEmpty);
  });

  test('catalog shows products added after backend upload', () {
    final provider = ProductProvider();
    const uploadedProduct = ProductModel(
      id: 'database-product',
      name: 'Produk Upload',
      description: '',
      imagePath: 'https://example.com/product.png',
      price: 10000,
      originalPrice: 10000,
      rating: 5,
      sold: 0,
      location: 'Jakarta',
    );

    provider.addProduct(uploadedProduct);

    expect(provider.products, [uploadedProduct]);
  });

  test('uploaded products keep their left-to-right upload order', () {
    final provider = ProductProvider();
    const firstProduct = ProductModel(
      id: 'product-1',
      name: 'Produk 1',
      description: '',
      imagePath: 'https://example.com/product-1.png',
      price: 10000,
      originalPrice: 10000,
      rating: 5,
      sold: 0,
      location: 'Jakarta',
    );
    const secondProduct = ProductModel(
      id: 'product-2',
      name: 'Produk 2',
      description: '',
      imagePath: 'https://example.com/product-2.png',
      price: 20000,
      originalPrice: 20000,
      rating: 5,
      sold: 0,
      location: 'Bandung',
    );

    provider.addProduct(firstProduct);
    provider.addProduct(secondProduct);

    expect(provider.products.map((product) => product.id), [
      'product-1',
      'product-2',
    ]);
  });
}
