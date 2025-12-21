import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

// --- IMPORTS ---
import '../models/match_model.dart';
import '../widgets/hero_scroller.dart';
import '../widgets/match_card.dart';

// Import Drawer dari features/venyuk (Sesuaikan path ini jika perlu)
import '../../venyuk/widgets/left_drawer.dart'; 

import 'create_match_screen.dart';
import 'match_detail_screen.dart';

class MatchUpScreen extends StatefulWidget {
  const MatchUpScreen({super.key});

  @override
  State<MatchUpScreen> createState() => _MatchUpScreenState();
}

class _MatchUpScreenState extends State<MatchUpScreen> {
  // --- STATE VARIABLES ---
  String _searchQuery = "";
  String _selectedCategory = "all";
  bool _showMyMatches = false;
  
  final TextEditingController _searchController = TextEditingController();

  // --- FETCH DATA FROM DJANGO ---
  Future<List<Match>> fetchMatches(CookieRequest request) async {
    // URL Endpoint Django
    String url = 'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/match_up/?format=json';
    
    // 1. Pasang Filter Pencarian & Kategori
    if (_searchQuery.isNotEmpty) url += '&city=$_searchQuery';
    if (_selectedCategory != 'all') url += '&category=$_selectedCategory';

    // 2. Pasang Filter "My Match" (Server-Side)
    if (_showMyMatches) {
      url += '&my_match=true';
    }

    try {
      final response = await request.get(url);

      // Parsing JSON (Handle struktur pagination Django atau List biasa)
      List<dynamic> listData = [];
      if (response is Map && response.containsKey('results')) {
        listData = response['results'];
      } else if (response is List) {
        listData = response;
      }

      // Konversi ke Object Match
      List<Match> matches = [];
      for (var d in listData) {
        if (d != null) {
          try {
            matches.add(Match.fromJson(d));
          } catch (e) {
            // Skip data yang error parsing diam-diam
          }
        }
      }
      return matches;

    } catch (e) {
      // Jika error (misal koneksi putus), return list kosong
      return []; 
    }
  }

  // --- POPUP FILTER DIALOG ---
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return AlertDialog(
              title: const Text("Filter Kategori"),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text("Pilih cabang olahraga yang ingin ditampilkan:"),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!), 
                      borderRadius: BorderRadius.circular(8)
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _selectedCategory,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(value: "all", child: Text("Semua Cabang")),
                          DropdownMenuItem(value: "futsal", child: Text("⚽ Futsal")),
                          DropdownMenuItem(value: "sepak bola", child: Text("🥅 Sepak Bola")),
                          DropdownMenuItem(value: "mini soccer", child: Text("🏃 Mini Soccer")),
                          DropdownMenuItem(value: "basketball", child: Text("🏀 Basketball")),
                          DropdownMenuItem(value: "tennis", child: Text("🎾 Tennis")),
                          DropdownMenuItem(value: "padel", child: Text("🎾 Padel")),
                          DropdownMenuItem(value: "badminton", child: Text("🏸 Badminton")),
                          DropdownMenuItem(value: "pickle ball", child: Text("🏓 Pickle Ball")),
                          DropdownMenuItem(value: "squash", child: Text("Squash")),
                          DropdownMenuItem(value: "tennis meja", child: Text("🏓 Tennis Meja")),
                          DropdownMenuItem(value: "voli", child: Text("🏐 Voli")),
                          DropdownMenuItem(value: "biliard", child: Text("🎱 Biliard")),
                          DropdownMenuItem(value: "golf", child: Text("⛳ Golf")),
                          DropdownMenuItem(value: "shooting", child: Text("🎯 Shooting")),
                        ],
                        onChanged: (val) {
                          setStateModal(() => _selectedCategory = val!);
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal", style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
                  onPressed: () {
                    setState(() {}); // Refresh halaman utama
                    Navigator.pop(context);
                  },
                  child: const Text("Terapkan", style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // --- BUILD UI ---
  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryRed = const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      
      // 1. DRAWER (Menu Samping)
      drawer: const LeftDrawer(),

      // 2. APP BAR
      appBar: AppBar(
        title: const Text(
          "Match Up!", 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: Colors.black), // Hamburger jadi hitam
        actions: [
           // Icon Profile (Placeholder)
           IconButton(
             icon: const Icon(Icons.account_circle, color: Colors.black, size: 30),
             onPressed: () {
               ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("Fitur Profile akan segera hadir!"))
               );
             },
           ),
           const SizedBox(width: 8),
        ],
      ),
      
      // 3. BODY CONTENT
      body: RefreshIndicator(
        onRefresh: () async => setState(() {}),
        child: FutureBuilder(
          future: fetchMatches(request),
          builder: (context, AsyncSnapshot<List<Match>> snapshot) {
            
            // Loading State
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final matches = snapshot.data ?? [];

            return ListView(
              padding: const EdgeInsets.only(bottom: 80),
              children: [
                
                // A. HERO SCROLLER (Banner)
                // Hanya tampil kalau bukan tab "My Match" dan ada datanya
                if (!_showMyMatches && matches.isNotEmpty) ...[
                  HeroScroller(matches: matches),
                  const SizedBox(height: 16),
                ],

                // B. SEARCH BAR & FILTER BUTTON
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      // Kolom Search
                      Expanded(
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TextField(
                            controller: _searchController,
                            decoration: const InputDecoration(
                              hintText: "Cari kota...",
                              border: InputBorder.none,
                              prefixIcon: Icon(Icons.search, color: Colors.grey),
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            onSubmitted: (val) => setState(() => _searchQuery = val),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      
                      // Tombol Filter
                      GestureDetector(
                        onTap: _showFilterDialog,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: _selectedCategory == 'all' ? Colors.grey[100] : primaryRed.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedCategory != 'all' ? Border.all(color: primaryRed) : null,
                          ),
                          child: Icon(
                            Icons.tune, 
                            color: _selectedCategory == 'all' ? Colors.grey[700] : primaryRed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // C. TABS (All Match / My Match)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      _buildTabItem("All Match", !_showMyMatches, primaryRed, () => setState(() => _showMyMatches = false)),
                      const SizedBox(width: 20),
                      _buildTabItem("My Match", _showMyMatches, primaryRed, () => setState(() => _showMyMatches = true)),
                    ],
                  ),
                ),
                const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),

                // D. LIST MATCHES
                if (matches.isEmpty) 
                  const Padding(
                    padding: EdgeInsets.only(top: 50),
                    child: Center(
                      child: Text(
                        "Tidak ada match ditemukan.", 
                        style: TextStyle(color: Colors.grey)
                      ),
                    ),
                  )
                else 
                  ListView.builder(
                    shrinkWrap: true, // Wajib agar tidak error di dalam ListView parent
                    physics: const NeverScrollableScrollPhysics(), // Scroll ikut parent
                    itemCount: matches.length,
                    itemBuilder: (context, index) {
                      return MatchCard(
                        match: matches[index], 
                        onTap: () {
                          Navigator.push(
                            context, 
                            MaterialPageRoute(
                              builder: (context) => MatchDetailScreen(matchId: matches[index].id)
                            )
                          );
                        }
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),

      // 4. FLOATING ACTION BUTTON (Tambah Match)
      floatingActionButton: FloatingActionButton(
        // LOGIKA WARNA:
        // Kalau Login -> Merah (primaryRed)
        // Kalau Belum -> Abu-abu (Colors.grey)
        backgroundColor: request.loggedIn ? primaryRed : Colors.grey,
        
        child: const Icon(Icons.add, color: Colors.white),
        
        // LOGIKA AKSI:
        onPressed: () async {
          if (request.loggedIn) {
            // --- SKENARIO SUDAH LOGIN ---
            await Navigator.push(
              context, 
              MaterialPageRoute(builder: (context) => const CreateMatchScreen())
            );
            setState(() {}); // Refresh setelah balik
          } else {
            // --- SKENARIO BELUM LOGIN ---
            // Tampilkan pesan error tipis-tipis
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Ups! Kamu harus login dulu untuk membuat match."),
                backgroundColor: Colors.grey,
                duration: Duration(seconds: 2),
              ),
            );
            
            // Opsional: Arahkan ke halaman login jika mau
            // Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginPage()));
          }
        },
      ),
    );
  }

  // Widget Helper untuk Tab Item
  Widget _buildTabItem(String title, bool isActive, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: isActive ? Border(bottom: BorderSide(color: color, width: 2)) : null
        ),
        child: Text(
          title, 
          style: TextStyle(
            fontWeight: FontWeight.bold, 
            color: isActive ? color : Colors.grey[400],
            fontSize: 16
          )
        ),
      ),
    );
  }
}