import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/mobile/bottom_nav.dart';
import '../../widgets/mobile/product_card_mobile.dart';
import 'akun_mobile.dart';
import 'feed_mobile.dart';
import 'mall_mobile.dart';
import 'transaksi_mobile.dart';

class HomeMobile extends StatefulWidget {
  const HomeMobile({super.key});

  @override
  State<HomeMobile> createState() => _HomeMobileState();
}

class _HomeMobileState extends State<HomeMobile> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<ProductProvider>().fetchProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _HomeContent(),
      const FeedMobile(),
      const MallMobile(),
      const TransaksiMobile(),
      const AkunMobile(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: pages[_index],
      bottomNavigationBar: BottomNav(
        currentIndex: _index,
        onChanged: (value) => setState(() => _index = value),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// HOME CONTENT
// ─────────────────────────────────────────────
class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    final productProvider = context.watch<ProductProvider>();
    final products = productProvider.products;
    
    // Split products into left and right columns
    final leftProducts = <ProductModel>[];
    final rightProducts = <ProductModel>[];
    for (int i = 0; i < products.length; i++) {
      if (i % 2 == 0) {
        leftProducts.add(products[i]);
      } else {
        rightProducts.add(products[i]);
      }
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          elevation: 0,
          toolbarHeight: 66,
          titleSpacing: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: const _MobileSearchHeader(),
        ),
        const SliverToBoxAdapter(child: _BalancePromoBanner()),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        const SliverToBoxAdapter(child: _FeatureStrip()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverToBoxAdapter(child: _ContinueCheckingSection()),
        const SliverToBoxAdapter(child: SizedBox(height: 20)),
        const SliverPersistentHeader(
          pinned: true,
          delegate: _TabsHeaderDelegate(),
        ),
        const SliverToBoxAdapter(child: _FlashSalePreview()),
        SliverToBoxAdapter(
          child: _MasonryProductGrid(
            leftProducts: leftProducts,
            rightProducts: rightProducts,
          ),
        ),
        if (productProvider.hasMore)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: ElevatedButton(
                onPressed: productProvider.isLoading
                    ? null
                    : () => productProvider.loadMore(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.green,
                  side: const BorderSide(color: AppColors.green),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: productProvider.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text(
                        'Muat Lebih Banyak',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SEARCH HEADER
// ─────────────────────────────────────────────
class _MobileSearchHeader extends StatelessWidget {
  const _MobileSearchHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 10, 10, 10),
      child: Row(
        children: [
          Expanded(child: _SearchBox()),
          SizedBox(width: 8),
          _BadgedHeaderIcon(
            icon: Icons.chat_bubble_outline_rounded,
            badge: '17',
          ),
          SizedBox(width: 2),
          _BadgedHeaderIcon(
            icon: Icons.shopping_cart_outlined,
            badge: '5',
          ),
        ],
      ),
    );
  }
}

class _SearchBox extends StatelessWidget {
  const _SearchBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFF2F3437), width: 1.8),
        borderRadius: BorderRadius.circular(22),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: const Row(
        children: [
          Icon(Icons.search_rounded, color: Color(0xFF8B8F94), size: 20),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'abaya',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF8B8F94),
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BadgedHeaderIcon extends StatelessWidget {
  final IconData icon;
  final String badge;

  const _BadgedHeaderIcon({required this.icon, required this.badge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 36,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 2,
            bottom: 6,
            child: Icon(icon, color: Colors.black, size: 26),
          ),
          Positioned(
            right: -2,
            top: 2,
            child: Container(
              height: 18,
              constraints: const BoxConstraints(minWidth: 18),
              padding: const EdgeInsets.symmetric(horizontal: 3),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: const Color(0xFFE62E63),
                border: Border.all(color: Colors.white, width: 1.5),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// PROMO BANNER
// ─────────────────────────────────────────────
class _BalancePromoBanner extends StatelessWidget {
  const _BalancePromoBanner();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return SizedBox(
      width: double.infinity,
      height: width * 0.38,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            '${AppAssets.mobileProductPath}/benner1.png',
            fit: BoxFit.cover,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 10,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _PageDot(active: false),
                SizedBox(width: 5),
                _PageDot(active: true),
                SizedBox(width: 5),
                _PageDot(active: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDot extends StatelessWidget {
  final bool active;

  const _PageDot({required this.active});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: active ? 24 : 7,
      height: 7,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: active ? 0.95 : 0.45),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FEATURE STRIP
// ─────────────────────────────────────────────
class _FeatureStrip extends StatelessWidget {
  const _FeatureStrip();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 116,
      child: Column(
        children: [
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: const [
                _PlusFeatureCard(),
                SizedBox(width: 10),
                _FeatureShortcut(
                  image: '${AppAssets.mobileProductPath}/top-up.png',
                  label: 'Top-Up &\nTagihan',
                ),
                _FeatureShortcut(
                  image: '${AppAssets.mobileProductPath}/bonus.png',
                  label: 'Bonus',
                ),
                _FeatureShortcut(
                  image: '${AppAssets.mobileProductPath}/dapetin.png',
                  label: 'Dapetin\nRp500rb',
                ),
                _FeatureShortcut(
                  image: '${AppAssets.mobileProductPath}/beli lokal.png',
                  label: 'Beli Lokal',
                ),
                _FeatureShortcut(
                  image: '${AppAssets.mobileProductPath}/cell1.png',
                  label: 'Tarik\nSaldo',
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 28,
                height: 5,
                decoration: BoxDecoration(
                  color: AppColors.green,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 20,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFE4E7EC),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlusFeatureCard extends StatelessWidget {
  const _PlusFeatureCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 106,
        height: 78,
        child: Image.asset(
          '${AppAssets.mobileProductPath}/extar kupon.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _FeatureShortcut extends StatelessWidget {
  final String image;
  final String label;

  const _FeatureShortcut({required this.image, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Image.asset(image, fit: BoxFit.contain),
          ),
          const SizedBox(height: 5),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 11.5,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CONTINUE CHECKING SECTION
// ─────────────────────────────────────────────
class _ContinueCheckingSection extends StatelessWidget {
  const _ContinueCheckingSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            'Lanjut cek ini, yuk',
            style: TextStyle(
              color: Color(0xFF303133),
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 160,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            children: const [
              _RecentCard(
                image: '${AppAssets.mobileProductPath}/product 1 pada bawa Flasc sale.jpeg',
                title: 'Balik lihat',
                subtitle: 'Celana Cargo Pria',
              ),
              _RecentCard(
                image: '${AppAssets.mobileProductPath}/product 2 pada bawa Flasc sale.jpeg',
                title: 'Terakhir cek',
                subtitle: 'Kaos Pria',
              ),
              _RecentCard(
                image: '${AppAssets.mobileProductPath}/product 3 pada bawa Flasc sale.jpeg',
                title: 'Incaranmu',
                subtitle: 'Sleeping Bag',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentCard extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _RecentCard({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      margin: const EdgeInsets.only(right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: AspectRatio(
              aspectRatio: 1,
              child: Image.asset(image, fit: BoxFit.cover),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF303133),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFF6B7280),
              fontSize: 11,
              height: 1.1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SEGMENT TABS (sticky)
// ─────────────────────────────────────────────
class _TabsHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _TabsHeaderDelegate();

  @override
  double get minExtent => 52;

  @override
  double get maxExtent => 52;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      elevation: overlapsContent ? 2 : 0,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: const _SegmentTabs(),
    );
  }

  @override
  bool shouldRebuild(covariant _TabsHeaderDelegate oldDelegate) => false;
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs();

  @override
  Widget build(BuildContext context) {
    return ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      children: const [
        _TextTab(label: 'For Alif', selected: true),
        SizedBox(width: 16),
        Center(child: _MallBadge()),
        SizedBox(width: 20),
        _TextTab(label: 'Elektronik'),
        SizedBox(width: 20),
        _TextTab(label: 'Handphone & Gadget'),
        SizedBox(width: 20),
        _TextTab(label: 'Fashion'),
        SizedBox(width: 20),
        _TextTab(label: 'Rumah Tangga'),
      ],
    );
  }
}

class _TextTab extends StatelessWidget {
  final String label;
  final bool selected;

  const _TextTab({required this.label, this.selected = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 52,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: selected ? AppColors.green : Colors.black,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: selected ? 34 : 0,
            height: 3,
            decoration: BoxDecoration(
              color: selected ? AppColors.green : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ],
      ),
    );
  }
}

class _MallBadge extends StatelessWidget {
  const _MallBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 26,
      padding: const EdgeInsets.only(left: 3, right: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: const Color(0xFF7B2AE8),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'Mall',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// FLASH SALE PREVIEW  (with countdown timer)
// ─────────────────────────────────────────────
class _FlashSalePreview extends StatefulWidget {
  const _FlashSalePreview();

  @override
  State<_FlashSalePreview> createState() => _FlashSalePreviewState();
}

class _FlashSalePreviewState extends State<_FlashSalePreview> {
  late int _seconds;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // start at 22:52:39
    _seconds = 22 * 3600 + 52 * 60 + 39;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_seconds > 0) _seconds--;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timeLabel {
    final h = _seconds ~/ 3600;
    final m = (_seconds % 3600) ~/ 60;
    final s = _seconds % 60;
    return '${h.toString().padLeft(2, '0')}:'
        '${m.toString().padLeft(2, '0')}:'
        '${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 14, 10, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Flash Sale header row
          Row(
            children: [
              const Text(
                'Flash Sale',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFE62E63),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _timeLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 220,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left flash sale card (two stacked products)
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          '${AppAssets.mobileProductPath}/cell1.png',
                          fit: BoxFit.cover,
                        ),
                        // Price overlays
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.55),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            padding: const EdgeInsets.fromLTRB(8, 20, 8, 8),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Rp31.731',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  'Rp84.000',
                                  style: TextStyle(
                                    color: Color(0xFFCCCCCC),
                                    fontSize: 11,
                                    decoration: TextDecoration.lineThrough,
                                    decorationColor: Color(0xFFCCCCCC),
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
                const SizedBox(width: 10),
                // Right product card
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                '${AppAssets.mobileProductPath}/cell2.jpeg',
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 7, vertical: 4),
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE62E63),
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    topRight: Radius.circular(8),
                                  ),
                                ),
                                child: const Text(
                                  '>3%',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Rp52.245',
                        style: TextStyle(
                          color: Color(0xFFD81B60),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Text(
                        'Rp115.000',
                        style: TextStyle(
                          color: Color(0xFF9CA3AF),
                          fontSize: 11,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: Color(0xFF9CA3AF),
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────
// MASONRY PRODUCT GRID
// ─────────────────────────────────────────────
class _MasonryProductGrid extends StatelessWidget {
  final List<ProductModel> leftProducts;
  final List<ProductModel> rightProducts;

  const _MasonryProductGrid({
    required this.leftProducts,
    required this.rightProducts,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _MasonryColumn(products: leftProducts)),
          const SizedBox(width: 10),
          Expanded(child: _MasonryColumn(products: rightProducts)),
        ],
      ),
    );
  }
}

class _MasonryColumn extends StatelessWidget {
  final List<ProductModel> products;

  const _MasonryColumn({required this.products});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < products.length; index++) ...[
          ProductCardMobile(product: products[index]),
          if (index != products.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────
// PRODUCT CATALOG DATA
// ─────────────────────────────────────────────
