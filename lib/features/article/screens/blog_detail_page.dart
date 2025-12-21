import 'package:flutter/material.dart';
import 'package:venyuk_mobile/features/article/models/blog_entry.dart';

class BlogDetailPage extends StatelessWidget {
  final BlogEntry blog;

  // Constructor: Wajib menerima parameter 'blog'
  const BlogDetailPage({super.key, required this.blog});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Detail'),
        backgroundColor: const Color(0xFFB71C1C), // Merah Maroon
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (blog.fields.thumbnail != null && blog.fields.thumbnail!.isNotEmpty)
              SizedBox(
                width: double.infinity,
                height: 250, // Tinggi gambar detail lebih besar biar puas
                child: Image.network(
                  // Gunakan Proxy URL agar aman dari error CORS/Localhost
                  'http://127.0.0.1:8000/blog/proxy-image/?url=${Uri.encodeComponent(blog.fields.thumbnail!)}',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 50, color: Colors.grey),
                      ),
                    );
                  },
                ),
              )
            else
              // Placeholder kalau tidak ada gambar
              Container(
                width: double.infinity,
                height: 200,
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Judul
                  Text(
                    blog.fields.title,
                    style: const TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  
                  // Info Tambahan (Kategori, dll)
                  Row(
                    children: [
                      Icon(Icons.category, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        blog.fields.category, 
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 16),
                    ],
                  ),
                  
                  const Divider(height: 30, thickness: 1),

                  // Konten Utama
                  Text(
                    blog.fields.content,
                    textAlign: TextAlign.justify,
                    style: const TextStyle(
                      fontSize: 16.0,
                      height: 1.5, // Jarak antar baris biar enak dibaca
                    ),
                  ),

                  const SizedBox(height: 20),
                  
                  // Tombol Kembali
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Back to List'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}