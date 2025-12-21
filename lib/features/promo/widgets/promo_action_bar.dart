import 'package:flutter/material.dart';

class PromoActionBar extends StatelessWidget {
  final VoidCallback onCreatePromo;

  const PromoActionBar({
    Key? key,
    required this.onCreatePromo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Promo Aktif',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A2E),
            ),
          ),
          ElevatedButton.icon(
            onPressed: onCreatePromo,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Buat Promo Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8B3A3A),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}