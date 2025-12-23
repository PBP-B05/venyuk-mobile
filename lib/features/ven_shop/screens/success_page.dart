import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/ven_shop/models/product.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/shop_page.dart';
import 'package:venyuk_mobile/global/screens/main_nav.dart'; 

class SuccessPage extends StatefulWidget {
  final Product product;

  const SuccessPage({super.key, required this.product});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  int _rating = 0;
  bool _isSubmitting = false;
  bool _hasRated = false;

  Future<void> _submitRating(CookieRequest request) async {
    if (_rating == 0) return;
    setState(() { _isSubmitting = true; });

    try {
      final response = await request.postJson(
        "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/ven_shop/rating-flutter/${widget.product.id}/",
        jsonEncode({"rating": _rating}),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          setState(() { _hasRated = true; });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Terima kasih atas penilaian Anda!")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['message'] ?? "Gagal menyimpan rating")),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Terjadi kesalahan koneksi")),
        );
      }
    } finally {
      if (mounted) setState(() { _isSubmitting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 100),
              const SizedBox(height: 24),
              
              const Text(
                "Pembelian Berhasil!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              
              Text(
                "Anda telah membeli ${widget.product.title}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              
              const SizedBox(height: 40),

              if (!_hasRated) ...[
                const Text("Beri penilaian produk ini:", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      onPressed: () {
                        setState(() { _rating = index + 1; });
                      },
                      icon: Icon(
                        index < _rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 40,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                if (_rating > 0)
                  ElevatedButton(
                    onPressed: _isSubmitting ? null : () => _submitRating(request),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSubmitting 
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text("Kirim Rating"),
                  ),
              ] else ...[
                 Container(
                   padding: const EdgeInsets.all(12),
                   decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                   child: const Row(
                     mainAxisAlignment: MainAxisAlignment.center,
                     mainAxisSize: MainAxisSize.min,
                     children: [
                       Icon(Icons.star, color: Colors.amber),
                       SizedBox(width: 8),
                       Text("Rating terkirim!"),
                     ],
                   ),
                 )
              ],

              const SizedBox(height: 50),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const ShopPage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD84040),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text("Kembali Belanja", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}