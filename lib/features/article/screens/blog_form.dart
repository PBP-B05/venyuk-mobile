import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class BlogFormPage extends StatefulWidget {
  const BlogFormPage({super.key});

  @override
  State<BlogFormPage> createState() => _BlogFormPageState();
}

class _BlogFormPageState extends State<BlogFormPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Variabel untuk menyimpan input user
  String _title = "";
  String _content = "";
  String _thumbnail = "";
  String _category = "community posts"; // Default value

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Blog Post'),
        backgroundColor: const Color(0xFFB71C1C), // Sesuaikan warna tema kamu
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- INPUT JUDUL ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Judul Blog",
                    labelText: "Title",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _title = value!;
                    });
                  },
                ),
              ),

              // --- INPUT KONTEN ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Isi Blog...",
                    labelText: "Content",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  maxLines: 5, // Biar kotaknya agak besar
                  onChanged: (String? value) {
                    setState(() {
                      _content = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Konten tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // --- INPUT URL GAMBAR (Thumbnail) ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: InputDecoration(
                    hintText: "Masukkan URL Gambar (Contoh: Wikipedia Link)",
                    labelText: "Thumbnail URL",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (String? value) {
                    setState(() {
                      _thumbnail = value!;
                    });
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Thumbnail tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),

              // --- INPUT KATEGORI (Dropdown) ---
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: InputDecoration(
                    labelText: "Category",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: "community posts", child: Text("Community Posts")),
                    DropdownMenuItem(value: "e-sports", child: Text("E-Sports")),
                    DropdownMenuItem(value: "sports", child: Text("Sports")),
                  ],
                  onChanged: (String? value) {
                    setState(() {
                      _category = value!;
                    });
                  },
                ),
              ),

              const SizedBox(height: 20),

              // --- TOMBOL SAVE ---
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(const Color(0xFFB71C1C)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      // Kirim ke Django dan tunggu respons
                      // URL lengkap: http://127.0.0.1:8000/blog/add-blog-ajax/
                      final response = await request.postJson( // <--- Pakai postJson
                        "http://127.0.0.1:8000/blog/create-flutter/",
                        jsonEncode(<String, String>{ // <--- Harus di-encode jadi String JSON
                            'title': _title,
                            'content': _content,
                            'category': _category,
                            'thumbnail': _thumbnail,
                        }),
                    );
                      if (context.mounted) {
                        if (response['status'] == 'success') {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Blog berhasil disimpan!"),
                          ));
                          Navigator.pop(context); // Kembali ke halaman sebelumnya
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Gagal menyimpan, silakan coba lagi."),
                          ));
                        }
                      }
                    }
                  },
                  child: const Text(
                    "Save",
                    style: TextStyle(color: Colors.white),
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