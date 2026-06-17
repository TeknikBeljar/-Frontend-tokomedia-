import 'package:flutter/material.dart';

class AppColors {
  static const Color green = Color(0xFF03AC0E);
  static const Color greenDark = Color(0xFF018A0B);
  static const Color greenSoft = Color(0xFFE8F8EA);
  static const Color red = Color(0xFFE84040);
  static const Color orange = Color(0xFFFF7A00);
  static const Color blue = Color(0xFF1E88E5);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF6D7588);
  static const Color border = Color(0xFFE5E7EB);
  static const Color surface = Color(0xFFF6F7F9);
}

class AppAssets {
  static const String webProductPath = 'assets/images/products/web';
  static const String mobileProductPath = 'assets/images/products/mobile';
  static const String webRefPath = 'assets/images/web_ref';
  static const String heroPromo = '$webRefPath/hero_pasdidiskon.png';
  static const String categoryBanner = '$webRefPath/category_banner.png';
  static const String profile = '$webRefPath/avatar.png';
  static const String googleIcon = '$webRefPath/google.png';
  static const String tiktokIcon = '$webRefPath/tiktok_icon.png';
  static const String loginReference = '$webRefPath/login.png';
  static const String loginBackground = '$webRefPath/login_background.png';
  static const String registerReference = '$webRefPath/register.png';
  static const String registerIllustration =
      '$webRefPath/register_illustration.png';

  static const List<String> webProducts = [
    '$webRefPath/product_01.png',
    '$webRefPath/product_02.png',
    '$webRefPath/product_03.png',
    '$webRefPath/product_04.png',
    '$webRefPath/product_05.png',
    '$webRefPath/product_06.png',
    '$webRefPath/product_07.png',
    '$webRefPath/product_08.png',
    '$webRefPath/product_09.png',
    '$webRefPath/product_10.png',
    '$webRefPath/product_11.png',
    '$webRefPath/product_12.png',
  ];

  static const List<String> mobileProducts = [
    '$mobileProductPath/1.jpeg',
    '$mobileProductPath/2.jpeg',
    '$mobileProductPath/3.jpeg',
    '$mobileProductPath/4.jpeg',
    '$mobileProductPath/5.png',
    '$mobileProductPath/6.jpeg',
    '$mobileProductPath/7.jpeg',
    '$mobileProductPath/8.jpeg',
    '$mobileProductPath/cell2.jpeg',
  ];
}

class AppBreakpoints {
  static const double tablet = 720;
  static const double desktop = 1024;
}
