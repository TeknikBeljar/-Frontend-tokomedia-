import 'package:flutter/material.dart';

class MallMobile extends StatelessWidget {
  const MallMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mall')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.storefront, size: 54),
            SizedBox(height: 12),
            Text('Toko resmi dan brand pilihan.'),
          ],
        ),
      ),
    );
  }
}
