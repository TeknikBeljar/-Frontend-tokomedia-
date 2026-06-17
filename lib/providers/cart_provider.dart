import 'package:flutter/foundation.dart';

import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final List<ProductModel> _items = [];

  List<ProductModel> get items => List.unmodifiable(_items);

  int get count => _items.length;

  int get total => _items.fold(0, (sum, product) => sum + product.price);

  void add(ProductModel product) {
    _items.add(product);
    notifyListeners();
  }

  void remove(ProductModel product) {
    _items.removeWhere((item) => item.id == product.id);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
