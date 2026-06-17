import 'package:flutter/material.dart';

import '../../config/constants.dart';

class BottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;

  const BottomNav({
    super.key,
    required this.currentIndex,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: Row(
            children: [
              _BottomNavItem(
                label: 'Buat Kamu',
                icon: Icons.thumb_up_alt_outlined,
                selectedIcon: Icons.thumb_up_alt_rounded,
                selected: currentIndex == 0,
                onTap: () => onChanged(0),
              ),
              _BottomNavItem(
                label: 'Feed',
                icon: Icons.play_circle_outline_rounded,
                selectedIcon: Icons.play_circle_rounded,
                selected: currentIndex == 1,
                onTap: () => onChanged(1),
              ),
              _BottomNavItem(
                label: 'Mall',
                icon: Icons.storefront_outlined,
                selectedIcon: Icons.storefront_rounded,
                selected: currentIndex == 2,
                onTap: () => onChanged(2),
              ),
              _BottomNavItem(
                label: 'Transaksi',
                icon: Icons.receipt_long_outlined,
                selectedIcon: Icons.receipt_long_rounded,
                selected: currentIndex == 3,
                onTap: () => onChanged(3),
              ),
              _BottomNavItem(
                label: 'Akun',
                icon: Icons.person_outline_rounded,
                selectedIcon: Icons.person_rounded,
                selected: currentIndex == 4,
                onTap: () => onChanged(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomNavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final VoidCallback onTap;

  const _BottomNavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.green : const Color(0xFF6B7280);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(selected ? selectedIcon : icon, color: color, size: 26),
            const SizedBox(height: 3),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
