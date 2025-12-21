import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'edit_match_screen.dart';

class MatchDetailScreen extends StatefulWidget {
  final int matchId;

  const MatchDetailScreen({super.key, required this.matchId});

  @override
  State<MatchDetailScreen> createState() => _MatchDetailScreenState();
}

class _MatchDetailScreenState extends State<MatchDetailScreen> {
  bool isLoading = true;
  
  Map<String, dynamic>? matchData;
  List<dynamic> participants = [];
  bool isMyMatch = false;
  bool isJoined = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchDetail();
    });
  }

  String getSmartImageUrl(String? rawUrl) {
    if (rawUrl == null || rawUrl.isEmpty) return "";
    
    if (rawUrl.startsWith('http')) {
      final encoded = Uri.encodeComponent(rawUrl);
      return "http://localhost:8000/match_up/proxy-image/?url=$encoded";
    } 
    
    return "http://localhost:8000$rawUrl";
  }

  Future<void> fetchDetail() async {
    final request = context.read<CookieRequest>();
    final String url = 'http://localhost:8000/match_up/${widget.matchId}/json/';

    try {
      final response = await request.get(url);
      setState(() {
        matchData = response['match'];
        participants = response['participants'];
        isMyMatch = response['is_my_match'];
        isJoined = response['is_joined'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  Future<void> joinMatch() async {
    if (_nameController.text.isEmpty || _phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Isi data diri dulu!")));
      return;
    }

    final request = context.read<CookieRequest>();
    final String url = 'http://localhost:8000/match_up/join-flutter/${widget.matchId}/';

    try {
      final response = await request.post(
        url,
        jsonEncode({
          'full_name': _nameController.text,
          'phone': _phoneController.text,
        }),
      );

      if (mounted) {
        if (response['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Berhasil Join! 🎉"), backgroundColor: Colors.green
          ));
          fetchDetail();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(response['message'] ?? "Gagal join."), backgroundColor: Colors.red,
          ));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  Future<void> deleteMatch() async {
    final request = context.read<CookieRequest>();
    final String url = 'http://localhost:8000/match_up/delete-flutter/${widget.matchId}/';

    try {
      await request.post(url, {});
      
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
           content: Text("Match berhasil dihapus."), backgroundColor: Colors.red
         ));
         Navigator.pop(context); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Gagal menghapus match.")));
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (matchData == null) return const Scaffold(body: Center(child: Text("Data error.")));

    final venueName = matchData!['venue_name'];
    final creatorName = matchData!['creator_username'];
    final difficulty = matchData!['difficulty_level'];
    final startTime = DateTime.parse(matchData!['start_time']);
    final timeString = DateFormat('HH:mm').format(startTime);
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
          Positioned.fill(
            child: Container(color: const Color(0xFFEF4444)), 
          ),

          SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 100, 16, 40), 
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16), 
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          image: matchData!['venue_image'] != null 
                              ? DecorationImage(
                                  image: NetworkImage(getSmartImageUrl(matchData!['venue_image'])),
                                  fit: BoxFit.cover
                                )
                              : null
                        ),
                        child: matchData!['venue_image'] == null 
                            ? const Center(child: Icon(Icons.stadium, size: 50, color: Colors.grey))
                            : null,
                      ),
                      
                      Padding(
                        padding: const EdgeInsets.all(24.0), 
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(venueName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            _buildDetailRow("📅 Tanggal:", dateString), 
                            _buildDetailRow("⏰ Waktu:", timeString),
                            _buildDetailRow("👤 Host:", creatorName),
                            _buildDetailRow("⭐ Level:", difficulty),
                            const Divider(height: 30),
                            
                            const Text("👥 Peserta", style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            if (participants.isEmpty)
                              const Text("- Belum ada peserta -", style: TextStyle(color: Colors.grey))
                            else
                              ...participants.map((p) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text("• ${p['full_name']} ${isMyMatch ? '(${p['phone']})' : ''}"),
                              )),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 8),
          Text(value),
        ],
      ),
    );
  }

  Widget _buildCreatorActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🔧 Kelola Match", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        const Text("Ini adalah match yang kamu buat.", style: TextStyle(color: Colors.grey)),
        const SizedBox(height: 16),
        
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[400],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EditMatchScreen(matchId: widget.matchId)),
                  );

                  if (result == true) {
                    fetchDetail();
                  }
                },
                child: const Text("Edit", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            
            const SizedBox(width: 16),
            
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                onPressed: () {
                  showDialog(
                    context: context, 
                    builder: (ctx) => AlertDialog(
                      title: const Text("Hapus Match?"),
                      content: const Text("Yakin ingin menghapus match ini? Tindakan ini tidak bisa dibatalkan."),
                      actions: [
                        TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            deleteMatch();
                          }, 
                          child: const Text("Hapus", style: TextStyle(color: Colors.red))
                        ),
                      ],
                    )
                  );
                },
                child: const Text("Delete", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJoinForm() {
    if (isJoined) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.green[50], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text("✅ Kamu sudah bergabung di match ini!", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))),
      );
    }

    final isFull = matchData!['slot_terisi'] >= matchData!['slot_total'];
    if (isFull) {
       return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text("🚫 Slot Penuh", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("🎉 Join Match", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Divider(),
        const SizedBox(height: 10),
        
        const Text("Nama Lengkap", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _nameController, decoration: const InputDecoration(hintText: "Masukkan nama")),
        const SizedBox(height: 12),

        const Text("No. Telepon", style: TextStyle(fontWeight: FontWeight.bold)),
        TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(hintText: "08xxxxx")),
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
}