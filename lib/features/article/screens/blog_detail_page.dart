import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart'; 
import 'package:venyuk_mobile/features/article/models/blog_entry.dart';
import 'package:venyuk_mobile/features/article/models/comment.dart';
import 'package:venyuk_mobile/features/article/screens/edit_blog_page.dart'; 

class BlogDetailPage extends StatefulWidget {
  final BlogEntry blog;
  const BlogDetailPage({super.key, required this.blog});
  @override
  State<BlogDetailPage> createState() => _BlogDetailPageState();
}

class _BlogDetailPageState extends State<BlogDetailPage> {
  // 1. Controller untuk Input Teks
  final TextEditingController _commentController = TextEditingController();
  int? currentUserId;

  @override
  void initState() {
    super.initState();
    // --- [BARU] 2. Panggil fungsi cek user saat halaman dibuka ---
    _getCurrentUser();
  }

  Future<void> _getCurrentUser() async {
    final request = context.read<CookieRequest>();
    try {
      // Ganti URL sesuai IP kamu (127.0.0.1 atau 10.0.2.2)
      final response = await request.get('https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/blog/get-user-id/');
      setState(() {
        currentUserId = response['user_id'];
      });
    } catch (e) {
      setState(() {
        currentUserId = null;
      });
    }
  }

  Future<List<Comment>> fetchComments() async {
    var url = Uri.parse('https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/blog/comments/${widget.blog.pk}/');
    var response = await http.get(
      url,
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      List<Comment> comments = [];
      for (var d in data) {
        comments.add(Comment.fromJson(d));
      }
      return comments;
    } else {
      return [];
    }
  }

  // 3. Fungsi Kirim Komentar (Harus sejajar dengan fetchComments)
  Future<void> sendComment(CookieRequest request) async {
    if (_commentController.text.isEmpty) return;

    final response = await request.postJson(
      "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/blog/add-comment-flutter/${widget.blog.pk}/",
      jsonEncode({"content": _commentController.text}),
    );

    if (response['status'] == 'success') {
      _commentController.clear(); // Hapus teks
      setState(() {}); // Refresh tampilan biar komen baru muncul
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Komentar terkirim!")),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${response['message']}")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Blog Detail'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
        actions: [
          // 1. Tombol Edit (Cek Sendiri)
          if (currentUserId != null && currentUserId == widget.blog.fields.user)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditBlogPage(blog: widget.blog),
                  ),
                );
                if (context.mounted) Navigator.pop(context, true);
              },
            ),

          // 2. Tombol Delete (Cek Sendiri)
          if (currentUserId != null && currentUserId == widget.blog.fields.user)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                bool confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Hapus Blog?'),
                        content: const Text('Yakin mau hapus?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Batal'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm) {
                  final response = await request.postJson(
                    "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/blog/delete-flutter/${widget.blog.pk}/",
                    jsonEncode({}),
                  );
                  if (context.mounted) {
                    if (response['status'] == 'success') {
                      Navigator.pop(context, true);
                    }
                  }
                }
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- GAMBAR ---
                  if (widget.blog.fields.thumbnail != null && widget.blog.fields.thumbnail!.isNotEmpty)
                    Image.network(
                      'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/blog/proxy-image/?url=${Uri.encodeComponent(widget.blog.fields.thumbnail!)}',
                      height: 250, width: double.infinity, fit: BoxFit.cover,
                      errorBuilder: (ctx, _, __) => Container(height: 200, color: Colors.grey),
                    )
                  else
                    Container(height: 200, color: Colors.grey, child: const Icon(Icons.image, size: 50)),
                  
                  const SizedBox(height: 16),

                  // --- JUDUL & KONTEN ---
                  Text(widget.blog.fields.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                  Text(widget.blog.fields.category, style: TextStyle(color: Colors.grey[600])),
                  const Divider(),
                  Text(widget.blog.fields.content, textAlign: TextAlign.justify),
                  
                  const Divider(),
                  const Text("Komentar", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  
                  // --- LIST KOMENTAR ---
                  FutureBuilder<List<Comment>>(
                    future: fetchComments(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Text("Belum ada komentar.", style: TextStyle(color: Colors.grey));
                      } else {
                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            var comment = snapshot.data![index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              child: ListTile(
                                title: Text(comment.user, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text(comment.content),
                                trailing: Text(comment.createdAt.substring(0, 10), style: const TextStyle(fontSize: 10)),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 10), // Jarak biar gak ketutup input
                ],
              ),
            ),
          ),
          
          // BAGIAN BAWAH (Input Field Sticky)
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(blurRadius: 2, color: Colors.grey.withOpacity(0.3))],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      hintText: "Tulis komentar...",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  color: const Color(0xFFB71C1C),
                  onPressed: () => sendComment(request), // Panggil fungsi kirim
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
