import 'package:flutter/material.dart';
import 'package:venyuk_mobile/features/ven_shop/screens/shop_page.dart';
import 'package:venyuk_mobile/global/widget/chatbot.dart'; // Pastikan path ini benar
import 'package:venyuk_mobile/features/promo/screens/promo_page.dart';
import 'package:venyuk_mobile/features/venyuk/pages/venue_page.dart';
import 'package:venyuk_mobile/features/match_up/screens/match_up_screen.dart';
import 'package:venyuk_mobile/features/article/screens/blog_list_page.dart';

class MainNav extends StatefulWidget {
  const MainNav({super.key});

  @override
  State<MainNav> createState() => _MainNavState();
}

class _MainNavState extends State<MainNav> {
  int _selectedIndex = 0; 

  final List<Widget> _pages = [
    const VenuePage(),
    
    const PromoPage(),
    
    const ShopPage(),
    
    const MatchUpScreen(),
    
    const BlogListPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),

      
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.black12, width: 0.5)),
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, -2))
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          currentIndex: _selectedIndex,
          selectedItemColor: const Color(0xFFD84040), 
          unselectedItemColor: Colors.grey,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          onTap: _onItemTapped,
          items: const [

            // Venue
            BottomNavigationBarItem(
              icon: Icon(Icons.stadium_outlined, size: 28),
              activeIcon: Icon(Icons.stadium, size: 28),
              label: 'Venue',
            ),
            
            // Promo
            BottomNavigationBarItem(
              icon: Icon(Icons.local_offer_outlined, size: 28),
              activeIcon: Icon(Icons.local_offer, size: 28),
              label: 'Promo',
            ),
            
            // Shop
            BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag_outlined, size: 28),
              activeIcon: Icon(Icons.shopping_bag, size: 28), 
              label: 'Shop',
            ),
            
            // Match up and versus
            BottomNavigationBarItem(
              icon: Icon(Icons.scoreboard_outlined, size: 28),
              activeIcon: Icon(Icons.scoreboard, size: 28),
              label: 'Match',
            ),
            
            // Community
            BottomNavigationBarItem(
              icon: Icon(Icons.forum_outlined, size: 28),
              activeIcon: Icon(Icons.forum, size: 28),
              label: 'Community',
            ),
          ],
        ),
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20.0), 
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [
                Color(0xFFFF5252), 
                Color(0xFFD32F2F)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 8,
                offset: Offset(2, 4),
              )
            ],
          ),
          child: FloatingActionButton(
            heroTag: 'chatbot_global',
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: const ChatScreen(),
                ),
              );
            },
            backgroundColor: Colors.transparent, 
            elevation: 0, 
            shape: const CircleBorder(),
            child: const Icon(Icons.chat_bubble_outline, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }
}
