import 'package:flutter/material.dart';

class PromoModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final Color backgroundColor;

  const PromoModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.backgroundColor,
  });
}
