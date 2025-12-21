import 'package:flutter/material.dart';
import 'package:venyuk_mobile/features/article/models/blog_entry.dart'; 
import 'package:venyuk_mobile/features/article/screens/blog_detail_page.dart';

class BlogCard extends StatelessWidget {
  final BlogEntry blog;
  // 1. TAMBAHKAN VARIABLE INI
  final Function() onRefresh; 

  // 2. WAJIBKAN DI CONSTRUCTOR
  const BlogCard({
    super.key, 
    required this.blog, 
    required this.onRefresh 
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ... (Bagian Gambar - Tidak ada perubahan) ...
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: blog.fields.thumbnail != null && blog.fields.thumbnail!.isNotEmpty
                ? Image.network(
                  'http://127.0.0.1:8000/blog/proxy-image/?url=${Uri.encodeComponent(blog.fields.thumbnail!)}',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (ctx, error, stackTrace) => Container(
                      height: 180, 
                      color: Colors.grey[300], 
                      child: const Center(child: Icon(Icons.broken_image, color: Colors.grey))
                    ),
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey[300],
                    child: const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                  ),
          ),
          
          // ... (Bagian Konten Teks) ...
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ... (Judul & Kategori - Tidak ada perubahan) ...
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blog.fields.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFB71C1C),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      blog.fields.dateAdded,
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  blog.fields.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                
                // 3. UBAH LOGIKA TOMBOL BACA
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    // Ubah jadi async
                    onPressed: () async { 
                      // Simpan hasil kembalian (pop) ke variable result
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetailPage(blog: blog),
                        ),
                      );

                      // Cek jika resultnya true (artinya user habis Edit/Delete)
                      if (result == true) {
                        // Panggil fungsi refresh milik halaman induk
                        onRefresh(); 
                      }
                    }, 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Read More'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}