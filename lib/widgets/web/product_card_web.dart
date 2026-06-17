import 'package:flutter/material.dart';

import '../../config/constants.dart';
import '../../models/product_model.dart';
import '../../utils/currency_formatter.dart';
import '../../utils/image_helper.dart';

class ProductCardWeb extends StatelessWidget {
  final ProductModel product;

  const ProductCardWeb({super.key, required this.product});

  String get _soldLabel {
    if (product.soldLabel != null) {
      return product.soldLabel!;
    }
    if (product.sold >= 1000) {
      return '${(product.sold / 1000).floor()}rb+';
    }
    return '${product.sold}+';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: AspectRatio(
                aspectRatio: 1,
                child: ImageHelper.resolveProductImage(
                  product.resolvedImagePath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            if (product.discount > 0)
              Positioned(
                left: -5,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFB495C),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    '${product.discount}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 9),
        Text(
          product.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF322F2B),
            height: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        if (product.usePriceBadge)
          Container(
            height: 22,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF5E5),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(color: const Color(0xFFFFB0B4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _WebDiscountTicketIcon(),
                const SizedBox(width: 3),
                Text(
                  CurrencyFormatter.format(product.price),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFB495C),
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            CurrencyFormatter.format(product.price),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF23211E),
              height: 1.2,
            ),
          ),
        if (product.promoText.isNotEmpty) ...[
          const SizedBox(height: 5),
          Text(
            product.promoText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Color(0xFFFF8614),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
          ),
        ],
        const SizedBox(height: 5),
        Row(
          children: [
            const Icon(Icons.star, size: 15, color: Color(0xFFFFCF01)),
            const SizedBox(width: 3),
            Expanded(
              child: Text(
                '${product.rating.toStringAsFixed(1)} \u00B7 $_soldLabel terjual',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF828085),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            _ProductMetaIcon(product: product),
            if (product.metaIcon != ProductMetaIcon.none)
              const SizedBox(width: 4),
            Expanded(
              child: Text(
                product.location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF828085),
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
        const Align(
          alignment: Alignment.centerRight,
          child: Text(
            '...',
            style: TextStyle(
              color: Color(0xFF98A2B3),
              fontSize: 14,
              height: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class _WebDiscountTicketIcon extends StatelessWidget {
  const _WebDiscountTicketIcon();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      key: Key('web-discount-ticket-icon'),
      width: 15,
      height: 14,
      child: CustomPaint(painter: _WebDiscountTicketPainter()),
    );
  }
}

class _WebDiscountTicketPainter extends CustomPainter {
  const _WebDiscountTicketPainter();

  @override
  void paint(Canvas canvas, Size size) {
    const ticketColor = Color(0xFFD6003F);
    const badgeColor = Color(0xFFFFF5E5);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        const Radius.circular(1.5),
      ),
      Paint()..color = ticketColor,
    );

    final notchPaint = Paint()..color = badgeColor;
    canvas.drawCircle(Offset(0, size.height / 2), 2.1, notchPaint);
    canvas.drawCircle(
      Offset(size.width, size.height / 2),
      2.1,
      notchPaint,
    );

    final percentPainter = TextPainter(
      text: const TextSpan(
        text: '%',
        style: TextStyle(
          color: Colors.white,
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
  bool shouldRepaint(covariant _WebDiscountTicketPainter oldDelegate) => false;
}

class _ProductMetaIcon extends StatelessWidget {
  final ProductModel product;

  const _ProductMetaIcon({required this.product});

  @override
  Widget build(BuildContext context) {
    switch (product.metaIcon) {
      case ProductMetaIcon.none:
        return const SizedBox.shrink();
      case ProductMetaIcon.officialStore:
        return Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: const Color(0xFF9F00DD),
            borderRadius: BorderRadius.circular(2),
          ),
          child: const Icon(Icons.check, size: 11, color: Colors.white),
        );
      case ProductMetaIcon.powerMerchant:
        return SizedBox(
          key: Key('web-power-merchant-icon-${product.id}'),
          width: 15,
          height: 15,
          child: const CustomPaint(painter: _PowerMerchantIconPainter()),
        );
      case ProductMetaIcon.legacy:
        return Icon(
          product.isOfficial ? Icons.verified : Icons.shield,
          size: 15,
          color: product.isOfficial
              ? const Color(0xFF7B3FE4)
              : AppColors.green,
        );
    }
  }
}

class _PowerMerchantIconPainter extends CustomPainter {
  const _PowerMerchantIconPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final hexagon = Path()
      ..moveTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.91, size.height * 0.24)
      ..quadraticBezierTo(
        size.width,
        size.height * 0.29,
        size.width,
        size.height * 0.39,
      )
      ..lineTo(size.width, size.height * 0.7)
      ..quadraticBezierTo(
        size.width,
        size.height * 0.78,
        size.width * 0.91,
        size.height * 0.84,
      )
      ..lineTo(size.width * 0.58, size.height * 0.98)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height,
        size.width * 0.42,
        size.height * 0.98,
      )
      ..lineTo(size.width * 0.09, size.height * 0.79)
      ..quadraticBezierTo(
        0,
        size.height * 0.74,
        0,
        size.height * 0.64,
      )
      ..lineTo(0, size.height * 0.36)
      ..quadraticBezierTo(
        0,
        size.height * 0.27,
        size.width * 0.09,
        size.height * 0.21,
      )
      ..lineTo(size.width * 0.42, size.height * 0.02)
      ..quadraticBezierTo(
        size.width * 0.5,
        0,
        size.width * 0.5,
        0,
      )
      ..close();

    canvas.drawPath(hexagon, Paint()..color = const Color(0xFF028A45));

    final crown = Path()
      ..moveTo(size.width * 0.22, size.height * 0.43)
      ..lineTo(size.width * 0.4, size.height * 0.53)
      ..lineTo(size.width * 0.51, size.height * 0.29)
      ..quadraticBezierTo(
        size.width * 0.54,
        size.height * 0.23,
        size.width * 0.58,
        size.height * 0.29,
      )
      ..lineTo(size.width * 0.68, size.height * 0.53)
      ..lineTo(size.width * 0.82, size.height * 0.43)
      ..quadraticBezierTo(
        size.width * 0.88,
        size.height * 0.39,
        size.width * 0.86,
        size.height * 0.47,
      )
      ..lineTo(size.width * 0.8, size.height * 0.76)
      ..quadraticBezierTo(
        size.width * 0.79,
        size.height * 0.8,
        size.width * 0.74,
        size.height * 0.8,
      )
      ..lineTo(size.width * 0.33, size.height * 0.8)
      ..quadraticBezierTo(
        size.width * 0.28,
        size.height * 0.8,
        size.width * 0.27,
        size.height * 0.75,
      )
      ..lineTo(size.width * 0.19, size.height * 0.47)
      ..quadraticBezierTo(
        size.width * 0.17,
        size.height * 0.39,
        size.width * 0.22,
        size.height * 0.43,
      )
      ..close();

    canvas.drawPath(crown, Paint()..color = const Color(0xFFFECF01));
  }

  @override
  bool shouldRepaint(covariant _PowerMerchantIconPainter oldDelegate) => false;
}
