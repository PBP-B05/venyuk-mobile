import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/match_model.dart';
import '../widgets/hero_scroller.dart';
import '../widgets/match_card.dart'; // Widget list item yg baru kamu buat tadi
import 'create_match_screen.dart';
import 'match_detail_screen.dart';

class MatchUpScreen extends StatefulWidget {
  const MatchUpScreen({super.key});

  @override
  State<MatchUpScreen> createState() => _MatchUpScreenState();
}

class _MatchUpScreenState extends State<MatchUpScreen> {
  // State Filter
  String _searchQuery = "";
  String _selectedCategory = "all";
  bool _showMyMatches = false;

  final TextEditingController _searchController = TextEditingController();

  Future<List<Match>> fetchMatches(CookieRequest request) async {
    String url = 'http://127.0.0.1:8000/match_up/?format=json';
    
    // Filter
    if (_searchQuery.isNotEmpty) url += '&city=$_searchQuery';
    if (_selectedCategory != 'all') url += '&category=$_selectedCategory';

    try {
      final response = await request.get(url);
      
      // 🔍 DEBUG: Cek Terminal VS Code setelah refresh!
      print("--------------------------------------------------");
      print("RAW RESPONSE DARI DJANGO:");
      print(response); 
      print("--------------------------------------------------");

      List<dynamic> listData = [];
      
      // Cek apakah response berupa HTML (String panjang) -> Tanda Belum Login
      if (response.toString().contains("<!DOCTYPE html>")) {
        print("🚨 WADUH! Server kirim HTML (Halaman Login), bukan JSON.");
        print("👉 Solusi: Matikan @login_required di views.py Django kamu.");
      } 
      // Cek JSON Valid
      else if (response is Map && response.containsKey('results')) {
        listData = response['results'];
      } else if (response is List) {
        listData = response;
      }

      List<Match> matches = [];
      for (var d in listData) {
        if (d != null) {
          try {
            matches.add(Match.fromJson(d));
          } catch (e) {
            print("❌ Gagal parsing match: $e");
          }
        }
      }

      // --- DUMMY DATA (DATA PANCINGAN) ---
      // Kalau list kosong, kita isi paksa biar kelihatan UI-nya jalan
      if (matches.isEmpty) {
        print("⚠️ Data Server Kosong/Gagal. Menampilkan Dummy Data.");
        matches.add(Match(
          id: 999,
          venueId: "dummy-uuid",
          venueName: "TESTING VENUE (DUMMY)",
          venueCity: "Jakarta",
          venueImage: "", // Kosong biar test placeholder
          creatorUsername: "System",
          slotTotal: 10,
          slotTerisi: 5,
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 2)),
          difficultyLevel: "beginner",
          // creatorId: 1, // field ini sudah kita hapus di model baru
        ));
      }
      // -----------------------------------

      return matches;

    } catch (e) {
      print("❌ Error Fetching: $e");
      // Tetap return list kosong (atau dummy) biar gak crash
      return []; 
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryRed = const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Match Up", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder(
        future: fetchMatches(request),
        builder: (context, AsyncSnapshot<List<Match>> snapshot) {
          // 1. Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error Fetching
          if (snapshot.hasError) {
             return Center(child: Text("Error memuat data. Cek koneksi server."));
          }

          final matches = snapshot.data ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. HERO SCROLLER
                // Kalau data kosong, dia otomatis shrink (ilang)
                HeroScroller(matches: matches),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. TABS & FILTER (UI Lama kamu)
                      _buildFilterSection(primaryRed),

                      const SizedBox(height: 32),

                      // 3. LIST MATCHES
                      if (matches.isEmpty)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.only(top: 40),
                            child: Text(
                              "Tidak ada match tersedia.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: matches.length,
                          itemBuilder: (context, index) {
                            // Pakai MatchCard yang baru
                            return MatchCard(
                              match: matches[index], 
                              onTap: () {
                                Navigator.push(
                                  context, 
                                  MaterialPageRoute(builder: (context) => MatchDetailScreen(matchId: matches[index].id))
                                );
                              }
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryRed,
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
           await Navigator.push(
             context, 
             MaterialPageRoute(builder: (context) => const CreateMatchScreen())
           );
           setState(() {}); // Refresh setelah balik
        },
      ),
    );
  }

  // Pisahkan UI Filter biar rapi
  Widget _buildFilterSection(Color primaryRed) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildTabItem("All Match", !_showMyMatches, primaryRed, () => setState(() => _showMyMatches = false)),
            const SizedBox(width: 24),
            _buildTabItem("My Match", _showMyMatches, primaryRed, () => setState(() => _showMyMatches = true)),
          ],
        ),
        const Divider(height: 1, color: Colors.grey),
        const SizedBox(height: 24),
        const Text("Filter", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: "Cari kota...",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        const SizedBox(height: 12),
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
               icon: const Icon(Icons.filter_list, color: Colors.grey),
               
               // DAFTAR KATEGORI LENGKAP (Sesuai Django Venue Models)
               items: const [
                 DropdownMenuItem(value: "all", child: Text("Semua Cabang Olahraga")),
                 DropdownMenuItem(value: "futsal", child: Text("⚽ Futsal")),
                 DropdownMenuItem(value: "sepak bola", child: Text("🥅 Sepak Bola")),
                 DropdownMenuItem(value: "mini soccer", child: Text("🏃 Mini Soccer")),
                 DropdownMenuItem(value: "basketball", child: Text("🏀 Basketball")),
                 DropdownMenuItem(value: "tennis", child: Text("🎾 Tennis")),
                 DropdownMenuItem(value: "padel", child: Text("🎾 Padel")),
                 DropdownMenuItem(value: "badminton", child: Text("🏸 Badminton")),
                 DropdownMenuItem(value: "pickle ball", child: Text("🏓 Pickle Ball")),
                 DropdownMenuItem(value: "squash", child: Text("squash")),
                 DropdownMenuItem(value: "tennis meja", child: Text("🏓 Tennis Meja")),
                 DropdownMenuItem(value: "voli", child: Text("🏐 Voli")),
                 DropdownMenuItem(value: "biliard", child: Text("🎱 Biliard")),
                 DropdownMenuItem(value: "golf", child: Text("⛳ Golf")),
                 DropdownMenuItem(value: "shooting", child: Text("🎯 Shooting")),
               ],
               
               onChanged: (val) {
                 setState(() {
                   _selectedCategory = val!;
                 });
               },
             ),
           ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: primaryRed, foregroundColor: Colors.white),
            onPressed: () => setState(() { _searchQuery = _searchController.text; }),
            child: const Text("Cari Match"),
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String title, bool isActive, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(border: isActive ? Border(bottom: BorderSide(color: color, width: 3)) : null),
        child: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isActive ? Colors.black87 : Colors.grey[500])),
      ),
    );
  }
}