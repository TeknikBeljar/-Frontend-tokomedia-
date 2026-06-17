import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/web/category_nav.dart';
import '../../widgets/web/header_web.dart';
import '../../widgets/web/hero_banner_web.dart';
import '../../widgets/web/product_grid_web.dart';

class HomeWeb extends StatefulWidget {
  const HomeWeb({super.key});

  @override
  State<HomeWeb> createState() => _HomeWebState();
}

class _HomeWebState extends State<HomeWeb> {
  @override
  void initState() {
    super.initState();
    // Fetch products once after layout is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Column(
            children: [
              HeaderWeb(
                onSearch: (value) =>
                    context.read<ProductProvider>().search(value),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      const _ConstrainedContent(child: HeroBannerWeb()),
                      const SizedBox(height: 22),
                      const _ConstrainedContent(child: _PromoDashboard()),
                      const SizedBox(height: 42),
                      const _ConstrainedContent(child: CategoryNav()),
                      const SizedBox(height: 62),
                      Container(height: 8, color: const Color(0xFFF4F6F8)),
                      Container(
                        width: double.infinity,
                        color: const Color(0xFFFFFFED),
                        padding: const EdgeInsets.only(top: 48, bottom: 40),
                        child: _ConstrainedContent(
                          child: Column(
                            children: [
                              _ProductSection(products: products),
                              if (productProvider.hasMore)
                                Padding(
                                  padding: const EdgeInsets.only(top: 32),
                                  child: ElevatedButton(
                                    onPressed: productProvider.isLoading
                                        ? null
                                        : () => productProvider.loadMore(),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: AppColors.green,
                                      side: const BorderSide(
                                          color: AppColors.green),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 32, vertical: 16),
                                    ),
                                    child: productProvider.isLoading
                                        ? const SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                                strokeWidth: 2))
                                        : const Text('Muat Lebih Banyak',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const Positioned(right: 82, bottom: 36, child: _ChatButton()),
        ],
      ),
    );
  }
}

class _ConstrainedContent extends StatelessWidget {
  final Widget child;

  const _ConstrainedContent({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1210),
        child: child,
      ),
    );
  }
}

class _PromoDashboard extends StatelessWidget {
  const _PromoDashboard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 205,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kategori Populer',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.asset(
                      AppAssets.categoryBanner,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Top Up & Tagihan',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Lihat Semua',
                      style: TextStyle(
                        color: AppColors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 39,
                          child: Row(
                            children: [
                              _TopUpTab(label: 'Pulsa', active: true),
                              _TopUpTab(label: 'Paket Data'),
                              _TopUpTab(label: 'Listrik PLN'),
                              _TopUpTab(label: 'Roaming'),
                              SizedBox(width: 44, child: Icon(Icons.more_vert)),
                            ],
                          ),
                        ),
                        Container(height: 1, color: AppColors.border),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(12, 14, 12, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TopUpInput(
                                  label: 'Nomor Telepon',
                                  hint: 'Masukan Nomor',
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: _TopUpInput(
                                  label: 'Nominal',
                                  hint: '',
                                  showArrow: true,
                                ),
                              ),
                              SizedBox(width: 12),
                              SizedBox(
                                width: 92,
                                height: 40,
                                child: ElevatedButton(
                                  onPressed: null,
                                  child: Text('Beli'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopUpTab extends StatelessWidget {
  final String label;
  final bool active;

  const _TopUpTab({required this.label, this.active = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: active ? AppColors.green : Colors.transparent,
              width: 2,
            ),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? AppColors.green : const Color(0xFF53627C),
            fontWeight: FontWeight.w800,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class _TopUpInput extends StatelessWidget {
  final String label;
  final String hint;
  final bool showArrow;

  const _TopUpInput({
    required this.label,
    required this.hint,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF53627C),
            fontSize: 12,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFDCE2EA)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  hint,
                  style: const TextStyle(
                    color: Color(0xFF98A2B3),
                    fontSize: 12,
                  ),
                ),
              ),
              if (showArrow) const Icon(Icons.keyboard_arrow_down, size: 20),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductSection extends StatelessWidget {
  final List<ProductModel> products;

  const _ProductSection({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _ProductTabs(),
        const SizedBox(height: 30),
        ProductGridWeb(products: products),
      ],
    );
  }
}

class _ProductTabs extends StatelessWidget {
  const _ProductTabs();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          children: [
            const Text(
              'For Alif',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Container(width: 48, height: 3, color: AppColors.green),
          ],
        ),
        const SizedBox(width: 36),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_box, color: Color(0xFF7B3FE4), size: 22),
              SizedBox(width: 3),
              Text(
                'Mall',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 34),
        const Text(
          'Produk Incaranmu',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
      ],
    );
  }
}

class _ChatButton extends StatelessWidget {
  const _ChatButton();

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      shadowColor: Colors.black26,
      borderRadius: BorderRadius.circular(28),
      color: Colors.white,
      child: Container(
        height: 42,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(28)),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.chat_bubble, color: AppColors.green, size: 20),
            SizedBox(width: 10),
            Text(
              'Chat',
              style: TextStyle(
                color: AppColors.green,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
