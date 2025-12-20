import 'package:flutter/material.dart';
// Pastikan nama project sesuai pubspec.yaml (venyuk_mobile atau venyuk)
import 'package:venyuk_mobile/features/article/models/blog_entry.dart'; 

class BlogCard extends StatelessWidget {
  final BlogEntry blog;

  const BlogCard({super.key, required this.blog});

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
          // 1. Gambar Blog
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
          
          // 2. Konten Teks
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      blog.fields.category.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFFB71C1C), // Merah Maroon
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
                
                // Tombol Baca
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigasi ke detail
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Kamu memilih: ${blog.fields.title}"))
                      );
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