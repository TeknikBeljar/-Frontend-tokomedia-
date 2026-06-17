import 'package:flutter/material.dart';

class ShimmerLoading extends StatelessWidget {
  final double height;
  final double width;

  const ShimmerLoading({
    super.key,
    required this.height,
    this.width = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFE9EDF2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SizedBox(height: height, width: width),
    );
  }
}
