import 'package:flutter/material.dart';

class TransaksiMobile extends StatelessWidget {
  const TransaksiMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transaksi')),
      body: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.receipt_long, size: 54),
            SizedBox(height: 12),
            Text('Riwayat pesanan akan tampil di sini.'),
          ],
        ),
      ),
    );
  }
}
