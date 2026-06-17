import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import '../models/product_model.dart';

class ProductApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static bool isTestMode = false;

  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token');
  }

  static Map<String, String> _authHeaders(String token) => {
        'Authorization': 'Bearer $token',
      };

  /// Create product with multipart upload
  static Future<ProductModel> createProduct({
    required Map<String, String> fields,
    required String imagePath,
    required List<int> imageBytes,
    required String imageName,
  }) async {
    if (isTestMode) {
      return ProductModel(
        id: 'test',
        name: fields['name'] ?? 'test',
        description: fields['description'] ?? 'test',
        price: 1000,
        originalPrice: 1000,
        location: fields['location'] ?? 'test',
        imagePath: '',
        rating: 5.0,
        sold: 0,
      );
    }
    final token = await _getToken();
    if (token == null) throw Exception('Belum login');

    final uri = Uri.parse('$baseUrl/api/products');
    final request = http.MultipartRequest('POST', uri)
      ..headers.addAll(_authHeaders(token))
      ..fields.addAll(fields);

    MediaType? mediaType;
    final ext = imageName.split('.').last.toLowerCase();
    if (ext == 'jpg' || ext == 'jpeg') {
      mediaType = MediaType('image', 'jpeg');
    } else if (ext == 'png') {
      mediaType = MediaType('image', 'png');
    } else if (ext == 'webp') {
      mediaType = MediaType('image', 'webp');
    }

    request.files.add(
      http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
        contentType: mediaType,
      ),
    );

    final streamResponse = await request.send().timeout(
      const Duration(seconds: 30),
      onTimeout: () => throw Exception('Upload timeout'),
    );

    final response = await http.Response.fromStream(streamResponse);

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final product = ProductModel.fromJson(data['data']);
      // Resolve relative image URLs to absolute
      return _resolveImageUrls(product);
    }

    final error = jsonDecode(response.body);
    throw Exception(error['message'] ?? 'Gagal membuat produk');
  }

  /// Get products with pagination
  static Future<ProductListResponse> getProducts({
    int page = 1,
    int limit = 12,
    String? search,
  }) async {
    if (isTestMode) {
      return ProductListResponse(
        products: [],
        page: page,
        totalPages: 0,
        total: 0,
        hasMore: false,
      );
    }
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }

    final uri = Uri.parse('$baseUrl/api/products')
        .replace(queryParameters: queryParams);

    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw Exception('Koneksi timeout'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final products = (data['products'] as List)
          .map((json) => _resolveImageUrls(ProductModel.fromJson(json)))
          .toList();
      final pagination = data['pagination'] as Map<String, dynamic>;

      return ProductListResponse(
        products: products,
        page: pagination['page'] as int,
        totalPages: pagination['total_pages'] as int,
        total: pagination['total'] as int,
        hasMore: pagination['has_more'] as bool,
      );
    }

    throw Exception('Gagal memuat daftar produk');
  }

  /// Get single product by id
  static Future<ProductModel> getProductById(String id) async {
    final uri = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.get(uri).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return _resolveImageUrls(ProductModel.fromJson(data['data']));
    }

    throw Exception('Produk tidak ditemukan');
  }

  /// Delete product
  static Future<void> deleteProduct(String id) async {
    final token = await _getToken();
    if (token == null) throw Exception('Belum login');

    final uri = Uri.parse('$baseUrl/api/products/$id');
    final response = await http.delete(uri, headers: _authHeaders(token)).timeout(
      const Duration(seconds: 15),
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Gagal menghapus produk');
    }
  }

  /// Resolve relative image URLs to absolute URLs
  static ProductModel _resolveImageUrls(ProductModel product) {
    if (product.imageUrl != null &&
        product.imageUrl!.isNotEmpty &&
        !product.imageUrl!.startsWith('http')) {
      return ProductModel(
        id: product.id,
        name: product.name,
        description: product.description,
        imagePath: '$baseUrl${product.imageUrl}',
        imageUrl: '$baseUrl${product.imageUrl}',
        price: product.price,
        originalPrice: product.originalPrice,
        rating: product.rating,
        sold: product.sold,
        location: product.location,
        discount: product.discount,
        isOfficial: product.isOfficial,
        freeShipping: product.freeShipping,
        promoText: product.promoText,
        soldLabel: product.soldLabel,
        usePriceBadge: product.usePriceBadge,
        metaIcon: product.metaIcon,
        isPowerShop: product.isPowerShop,
        showDiscountBesidePrice: product.showDiscountBesidePrice,
      );
    }
    return product;
  }
}

class ProductListResponse {
  final List<ProductModel> products;
  final int page;
  final int totalPages;
  final int total;
  final bool hasMore;

  const ProductListResponse({
    required this.products,
    required this.page,
    required this.totalPages,
    required this.total,
    required this.hasMore,
  });
}
