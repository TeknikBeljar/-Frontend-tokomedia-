enum ProductMetaIcon { legacy, none, officialStore, powerMerchant }

class ProductModel {
  final String id;
  final String name;
  final String description;
  final String imagePath;
  final String? imageUrl;
  final int price;
  final int originalPrice;
  final double rating;
  final int sold;
  final String location;
  final int discount;
  final bool isOfficial;
  final bool freeShipping;
  final String promoText;
  final String? soldLabel;
  final bool usePriceBadge;
  final ProductMetaIcon metaIcon;
  final bool isPowerShop;
  final bool showDiscountBesidePrice;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.imagePath,
    this.imageUrl,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.sold,
    required this.location,
    this.discount = 0,
    this.isOfficial = false,
    this.freeShipping = false,
    this.promoText = 'Hemat s.d 10% Pakai Bonus',
    this.soldLabel,
    this.usePriceBadge = false,
    this.metaIcon = ProductMetaIcon.legacy,
    this.isPowerShop = false,
    this.showDiscountBesidePrice = false,
  });

  /// Resolves the display image path: prefer imageUrl (network), fallback to imagePath (asset)
  String get resolvedImagePath => imageUrl ?? imagePath;

  /// Whether this product's image should be loaded from the network
  bool get isNetworkImage =>
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      imagePath.startsWith('http');

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    // Extract primary image URL from images array if present
    String? primaryImageUrl;
    if (json['images'] != null && (json['images'] as List).isNotEmpty) {
      final images = json['images'] as List;
      final primary = images.firstWhere(
        (img) => img['is_primary'] == true,
        orElse: () => images.first,
      );
      primaryImageUrl = primary['url'] as String?;
    }

    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      imagePath: primaryImageUrl ?? '',
      imageUrl: primaryImageUrl,
      price: (json['price'] as num).toInt(),
      originalPrice: (json['original_price'] as num).toInt(),
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      sold: (json['sold'] as num?)?.toInt() ?? 0,
      location: json['location'] as String? ?? '',
      discount: (json['discount'] as num?)?.toInt() ?? 0,
      isOfficial: json['is_official'] as bool? ?? false,
      freeShipping: json['free_shipping'] as bool? ?? false,
      promoText: json['promo_text'] as String? ?? '',
      soldLabel: json['sold_label'] as String?,
      usePriceBadge: json['use_price_badge'] as bool? ?? false,
      metaIcon: _parseMetaIcon(json['meta_icon'] as String? ?? 'none'),
      isPowerShop: json['is_power_shop'] as bool? ?? false,
      showDiscountBesidePrice: json['show_discount_beside'] as bool? ?? false,
    );
  }

  Map<String, String> toFormFields() {
    return {
      'name': name,
      'description': description,
      'price': price.toString(),
      'original_price': originalPrice.toString(),
      'discount': discount.toString(),
      'rating': rating.toString(),
      'sold': sold.toString(),
      if (soldLabel != null) 'sold_label': soldLabel!,
      'location': location,
      'promo_text': promoText,
      'free_shipping': freeShipping.toString(),
      'meta_icon': metaIcon.name,
      'is_official': isOfficial.toString(),
      'is_power_shop': isPowerShop.toString(),
      'use_price_badge': usePriceBadge.toString(),
      'show_discount_beside': showDiscountBesidePrice.toString(),
    };
  }

  static ProductMetaIcon _parseMetaIcon(String value) {
    return parseMetaIconPublic(value);
  }

  static ProductMetaIcon parseMetaIconPublic(String value) {
    switch (value) {
      case 'officialStore':
        return ProductMetaIcon.officialStore;
      case 'powerMerchant':
        return ProductMetaIcon.powerMerchant;
      case 'legacy':
        return ProductMetaIcon.legacy;
      default:
        return ProductMetaIcon.none;
    }
  }
}
