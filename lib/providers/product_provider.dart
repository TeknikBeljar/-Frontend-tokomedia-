import 'package:flutter/foundation.dart';

import '../models/product_model.dart';
import '../services/product_api_service.dart';

class ProductProvider extends ChangeNotifier {
  String _query = '';
  List<ProductModel> _apiProducts = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  String? _error;
  bool _initialFetchDone = false;

  String get query => _query;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;
  String? get error => _error;

  /// Products loaded from the backend database.
  List<ProductModel> get products => _filteredApi;

  List<ProductModel> get _filteredApi {
    if (_query.trim().isEmpty) return _apiProducts;
    final lower = _query.toLowerCase();
    return _apiProducts
        .where((p) => p.name.toLowerCase().contains(lower))
        .toList();
  }

  /// Products from API only (for cases that need them separately)
  List<ProductModel> get apiProducts => List.unmodifiable(_apiProducts);

  void search(String value) {
    _query = value;
    notifyListeners();
  }

  /// Fetch products from API (initial load or refresh)
  Future<void> fetchProducts({bool refresh = false}) async {
    if (_isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _apiProducts = [];
      _hasMore = true;
      _error = null;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await ProductApiService.getProducts(
        page: _currentPage,
        limit: 12,
      );

      _apiProducts = refresh
          ? response.products
          : [..._apiProducts, ...response.products];
      _hasMore = response.hasMore;
      _currentPage = response.page + 1;
      _initialFetchDone = true;
    } catch (e) {
      _error = e.toString();
      _initialFetchDone = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Load more products (pagination)
  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await fetchProducts();
  }

  /// Add a newly created product to the local list (after backend confirms)
  void addProduct(ProductModel product) {
    _apiProducts.add(product);
    notifyListeners();
  }

  /// Remove a product from local list
  void removeProduct(String productId) {
    _apiProducts.removeWhere((p) => p.id == productId);
    notifyListeners();
  }

  /// Delete product via API and update local state
  Future<void> deleteProduct(String productId) async {
    try {
      await ProductApiService.deleteProduct(productId);
      removeProduct(productId);
    } catch (e) {
      rethrow;
    }
  }

  /// Whether initial data fetch has been attempted
  bool get initialFetchDone => _initialFetchDone;
}
