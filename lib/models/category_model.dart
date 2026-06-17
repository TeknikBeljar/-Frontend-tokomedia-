import 'package:flutter/material.dart';

class Category {
  final String id;
  final String name;
  final IconData icon;
  final Color color;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
  });
}

class CheckCategory {
  final String title;
  final String subtitle;
  final String image;

  const CheckCategory({
    required this.title,
    required this.subtitle,
    required this.image,
  });
}
