import 'package:flutter/material.dart';

class FeedMobile extends StatelessWidget {
  const FeedMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return const _SimpleMobilePage(
      title: 'Feed',
      icon: Icons.feed,
      message: 'Inspirasi belanja dan update toko favorit.',
    );
  }
}

class _SimpleMobilePage extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const _SimpleMobilePage({
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 54),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}
