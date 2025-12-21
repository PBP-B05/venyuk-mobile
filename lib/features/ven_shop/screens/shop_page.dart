import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/ven_shop/models/product.dart';
import 'package:venyuk_mobile/features/ven_shop/widget/product_card.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/product_detail_page.dart';
import 'package:venyuk_mobile/global/widget/venyuk_header.dart';
import 'package:venyuk_mobile/features/venyuk/widgets/left_drawer.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/history_page.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/product_form_page.dart';
import 'package:venyuk_mobile/global/screens/login.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  final Map<String, String> categoryMap = {
    "Badminton": "🏸",
    "Basketball": "🏀",
    "Tennis": "🎾",
    "Football": "⚽",
    "Swimming": "🏊",
    "Running": "🏃",
    "Volleyball": "🏐",
  };

  List<String> selectedCategories = [];

  Future<List<Product>> fetchProduct(CookieRequest request) async {
    String url = 'http://127.0.0.1:8000/ven_shop/json/';
    
    if (selectedCategories.isNotEmpty) {
      String queryParams = selectedCategories
          .map((cat) => 'category=${cat.toLowerCase()}')
          .join('&');
      url += '?$queryParams';
    }

    final response = await request.get(url);
    List<Product> listProduct = [];
    for (var d in response) {
      if (d != null) listProduct.add(Product.fromJson(d));
    }
    return listProduct;
  }

  void _toggleCategory(String category) {
    setState(() {
      if (selectedCategories.contains(category)) {
        selectedCategories.remove(category);
      } else {
        selectedCategories.add(category);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const LeftDrawer(),
      // Drawer Filter
      endDrawer: Drawer(
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD84040), Color(0xFF8E1616)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
              child: const Text(
                "Kategori Olahraga",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: categoryMap.entries.map((entry) {
                  final categoryName = entry.key;
                  final emoji = entry.value;
                  final isChecked = selectedCategories.contains(categoryName);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isChecked ? const Color(0xFFFEF2F2) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: InkWell(
                      onTap: () => _toggleCategory(categoryName),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                        child: Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              activeColor: const Color(0xFFD84040),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (bool? value) {
                                _toggleCategory(categoryName);
                              },
                            ),
                            Text(emoji, style: const TextStyle(fontSize: 20)),
                            const SizedBox(width: 12),
                            Text(
                              categoryName,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Color(0xFF374151)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (selectedCategories.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        selectedCategories.clear();
                      });
                    },
                    icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                    label: const Text("Hapus Semua Filter", style: TextStyle(color: Colors.grey)),
                  ),
                ),
              ),
          ],
        ),
      ),

      body: SafeArea(
        child: Column(
          children: [
            // Header
            // Header with left drawer button
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFD84040), Color(0xFF8E1616)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Drawer button (use Builder to get a context with Scaffold ancestor)
                  Builder(
                    builder: (innerContext) => IconButton(
                      icon: const Icon(Icons.menu, color: Colors.white),
                      onPressed: () {
                        Scaffold.of(innerContext).openDrawer();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Ven-Shop",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // user popup (copied from VenyukHeader)
                  PopupMenuButton<String>(
                    offset: const Offset(0, 50),
                    tooltip: 'Menu Pengguna',
                    color: Colors.white,
                    surfaceTintColor: Colors.white,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.person, color: Color(0xFFD84040)),
                    ),
                    onSelected: (String value) async {
                      final request = context.read<CookieRequest>();
                      if (value == 'profile') {
                        if (request.loggedIn){
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fitur Profil sedang dalam pengembangan."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        }
                      } else if (value == 'history') {
                        if (request.loggedIn) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const HistoryPage()),
                          );
                        } else {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                          );
                        }
                      } else if (value == 'add_product') {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ProductFormPage()),
                        );
                      } else if (value == 'logout') {
                        final response = await request.logout(
                          "http://127.0.0.1:8000/authenticate/logout/",
                        );
                        if (context.mounted) {
                          if (response['status']) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => const LoginPage()),
                              (route) => false,
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("${response["message"]} Sampai jumpa.")),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(response["message"])),
                            );
                          }
                        }
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      final request = context.read<CookieRequest>();
                      bool isAdmin = false;
                      if (request.jsonData.containsKey('is_admin')) {
                        isAdmin = request.jsonData['is_admin'] == true;
                      }

                      return [
                        const PopupMenuItem(
                          value: 'profile',
                          child: Row(children: [Text('👤'), SizedBox(width: 10), Text('Profile')]),
                        ),
                        const PopupMenuItem(
                          value: 'history',
                          child: Row(children: [Text('🛒'), SizedBox(width: 10), Text('History')]),
                        ),
                        if (isAdmin)
                          const PopupMenuItem(
                            value: 'add_product',
                            child: Row(
                              children: [Icon(Icons.add_box, color: Colors.green, size: 20), SizedBox(width: 10), Text('Add Product')],
                            ),
                          ),
                        const PopupMenuDivider(),
                        const PopupMenuItem(
                          value: 'logout',
                          child: Row(children: [Text('🚪'), SizedBox(width: 10), Text('Logout')]),
                        ),
                      ];
                    },
                  ),
                ],
              ),
            ),

            // Judul & Filter
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Check out our product",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Builder(
                    builder: (innerContext) => InkWell(
                      onTap: () {
                        Scaffold.of(innerContext).openEndDrawer();
                      },
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          const Icon(Icons.sort, size: 32),
                          if (selectedCategories.isNotEmpty)
                            Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: FutureBuilder(
                key: ValueKey(selectedCategories.toString()),
                future: fetchProduct(request),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Tidak ada produk"));
                  } else {
                    return GridView.builder(
                      padding: const EdgeInsets.all(20),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 24,
                        childAspectRatio: 0.60,
                      ),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (_, index) {
                        return ProductCard(
                          product: snapshot.data![index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProductDetailPage(
                                product: snapshot.data![index],
                              ),
                            ),
                          ),
                          onRefresh: () {
                            setState(() {});
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}