import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/history_page.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/product_form_page.dart';
import 'package:venyuk_mobile/global/screens/login.dart';

class VenyukHeader extends StatelessWidget {
  final String title; 

  const VenyukHeader({super.key, this.title = "Ven-Shop"});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

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
              if (value == 'profile') {
                if (request.loggedIn){
                  ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Fitur Profil sedang dalam pengembangan."),
                              backgroundColor: Colors.red,
                            ),
                          );
                }else {
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
    );
  }
}