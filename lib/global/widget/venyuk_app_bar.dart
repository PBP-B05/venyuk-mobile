import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/history_page.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/product_form_page.dart';
import '../../features/venyuk/pages/landing_page.dart';
import '../../features/auth/login.dart';

class VenyukAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? additionalActions;
  final bool showUserMenu;
  final bool showDrawerButton;
  final bool showAddProduct; // Parameter baru
  final VoidCallback? onAddProduct; // Callback untuk add product

  const VenyukAppBar({
    Key? key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.additionalActions,
    this.showUserMenu = true,
    this.showDrawerButton = true,
    this.showAddProduct = false, 
    this.onAddProduct,
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(70);

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Container(
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Leading: Drawer atau Back button
              if (showDrawerButton && !showBackButton)
                Builder(
                  builder: (innerContext) => IconButton(
                    icon: const Icon(Icons.menu, color: Colors.white),
                    onPressed: () {
                      Scaffold.of(innerContext).openDrawer();
                    },
                  ),
                )
              else if (showBackButton)
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: onBackPressed ?? () => Navigator.pop(context),
                ),

              const SizedBox(width: 8),

              // Title
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Additional actions (optional)
              if (additionalActions != null) ...additionalActions!,

              // User menu
              if (showUserMenu) _buildUserMenu(context, request),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserMenu(BuildContext context, CookieRequest request) {
    return PopupMenuButton<String>(
      offset: const Offset(0, 50),
      tooltip: 'Menu Pengguna',
      color: Colors.white,
      surfaceTintColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, color: Color(0xFFD84040)),
      ),
      onSelected: (String value) => _handleMenuSelection(context, value, request),
      itemBuilder: (BuildContext context) => _buildMenuItems(request),
    );
  }

  List<PopupMenuEntry<String>> _buildMenuItems(CookieRequest request) {
    // Check if user is admin/superuser
    bool isAdmin = false;
    if (request.jsonData.containsKey('is_admin')) {
      isAdmin = request.jsonData['is_admin'] == true;
    } else if (request.jsonData.containsKey('is_superuser')) {
      isAdmin = request.jsonData['is_superuser'] == true;
    }

    return [
      const PopupMenuItem(
        value: 'profile',
        child: Row(
          children: [
            Icon(Icons.person_outline, size: 20, color: Color(0xFF374151)),
            SizedBox(width: 10),
            Text('Profile'),
          ],
        ),
      ),
      const PopupMenuItem(
        value: 'history',
        child: Row(
          children: [
            Icon(Icons.shopping_bag_outlined, size: 20, color: Color(0xFF374151)),
            SizedBox(width: 10),
            Text('History'),
          ],
        ),
      ),

      if (showAddProduct && isAdmin)
        const PopupMenuItem(
          value: 'add_product',
          child: Row(
            children: [
              Icon(Icons.add_box_outlined, color: Colors.green, size: 20),
              SizedBox(width: 10),
              Text('Add Product'),
            ],
          ),
        ),
      const PopupMenuDivider(),
      const PopupMenuItem(
        value: 'logout',
        child: Row(
          children: [
            Icon(Icons.logout, size: 20, color: Colors.red),
            SizedBox(width: 10),
            Text('Logout', style: TextStyle(color: Colors.red)),
          ],
        ),
      ),
    ];
  }

  Future<void> _handleMenuSelection(
    BuildContext context,
    String value,
    CookieRequest request,
  ) async {
    switch (value) {
      case 'profile':
        if (request.loggedIn) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Fitur Profil sedang dalam pengembangan."),
              backgroundColor: Colors.orange,
            ),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        }
        break;

      case 'history':
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
        break;

      case 'add_product':
        if (onAddProduct != null) {
          onAddProduct!();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProductFormPage()),
          );
        }
        break;
      case 'logout':
        final response = await request.logout(
          "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/authenticate/logout_api/",
        );
        if (context.mounted) {
          if (response['status']) {
            String username = response['username'] ?? 'User';
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LandingPage()),
              (route) => false,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Sampai jumpa, $username!")),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(response["message"] ?? "Logout gagal")),
            );
          }
        }
        break;
    }
  }
}