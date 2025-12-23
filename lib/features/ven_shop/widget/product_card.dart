import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:venyuk_mobile/features/ven_shop/models/product.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/product_form_page.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  final VoidCallback? onRefresh;

  const ProductCard({
    super.key, 
    required this.product, 
    required this.onTap, 
    this.onRefresh
  });

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    
    bool isAdmin = false;
    if (request.jsonData.containsKey('is_admin')) {
        isAdmin = request.jsonData['is_admin'] == true;
    }else if (request.jsonData.containsKey('is_superuser')) {
        isAdmin = request.jsonData['is_superuser'] == true;
    }

    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2), 
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              flex: 3, 
              child: Stack(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: double.infinity,
                    child: Image.network(
                      product.thumbnail ?? "",
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[100],
                          child: const Center(
                            child: Icon(Icons.image_not_supported, color: Colors.grey, size: 40),
                          ),
                        );
                      },
                    ),
                  ),
                  // Badge Kategori
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Colors.white.withOpacity(0.9),
                      child: Text(
                        product.category,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nama Produk
                        Text(
                          product.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        
                        // Harga
                        Text(
                          "Rp${product.price}",
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        
                        // Brand
                        Text(
                          product.brand,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Rating & Stock
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 14),
                                const SizedBox(width: 4),
                                Text(
                                  "${product.rating} | ${product.reviewer}",
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "Stock: ${product.stock}",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),

                        if (isAdmin) 
                          Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(context, MaterialPageRoute(
                                      builder: (context) => ProductFormPage(product: product)
                                  )).then((_) { if (onRefresh != null) onRefresh!(); });
                                },
                                child: const Icon(Icons.edit_square, color: Colors.blue, size: 20),
                              ),
                              const SizedBox(width: 12),
                              InkWell(
                                onTap: () async {
                                  final confirm = await showDialog(context: context, builder: (ctx) => AlertDialog(
                                    title: const Text("Hapus Produk?"),
                                    actions: [
                                      TextButton(onPressed: ()=>Navigator.pop(ctx, false), child: const Text("Batal")),
                                      TextButton(onPressed: ()=>Navigator.pop(ctx, true), child: const Text("Hapus")),
                                    ],
                                  ));
                                  if (confirm == true) {
                                    final response = await request.post("http://127.0.0.1:8000/ven_shop/delete-flutter/${product.id}/", {});
                                    if (response['status'] == 'success' && onRefresh != null) onRefresh!();
                                  }
                                },
                                child: const Icon(Icons.delete, color: Colors.red, size: 20),
                              ),
                            ],
                          )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}