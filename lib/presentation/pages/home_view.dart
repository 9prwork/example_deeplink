import 'package:flutter/material.dart';

import 'product_detail_view.dart';
import 'profile_view.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  static const _sampleLinks = [
    'exampledeeplink://product/42',
    'exampledeeplink://profile/9prwork',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deep Link Demo')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text(
            'ลองยิงลิงก์เหล่านี้จากนอกแอป (เช่นผ่าน adb หรือ Safari) '
            'แอปจะเปิดหน้าที่ตรงกันโดยอัตโนมัติ:',
          ),
          const SizedBox(height: 12),
          for (final link in _sampleLinks)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: SelectableText(
                link,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          const SizedBox(height: 24),
          const Text('หรือกดทดสอบการนำทางตรงจากในแอปได้ที่นี่:'),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProductDetailView(id: '42'),
              ),
            ),
            child: const Text('Open product/42'),
          ),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ProfileView(id: '9prwork'),
              ),
            ),
            child: const Text('Open profile/9prwork'),
          ),
        ],
      ),
    );
  }
}
