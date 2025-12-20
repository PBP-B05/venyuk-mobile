import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool isLoading = true;
  
  // Data State
  Map<String, dynamic>? matchData;
  List<dynamic> participants = [];
  bool isMyMatch = false;
  bool isJoined = false;

  // Controller Form Join
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDetail();
    });
  }

  // --- FETCH DATA (URL CHROME) ---
  Future<void> fetchDetail() async {
    final request = context.read<CookieRequest>();
    
    // UBAH URL INI: Tambahkan '/json/' di belakang ID
    final String url = 'http://127.0.0.1:8000/match_up/${widget.matchId}/json/';

    try {
      final response = await request.get(url);
      
      // Debug print biar tau isinya apa
      print("Detail Response: $response");

      setState(() {
        matchData = response['match'];
        participants = response['participants'];
        isMyMatch = response['is_my_match'];
        isJoined = response['is_joined'];
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching detail: $e");
      setState(() => isLoading = false);
    }
  }

  // --- JOIN MATCH ---
  Future<void> joinMatch() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi nama dan nomor telepon dulu!")));
      return;
    }

    final request = context.read<CookieRequest>();
    // URL FIX CHROME
    final String url = 'http://127.0.0.1:8000/match_up/join/${widget.matchId}/';

    try {
      final response = await request.post(
        url,
        {
          'full_name': _nameController.text,
          'phone': _phoneController.text,
        },
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Berhasil Join! 🎉")));
          fetchDetail(); // Refresh data
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['message'] ?? "Gagal join."),
            backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Terjadi kesalahan saat join.")));
    }
  }

  // --- DELETE MATCH ---
  Future<void> deleteMatch() async {
    final request = context.read<CookieRequest>();
    // URL FIX CHROME
    final String url = 'http://127.0.0.1:8000/match_up/delete/${widget.matchId}/';

    await request.post(url, {});
    
    if (mounted) {
       ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match dihapus.")));
       Navigator.pop(context); // Kembali ke list screen
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (matchData == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Error")),
        body: const Center(child: Text("Data tidak ditemukan atau error koneksi.")),
      );
    }

    // Parsing Data
    final venueName = matchData!['venue_name'];
    final venueCategory = "Category TBD"; 
    final venueAddress = matchData!['venue_city'] ?? "Alamat belum diatur"; 
    final venuePrice = "Rp 50.000"; 
    final isAvailable = true; 

    final creatorName = matchData!['creator_username'];
    final slotInfo = "${matchData!['slot_terisi']} / ${matchData!['slot_total']}";
    final difficulty = matchData!['difficulty_level'];
    
    final startTime = DateTime.parse(matchData!['start_time']);
    final endTime = DateTime.parse(matchData!['end_time']);
    final timeString = "${DateFormat('HH:mm').format(startTime)} - ${DateFormat('HH:mm').format(endTime)}";
    final dateString = DateFormat('EEEE, d MMM yyyy').format(startTime);

    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), 
      ),
      body: Stack(
        children: [
          // LAYER 1: BACKGROUND
          Positioned.fill(
            child: Image.asset(
              'assets/images/register_bg.png',
              fit: BoxFit.cover,
              color: Colors.black45,
              colorBlendMode: BlendMode.darken,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: Colors.blueAccent);
              },
            ),
          ),

          // LAYER 2: KONTEN
          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 40), 
            child: Column(
              children: [
                
                // --- CARD DETAIL ---
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16), 
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      // HEADER IMAGE & DIFFICULTY
                      Stack(
                        children: [
                          Container(
                            height: 150,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                            ),
                            child: const Center(child: Icon(Icons.stadium, size: 64, color: Colors.white54)),
                          ),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[600],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                "⭐ $difficulty",
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      Padding(
                        padding: const EdgeInsets.all(24.0), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            
                            // VENUE INFO
                            _buildSectionHeader("🏟 Venue Detail"),
                            Text(
                              venueName,
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                            ),
                            Text(
                              venueCategory.toUpperCase(), 
                              style: TextStyle(color: Colors.grey[600], letterSpacing: 1.2, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            _buildDetailRow("📍 Alamat:", venueAddress),
                            _buildDetailRow("💰 Harga:", venuePrice),
                            _buildDetailRow("📌 Status:", isAvailable ? "Tersedia" : "Tidak Tersedia", 
                              valueColor: isAvailable ? Colors.green[600] : Colors.red[600]),
                            
                            const SizedBox(height: 24),

                            // MATCH INFO
                            _buildSectionHeader("⚽ Match Detail"),
                            _buildDetailRow("👤 Pembuat:", creatorName),
                            _buildDetailRow("📅 Tanggal:", dateString), 
                            _buildDetailRow("⏰ Waktu:", timeString),
                            _buildDetailRow("🎟️ Slot:", slotInfo),
                            _buildDetailRow("🎯 Level:", difficulty),
                            const SizedBox(height: 8),
                            const Text("📝 Deskripsi:", style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                               matchData!['description'] ?? "Tidak ada deskripsi tambahan.",
                               style: const TextStyle(color: Colors.black87),
                            ),

                            const SizedBox(height: 24),
                            const Divider(),
                            const SizedBox(height: 16),

                            // PARTICIPANTS
                            const Text("👥 Peserta Terdaftar", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (participants.isEmpty)
                              const Text("Belum ada peserta yang terdaftar.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))
                            else
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: participants.length,
                                itemBuilder: (context, index) {
                                  final p = participants[index];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.circle, size: 8, color: Colors.black54),
                                        const SizedBox(width: 8),
                                        Text(p['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                                        if (isMyMatch)
                                           Text(" - ${p['phone']}", style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                // ACTION BOX
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0,5)),
                    ],
                  ),
                  child: isMyMatch ? _buildCreatorActions() : _buildJoinForm(),
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS HELPER ---
  Widget _buildSectionHeader(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Divider(color: Colors.grey[300], thickness: 1),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 14),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value, style: TextStyle(color: valueColor ?? Colors.black87)),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinForm() {
    if (isJoined) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green[50],
          border: Border.all(color: Colors.green[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text("🎉 Kamu sudah bergabung!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      );
    }

    final isFull = matchData!['slot_terisi'] >= matchData!['slot_total'];
    if (isFull) {
       return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          border: Border.all(color: Colors.red[200]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(child: Text("🚫 Maaf, Slot sudah penuh.", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader("🎉 Join Match"),
        
        const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: "Masukkan nama lengkap",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),

        const Text("No. Telepon", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 4),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            hintText: "Contoh: 08123456789",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
        const SizedBox(height: 24),

        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: joinMatch,
            child: const Text("Match Up!", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  Widget _buildCreatorActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.yellow[700], 
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Edit: Coming Soon")));
            },
            child: const Text("Edit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              showDialog(
                context: context, 
                builder: (ctx) => AlertDialog(
                  title: const Text("Hapus Match?"),
                  content: const Text("Yakin ingin menghapus match ini?"),
                  actions: [
                    TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                    TextButton(onPressed: deleteMatch, child: const Text("Hapus", style: TextStyle(color: Colors.red))),
                  ],
                )
              );
            },
            child: const Text("Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}