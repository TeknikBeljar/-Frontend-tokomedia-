import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';

class HeaderWeb extends StatelessWidget {
  final ValueChanged<String>? onSearch;

  const HeaderWeb({super.key, this.onSearch});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 1,
      shadowColor: Colors.black12,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 34,
            decoration: const BoxDecoration(
              color: Color(0xFFF3F4F5),
              border: Border(
                top: BorderSide(color: Color(0xFF202124), width: 2),
              ),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: const Row(
                  children: [
                    Icon(Icons.phone_iphone, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Gratis Ongkir + Banyak Promo',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('belanja di aplikasi', style: TextStyle(fontSize: 13)),
                    Icon(Icons.chevron_right, size: 18),
                    Spacer(),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Row(
                          children: [
                            _TopLink('Tentang Tokomedia'),
                            _TopLink('Pusat Edukasi Seller'),
                            _TopLink('Promo'),
                            _TopLink('Tokomedia Care'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: Row(
                  children: [
                    const SizedBox(width: 2),
                    const Text(
                      'tokomedia',
                      style: TextStyle(
                        color: AppColors.green,
                        fontSize: 34,
                        fontWeight: FontWeight.w500,
                        height: 1,
                      ),
                    ),
                    const SizedBox(width: 36),
                    const Text('Kategori', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 20),
                    Expanded(
                      child: SizedBox(
                        height: 40,
                        child: TextField(
                          onChanged: onSearch,
                          decoration: InputDecoration(
                            hintText: 'Cari di Tokomedia',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF6D7588),
                            ),
                            contentPadding: EdgeInsets.zero,
                            filled: true,
                            fillColor: Colors.white,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: Color(0xFFBAC4D1),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                color: AppColors.green,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 44),
                    const _HeaderIcon(
                      icon: Icons.shopping_cart_outlined,
                      badge: '5',
                    ),
                    const SizedBox(width: 18),
                    const _HeaderIcon(
                      icon: Icons.notifications_none,
                      badge: '17',
                    ),
                    const SizedBox(width: 18),
                    const Icon(Icons.mail_outline, size: 24),
                    const SizedBox(width: 28),
                    Container(width: 1, height: 24, color: AppColors.border),
                    const SizedBox(width: 28),
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFE9ECEF),
                      child: Icon(
                        Icons.storefront,
                        size: 18,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Toko', style: TextStyle(fontSize: 15)),
                    const SizedBox(width: 28),
                    PopupMenuButton<String>(
                      offset: const Offset(0, 40),
                      child: const Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundImage: AssetImage(AppAssets.profile),
                          ),
                          SizedBox(width: 8),
                          Text('Alif', style: TextStyle(fontSize: 15)),
                        ],
                      ),
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'upload',
                          child: Row(
                            children: [
                              Icon(Icons.upload_file, size: 20),
                              SizedBox(width: 8),
                              Text('Upload Product'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_sweep, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Hapus Produk'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(
                            children: [
                              Icon(Icons.logout, size: 20, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Keluar', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'upload') {
                          Navigator.pushNamed(context, '/upload-product');
                        } else if (value == 'delete') {
                          Navigator.pushNamed(context, '/delete-product');
                        } else if (value == 'logout') {
                          context.read<AuthProvider>().logout();
                          Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            height: 34,
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFF1F2F4))),
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1280),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Icon(Icons.location_on_outlined, size: 20),
                    SizedBox(width: 5),
                    Text(
                      'Pilih Alamat Pengirimanmu',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 12),
                    Icon(Icons.keyboard_arrow_down, size: 18),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopLink extends StatelessWidget {
  final String label;

  const _TopLink(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF42526E)),
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String badge;

  const _HeaderIcon({required this.icon, required this.badge});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon, size: 24),
        Positioned(
          right: -9,
          top: -8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: const Color(0xFFE12B57),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
