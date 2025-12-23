import 'package:flutter/material.dart';
import 'package:venyuk_mobile/features/ven_shop/models/product.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/checkout_page.dart'; 
import 'package:venyuk_mobile/features/venyuk/widgets/left_drawer.dart';
import 'package:venyuk_mobile/global/widget/venyuk_app_bar.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const VenyukAppBar(
        title: 'Detail Produk',
        showDrawerButton: false,
        showUserMenu: false,
        showBackButton: true,
        ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Container(
              width: double.infinity,
              height: 300,
              color: Colors.grey[200],
              child: product.thumbnail != null
                  ? Image.network(
                      product.thumbnail!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image, size: 50),
                    )
                  : const Icon(Icons.image, size: 50),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // price & rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Rp${product.price}",
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD84040), 
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber),
                          Text(
                            "${product.rating} (${product.reviewer} reviews)",
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // name & brand
                  Text(
                    product.title,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    product.brand,
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),

                  // deskripsi
                  const Text(
                    "Deskripsi",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.content,
                    style: const TextStyle(fontSize: 14, height: 1.5),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // stok
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.inventory_2_outlined, color: Colors.grey),
                        const SizedBox(width: 8),
                        Text("Stok Tersedia: ${product.stock}"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // tomobl checkout
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFD84040),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: product.stock > 0 
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutPage(product: product),
                    ),
                  );
                }
              : null, 
          child: Text(
            product.stock > 0 ? "Beli Sekarang" : "Stok Habis",
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}