import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- UPDATE IMPORT PATH ---
// Mundur 3 langkah (widgets -> venyuk -> features -> lib) lalu masuk auth
import '../../auth/login.dart'; 

// Mundur 2 langkah (widgets -> venyuk) lalu masuk match-up
import '../../match_up/screens/match_up_screen.dart';

// import '../../venue/screens/venue_home_screen.dart'; // Contoh buat nanti

class LeftDrawer extends StatelessWidget {
  const LeftDrawer({super.key});
  
  // ... (Sisa kode ke bawah SAMA PERSIS seperti sebelumnya) ...
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryRed = const Color(0xFFEF4444);

    return Drawer(
      // ... copy paste isi build dari jawaban sebelumnya ...
      child: ListView(
        children: [
           DrawerHeader(
            decoration: BoxDecoration(color: primaryRed),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Venyuk!', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                Padding(padding: EdgeInsets.all(10)),
                Text("Temukan lawan mainmu di sini!", textAlign: TextAlign.center, style: TextStyle(fontSize: 15, color: Colors.white)),
              ],
            ),
          ),
          
          ListTile(
            leading: const Icon(Icons.stadium_outlined),
            title: const Text('Venue'),
            onTap: () => Navigator.pop(context),
          ),
          // ... Menu lainnya ...
          
          ListTile(
            leading: const Icon(Icons.groups_2_outlined), 
            title: const Text('Main Bareng'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MatchUpScreen()),
              );
            },
          ),
          
          // ... Sisa menu & Logout ...
           ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              final response = await request.logout("http://localhost:8000/authenticate/logout/");
              if (!context.mounted) return;
              if (response['status']) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Sampai jumpa!")));
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
              }
            },
          ),
        ],
      ),
    );
  }
}