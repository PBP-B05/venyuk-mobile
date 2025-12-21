import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/article/models/blog_entry.dart';
import 'package:venyuk_mobile/features/article/screens/blog_form_page.dart';
import 'package:venyuk_mobile/features/article/widgets/blog_card.dart';
import 'package:venyuk_mobile/features/venyuk/widgets/left_drawer.dart';

class BlogListPage extends StatefulWidget {
  const BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}



class _BlogListPageState extends State<BlogListPage> {
  // Variabel untuk menyimpan kategori yang sedang dipilih
  String selectedCategory = "All";
  bool isSuperuser = false;

  @override
  void initState() {
    super.initState();
    // --- [BARU] Cek status admin saat halaman dibuka ---
    _checkAdminStatus();
  }

  Future<void> _checkAdminStatus() async {
    final request = context.read<CookieRequest>();
    try {
      // Panggil endpoint yang sama dengan yang kita pakai di DetailPage
      final response = await request.get('http://127.0.0.1:8000/blog/get-user-id/');
      setState(() {
        // Ambil data is_superuser (pastikan di views.py Django sudah return ini)
        isSuperuser = response['is_superuser'] ?? false; 
      });
    } catch (e) {
      print("Gagal cek status admin: $e");
    }
  }

  Future<List<BlogEntry>> fetchBlogs(CookieRequest request) async {
    String url = 'http://127.0.0.1:8000/blog/json/';
    if (selectedCategory == "My Blog") {
      url = 'http://127.0.0.1:8000/blog/my-blog-json/';
    }

    final response = await request.get(url);

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
      drawer: const LeftDrawer(),
      appBar: AppBar(
        title: const Text('Blog List'),
        backgroundColor: const Color(0xFFB71C1C), // Merah Maroon
        foregroundColor: Colors.white,
      ),
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
                  _buildFilterButton("My Blog"),
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
                   return const Center(child: Text("Gagal mengambil data / Server mati."));
                } else {
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    // Pesan khusus kalau My Blog kosong
                    if (selectedCategory == "My Blog") {
                       return const Center(child: Text('Kamu belum memposting apapun.'));
                    }
                    return const Center(child: Text('Belum ada blog.'));
                  } else {
                    List<BlogEntry> allData = snapshot.data!;
                    List<BlogEntry> filteredData = [];


                    if (selectedCategory == "All" || selectedCategory == "My Blog") {
                      filteredData = allData;
                    } 
                    // Kalau kategori lain (Sports, dll), baru kita saring manual
                    else {
                      filteredData = allData.where((item) => 
                        item.fields.category.toLowerCase() == selectedCategory.toLowerCase()
                      ).toList();
                    }
                    // --------------------------------------

                    if (filteredData.isEmpty) {
                       return const Center(child: Text('Tidak ada blog di kategori ini.'));
                    }

                    return ListView.builder(
                      itemCount: filteredData.length,
                      itemBuilder: (_, index) {
                        return BlogCard(
                          blog: filteredData[index],
                          onRefresh: () {
                            setState(() {
                                // Refresh halaman
                            });
                          },
                        );
                      },
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async { 
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => BlogFormPage(isSuperuser: isSuperuser)),
          );
          if (result == true) {
            setState(() {
            });
          }
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
        selectedColor: const Color(0xFFB71C1C), 
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
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