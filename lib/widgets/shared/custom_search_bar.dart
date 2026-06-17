import 'package:flutter/material.dart';

import '../../config/constants.dart';

class CustomSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  final String hintText;

  const CustomSearchBar({
    super.key,
    this.onChanged,
    this.hintText = 'Cari barang impianmu',
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: AppColors.textSecondary),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
      ),
    );
  }
}
