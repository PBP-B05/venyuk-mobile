import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
// Sesuaikan import ini dengan nama project kamu
import 'package:venyuk_mobile/features/article/models/blog_entry.dart';
import 'package:venyuk_mobile/features/article/screens/blog_form.dart';
import 'package:venyuk_mobile/features/article/widgets/blog_card.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  // Variabel untuk menyimpan kategori yang sedang dipilih
  String selectedCategory = "All";

  Future<List<BlogEntry>> fetchBlogs(CookieRequest request) async {
    // URL disesuaikan: 127.0.0.1 untuk Web, 10.0.2.2 untuk Emulator
    final response = await request.get('http://127.0.0.1:8000/blog/json/');

    List<BlogEntry> listBlog = [];
    for (var d in response) {
      if (d != null) {
        listBlog.add(BlogEntry.fromJson(d));
      }
    }
    return listBlog;
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Blog List'),
        backgroundColor: const Color(0xFFB71C1C), // Merah Maroon
        foregroundColor: Colors.white,
      ),
      // Kita ganti body jadi Column supaya bisa menaruh Filter di atas List
      body: Column(
        children: [
          // ==============================================
          // 1. BAGIAN FILTER KATEGORI
          // ==============================================
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterButton("All"),
                  _buildFilterButton("Sports"),
                  _buildFilterButton("E-Sports"),
                  _buildFilterButton("Community Posts"),
                ],
              ),
            ),
          ),
          
          // ==============================================
          // 2. BAGIAN LIST BLOG (EXPANDED)
          // ==============================================
          Expanded(
            child: FutureBuilder(
              future: fetchBlogs(request),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                   // Kalau error koneksi, kita return list kosong dulu biar ga crash
                   return const Center(child: Text("Gagal mengambil data / Server mati."));
                } else {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('Belum ada blog.'));
                  } else {
                    
                    // --- LOGIKA FILTERING (CLIENT SIDE) ---
                    List<BlogEntry> allData = snapshot.data!;
                    List<BlogEntry> filteredData = [];

                    if (selectedCategory == "All") {
                      filteredData = allData;
                    } else {
                      // Filter data berdasarkan category dari Django
                      // Kita pakai toLowerCase() biar aman (sports == Sports)
                      filteredData = allData.where((item) => 
                        item.fields.category.toLowerCase() == selectedCategory.toLowerCase()
                      ).toList();
                    }
                    // --------------------------------------

                    if (filteredData.isEmpty) {
                       return const Center(child: Text('Tidak ada artikel di kategori ini.'));
                    }

                    return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (_, index) => BlogCard(blog: filteredData[index]),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BlogFormPage()), 
          );
        },
        backgroundColor: const Color(0xFFB71C1C),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Widget Helper untuk membuat Tombol Filter
  Widget _buildFilterButton(String categoryName) {
    bool isSelected = selectedCategory == categoryName;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(categoryName),
        selected: isSelected,
        // Warna kalau dipilih: Merah Maroon, Teks Putih
        selectedColor: const Color(0xFFB71C1C), 
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        // Warna kalau tidak dipilih: Abu-abu
        backgroundColor: Colors.grey[200],
        onSelected: (bool selected) {
          setState(() {
            selectedCategory = categoryName;
          });
        },
      ),
    );
  }
}