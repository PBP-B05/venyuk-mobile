// =====================================
// FILE: lib/features/venyuk/widgets/left_drawer.dart (UPDATE)
// =====================================

import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import '../../auth/login.dart'; 
import '../../match_up/screens/match_up_screen.dart';
import '../../venyuk/pages/venue_page.dart'; 
import '../../promo/screens/promo_page.dart';
import '../../ven_shop/screens/shop_page.dart';
import '../../versus/pages/versus_list_page.dart';
import "../../article/screens/blog_list_page.dart";
import '../../venyuk/pages/landing_page.dart';
import 'package:venyuk_mobile/theme/app_colors.dart';

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryRed = const Color(0xFFEF4444);

    return Drawer(
      child: ListView(
        children: [
          // --- HEADER dengan LOGO ---
          DrawerHeader(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo Image
                Image.asset(
                  'assets/images/logo_venyuk.png', // Ganti dengan path logo Anda
                  height: 80,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    // Fallback jika gambar tidak ditemukan
                    return const Text(
                      'Venyuk!',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                
              ],
            ),
          ),

          // --- 1. VENUE (Home) ---
          ListTile(
            leading: const Icon(Icons.stadium_outlined),
            title: const Text('Venue'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VenuePage()),
              );
            },
          ),

          // --- 2. PROMO ---
          ListTile(
            leading: const Icon(Icons.discount_outlined),
            title: const Text('Promo'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PromoPage()),
              );
            },
          ),

          // --- 3. VEN-SHOP ---
          ListTile(
            leading: const Icon(Icons.shopping_bag_outlined),
            title: const Text('Ven-Shop'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ShopPage()),
              );
            },
          ),

          // --- 4. MATCH UP (Main Bareng) ---
          ListTile(
            leading: const Icon(Icons.groups_2_outlined),
            title: const Text('Match Up'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MatchUpScreen()),
              );
            },
          ),

          // --- 5. VERSUS ---
          ListTile(
            leading: const Icon(Icons.sports_mma_outlined),
            title: const Text('Versus'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VersusListPage()),
              );
            },
          ),

          // --- 6. BLOG ---
          ListTile(
            leading: const Icon(Icons.article_outlined),
            title: const Text('Blog'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const BlogListPage()),
              );
            },
          ),

          const Divider(),

          // --- LOGOUT ---
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              print('Fetching from: https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/authenticate/logout_api/');
              final response = await request.logout(
                "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/authenticate/logout_api/"
              );
              if (!context.mounted) return;

              if (response['status']) {
                String uname = response["username"];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Sampai jumpa, $uname!")),
                );
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LandingPage()),
                  (route) => false,
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(response["message"])),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}