import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/constants.dart';
import '../../models/product_model.dart';
import '../../providers/product_provider.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/image_helper.dart';

class ProductCardMobile extends StatelessWidget {
  final ProductModel product;

  const ProductCardMobile({super.key, required this.product});

  void _showDeleteConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Produk'),
        content: const Text('Apakah Anda yakin ingin menghapus produk ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await context.read<ProductProvider>().deleteProduct(product.id);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Produk berhasil dihapus'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString().replaceAll('Exception: ', '')),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              AspectRatio(
                aspectRatio: 1,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: ImageHelper.resolveProductImage(
                    product.resolvedImagePath,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              if (product.discount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _DiscountBadge(discount: product.discount),
                ),
              if (product.freeShipping)
                const Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _VoucherStrip(),
                ),
            ],
          ),
          const SizedBox(height: 7),
          if (product.isPowerShop)
            _PowerShopProductTitle(name: product.name)
          else if (product.isOfficial)
            _MallProductTitle(name: product.name)
          else
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.15,
                color: Colors.black,
              ),
            ),
          const SizedBox(height: 6),
          if (product.showDiscountBesidePrice)
            Row(
              key: const Key('mobile-price-with-discount'),
              children: [
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: _ProductPrice(price: product.price),
                  ),
                ),
                const SizedBox(width: 6),
                const _CouponPill(label: 'Harga Diskon', compact: true),
              ],
            )
          else ...[
            Align(
              alignment: Alignment.centerLeft,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: _ProductPrice(price: product.price),
              ),
            ),
            const SizedBox(height: 7),
            const _CouponPill(label: 'Harga Diskon'),
          ],
          const SizedBox(height: 6),
          if (product.discount <= 15)
            const Padding(
              padding: EdgeInsets.only(bottom: 5),
              child: _BonusPill(label: 'Hemat s.d 10% Pakai Bonus'),
            ),
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC400),
                size: 15,
              ),
              const SizedBox(width: 3),
              Expanded(
                child: Text(
                  '${product.rating.toStringAsFixed(1)} - ${_soldLabel(product.sold)} terjual',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.location,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                    height: 1,
                  ),
                ),
              ),
              const Text(
                '...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _soldLabel(int sold) {
    if (sold >= 100000) {
      return '100rb+';
    }
    if (sold >= 10000) {
      return '${(sold / 1000).round()}rb+';
    }
    if (sold >= 1000) {
      return '${(sold / 1000).toStringAsFixed(0)}rb+';
    }
    return '$sold';
  }
}

class _ProductPrice extends StatelessWidget {
  final int price;

  const _ProductPrice({required this.price});

  @override
  Widget build(BuildContext context) {
    return Text(
      CurrencyFormatter.format(price),
      key: const Key('mobile-product-price'),
      maxLines: 1,
      style: const TextStyle(
        color: Color(0xFFD81B60),
        fontSize: 18,
        fontWeight: FontWeight.w800,
        height: 1,
      ),
    );
  }
}

class _MallProductTitle extends StatelessWidget {
  final String name;

  const _MallProductTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      key: const Key('mobile-mall-product-title'),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.15,
          color: Colors.black,
        ),
        children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(right: 5),
              child: _MallMiniBadge(),
            ),
          ),
          TextSpan(text: name),
        ],
      ),
    );
  }
}

class _PowerShopProductTitle extends StatelessWidget {
  final String name;

  const _PowerShopProductTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      TextSpan(
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.15,
          color: Colors.black,
        ),
        children: [
          const WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: EdgeInsets.only(right: 3),
              child: _PowerShopIcon(),
            ),
          ),
          const TextSpan(
            text: 'Power Shop',
            style: TextStyle(
              color: Color(0xFF169447),
              fontWeight: FontWeight.w700,
            ),
          ),
          const TextSpan(text: '  '),
          TextSpan(text: name),
        ],
      ),
    );
  }
}

class _PowerShopIcon extends StatelessWidget {
  const _PowerShopIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: Key('mobile-power-shop-icon'),
      width: 16,
      height: 16,
      child: CustomPaint(painter: _PowerShopIconPainter()),
    );
  }
}

class _PowerShopIconPainter extends CustomPainter {
  const _PowerShopIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final hexagon = Path()
      ..moveTo(size.width * 0.5, size.height * 0.02)
      ..cubicTo(
        size.width * 0.55,
        size.height * 0.02,
        size.width * 0.58,
        size.height * 0.04,
        size.width * 0.62,
        size.height * 0.06,
      )
      ..lineTo(size.width * 0.9, size.height * 0.23)
      ..cubicTo(
        size.width * 0.96,
        size.height * 0.27,
        size.width * 0.98,
        size.height * 0.32,
        size.width * 0.98,
        size.height * 0.39,
      )
      ..lineTo(size.width * 0.98, size.height * 0.72)
      ..cubicTo(
        size.width * 0.98,
        size.height * 0.79,
        size.width * 0.95,
        size.height * 0.84,
        size.width * 0.89,
        size.height * 0.88,
      )
      ..lineTo(size.width * 0.61, size.height * 0.95)
      ..cubicTo(
        size.width * 0.56,
        size.height * 0.98,
        size.width * 0.53,
        size.height * 0.99,
        size.width * 0.5,
        size.height * 0.99,
      )
      ..cubicTo(
        size.width * 0.47,
        size.height * 0.99,
        size.width * 0.44,
        size.height * 0.98,
        size.width * 0.39,
        size.height * 0.95,
      )
      ..lineTo(size.width * 0.11, size.height * 0.78)
      ..cubicTo(
        size.width * 0.05,
        size.height * 0.74,
        size.width * 0.02,
        size.height * 0.69,
        size.width * 0.02,
        size.height * 0.62,
      )
      ..lineTo(size.width * 0.02, size.height * 0.38)
      ..cubicTo(
        size.width * 0.02,
        size.height * 0.31,
        size.width * 0.05,
        size.height * 0.26,
        size.width * 0.11,
        size.height * 0.22,
      )
      ..lineTo(size.width * 0.39, size.height * 0.05)
      ..cubicTo(
        size.width * 0.43,
        size.height * 0.03,
        size.width * 0.46,
        size.height * 0.02,
        size.width * 0.5,
        size.height * 0.02,
      )
      ..close();

    canvas.drawPath(hexagon, Paint()..color = const Color(0xFF04854C));

    final crown = Path()
      ..moveTo(size.width * 0.21, size.height * 0.43)
      ..cubicTo(
        size.width * 0.2,
        size.height * 0.39,
        size.width * 0.24,
        size.height * 0.36,
        size.width * 0.28,
        size.height * 0.39,
      )
      ..lineTo(size.width * 0.4, size.height * 0.49)
      ..lineTo(size.width * 0.49, size.height * 0.29)
      ..cubicTo(
        size.width * 0.51,
        size.height * 0.25,
        size.width * 0.55,
        size.height * 0.25,
        size.width * 0.57,
        size.height * 0.29,
      )
      ..lineTo(size.width * 0.66, size.height * 0.49)
      ..lineTo(size.width * 0.78, size.height * 0.39)
      ..cubicTo(
        size.width * 0.82,
        size.height * 0.36,
        size.width * 0.86,
        size.height * 0.39,
        size.width * 0.85,
        size.height * 0.43,
      )
      ..lineTo(size.width * 0.8, size.height * 0.72)
      ..cubicTo(
        size.width * 0.79,
        size.height * 0.77,
        size.width * 0.76,
        size.height * 0.78,
        size.width * 0.72,
        size.height * 0.78,
      )
      ..lineTo(size.width * 0.34, size.height * 0.78)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.78,
        size.width * 0.27,
        size.height * 0.77,
        size.width * 0.26,
        size.height * 0.72,
      )
      ..close();

    canvas.drawPath(
      crown,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant _PowerShopIconPainter oldDelegate) => false;
}

class _DiscountBadge extends StatelessWidget {
  final int discount;

  const _DiscountBadge({required this.discount});

  @override
  Widget build(BuildContext context) {
    final prefix = discount <= 7 ? '>' : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: const BoxDecoration(
        color: Color(0xFFE62E63),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          topRight: Radius.circular(7),
        ),
      ),
      child: Text(
        '$prefix$discount%',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _VoucherStrip extends StatelessWidget {
  const _VoucherStrip();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 23,
      child: Row(
        children: [
          Expanded(
            child: _VoucherTile(
              label: 'XTRA\nVoucher',
              color: Color(0xFFE91E63),
            ),
          ),
          Expanded(
            child: _VoucherTile(
              label: 'GRATIS\nONGKIR',
              color: AppColors.green,
            ),
          ),
          Expanded(
            child: _VoucherTile(
              label: 'Bonus\nCashback',
              color: Color(0xFFFFC928),
              textColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _VoucherTile extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;

  const _VoucherTile({
    required this.label,
    required this.color,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textColor,
          fontSize: 7.5,
          fontWeight: FontWeight.w900,
          height: 0.9,
        ),
      ),
    );
  }
}

class _MallMiniBadge extends StatelessWidget {
  const _MallMiniBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 18,
      padding: const EdgeInsets.only(left: 2, right: 5),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              color: const Color(0xFF7B2AE8),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 13,
            ),
          ),
          const SizedBox(width: 3),
          const Text(
            'Mall',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _CouponPill extends StatelessWidget {
  final String label;
  final bool compact;

  const _CouponPill({required this.label, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('mobile-discount-pill'),
      height: compact ? 22 : 24,
      padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0DC),
        border: Border.all(color: const Color(0xFFFF7183), width: 1.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _DiscountTicketIcon(compact: compact),
          SizedBox(width: compact ? 3 : 5),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: const Color(0xFFC00038),
              fontSize: compact ? 9.5 : 11.5,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

class _DiscountTicketIcon extends StatelessWidget {
  final bool compact;

  const _DiscountTicketIcon({this.compact = false});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('mobile-discount-ticket-icon'),
      width: compact ? 14 : 18,
      height: compact ? 13 : 16,
      child: const CustomPaint(painter: _DiscountTicketPainter()),
    );
  }
}

class _DiscountTicketPainter extends CustomPainter {
  const _DiscountTicketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const ticketColor = Color(0xFFD2003C);
    const pillColor = Color(0xFFFFF0DC);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(2.5),
      ),
      Paint()..color = ticketColor,
    );

    final notchPaint = Paint()..color = pillColor;
    canvas.drawCircle(Offset(0, size.height / 2), 2.2, notchPaint);
    canvas.drawCircle(
      Offset(size.width, size.height / 2),
      2.2,
      notchPaint,
    );

    final percentPainter = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(
          color: Color(0xFFFFFFE9),
          fontSize: 10,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    percentPainter.paint(
      canvas,
      Offset(
        (size.width - percentPainter.width) / 2,
        (size.height - percentPainter.height) / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _DiscountTicketPainter oldDelegate) => false;
}

class _BonusPill extends StatelessWidget {
  final String label;

  const _BonusPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFF5DCA2)),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Color(0xFFB07912),
          fontSize: 10.5,
          height: 1,
        ),
      ),
    );
  }
}
