import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../models/category_model.dart';
import '../models/promo_model.dart';

class DummyData {
  static const List<Category> categories = [
    Category(
      id: 'cat-1',
      name: 'Elektronik',
      icon: Icons.devices,
      color: AppColors.blue,
    ),
    Category(
      id: 'cat-2',
      name: 'Fashion',
      icon: Icons.checkroom,
      color: AppColors.orange,
    ),
    Category(
      id: 'cat-3',
      name: 'Makanan',
      icon: Icons.restaurant,
      color: AppColors.green,
    ),
    Category(
      id: 'cat-4',
      name: 'Rumah',
      icon: Icons.weekend,
      color: Color(0xFF7C4DFF),
    ),
    Category(
      id: 'cat-5',
      name: 'Kecantikan',
      icon: Icons.spa,
      color: Color(0xFFE91E63),
    ),
    Category(
      id: 'cat-6',
      name: 'Hobi',
      icon: Icons.sports_esports,
      color: Color(0xFF795548),
    ),
  ];

  static const List<PromoModel> promos = [
    PromoModel(
      title: 'Flash Sale',
      subtitle: 'Diskon sampai 70%',
      icon: Icons.flash_on,
      color: AppColors.orange,
      backgroundColor: Color(0xFFFFF3E6),
    ),
    PromoModel(
      title: 'Gratis Ongkir',
      subtitle: 'Min. belanja Rp20rb',
      icon: Icons.local_shipping,
      color: AppColors.green,
      backgroundColor: AppColors.greenSoft,
    ),
    PromoModel(
      title: 'COD',
      subtitle: 'Bayar di tempat',
      icon: Icons.payments,
      color: AppColors.blue,
      backgroundColor: Color(0xFFEAF4FF),
    ),
  ];
}
