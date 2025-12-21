import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/article/models/blog_entry.dart';

class EditBlogPage extends StatefulWidget {
  final BlogEntry blog;

  const EditBlogPage({super.key, required this.blog});

  @override
  State<EditBlogPage> createState() => _EditBlogPageState();
}

class _EditBlogPageState extends State<EditBlogPage> {
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _content;
  late String _category;

  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    // 1. ISI DATA AWAL
    _title = widget.blog.fields.title;
    _content = widget.blog.fields.content;
    
    // Perhatikan: Data dari Django JSON biasanya sudah sesuai dengan 'value' di models.py
    _category = widget.blog.fields.category; 

    _titleController = TextEditingController(text: _title);
    _contentController = TextEditingController(text: _content);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Blog'),
        backgroundColor: const Color(0xFFB71C1C),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- JUDUL ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: "Judul",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return "Judul tidak boleh kosong!";
                    return null;
                  },
                ),
              ),

              // --- KATEGORI (DROPDOWN) ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  // Pastikan value ini ada di dalam list items di bawah
                  value: _category, 
                  decoration: InputDecoration(
                    labelText: "Kategori",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  // SESUAIKAN DENGAN MODELS.PY KAMU!
                  // value: yang dikirim ke database (huruf kecil)
                  // child: yang dilihat user (huruf besar)
                  items: const [
                    DropdownMenuItem(
                      value: 'sports', // Sesuai models.py
                      child: Text('Sports'),
                    ),
                    DropdownMenuItem(
                      value: 'e-sports', // Sesuai models.py
                      child: Text('E-Sports'),
                    ),
                    DropdownMenuItem(
                      value: 'community posts', // Sesuai models.py
                      child: Text('Community Posts'),
                    ),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return "Kategori tidak boleh kosong!";
                    return null;
                  },
                ),
              ),

              // --- KONTEN ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "Konten",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
                  ),
                  maxLines: 5,
                  onChanged: (String? value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) return "Konten tidak boleh kosong!";
                    return null;
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- TOMBOL SIMPAN ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFB71C1C),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        // Kirim ke Django
                        final response = await request.postJson(
                          // Ganti URL sesuai endpoint kamu
                          "http://127.0.0.1:8000/blog/edit-flutter/${widget.blog.pk}/",
                          jsonEncode(<String, String>{
                            'title': _title,
                            'content': _content,
                            'category': _category, // Ini akan mengirim 'sports', 'e-sports', dll
                          }),
                        );

                        if (context.mounted) {
                          if (response['status'] == 'success') {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Berhasil disimpan!")),
                            );
                            Navigator.pop(context); // Kembali ke Detail
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Gagal: ${response['message']}")),
                            );
                          }
                        }
                      }
                    },
                    child: const Text("Simpan Perubahan"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}