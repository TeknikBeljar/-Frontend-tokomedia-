import 'package:flutter/material.dart';

import '../../config/constants.dart';

class AkunMobile extends StatelessWidget {
  const AkunMobile({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Akun')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: CircleAvatar(
                backgroundImage: AssetImage(AppAssets.profile),
              ),
              title: Text('Pengguna Tokomedia'),
              subtitle: Text('user@example.com'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                const ListTile(
                  leading: Icon(Icons.favorite_border),
                  title: Text('Wishlist'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.location_on_outlined),
                  title: Text('Alamat'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.upload_file),
                  title: const Text('Upload Product'),
                  onTap: () => Navigator.pushNamed(context, '/upload-product'),
                ),
                const Divider(height: 1),
                const ListTile(
                  leading: Icon(Icons.settings_outlined),
                  title: Text('Pengaturan'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
