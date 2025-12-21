import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class EditMatchScreen extends StatefulWidget {
  final int matchId;

  const EditMatchScreen({super.key, required this.matchId});

  @override
  State<EditMatchScreen> createState() => _EditMatchScreenState();
}

class _EditMatchScreenState extends State<EditMatchScreen> {
  final _formKey = GlobalKey<FormState>();
  bool isLoading = true;

  // Data Sources
  List<dynamic> venues = [];
  List<dynamic> participants = [];
  
  // Form Controllers & State
  String? selectedVenueId;
  TextEditingController slotController = TextEditingController();
  DateTime? startTime;
  DateTime? endTime;
  String selectedDifficulty = 'beginner';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadInitialData();
    });
  }

  // --- 1. LOAD DATA AWAL (Match Detail & List Venue) ---
  Future<void> loadInitialData() async {
    final request = context.read<CookieRequest>();
    try {
      // Fetch List Venue (Buat Dropdown)
      final venueRes = await request.get('http://localhost:8000/json/');
      
      // Fetch Detail Match (Buat ngisi form)
      final matchRes = await request.get('http://localhost:8000/match_up/${widget.matchId}/json/');

      setState(() {
        venues = venueRes;
        
        final match = matchRes['match'];
        participants = matchRes['participants'];

        // Isi Form dengan data lama
        // Cari ID Venue berdasarkan nama (karena JSON detail biasanya cuma kasih nama)
        // Disini kita lakukan pencocokan sederhana atau anggap user harus pilih ulang jika logic kompleks
        // Untuk simpelnya, kita coba cari venue yang namanya sama
        final existingVenue = venues.firstWhere(
            (v) => v['fields']['name'] == match['venue_name'], 
            orElse: () => null
        );
        
        if (existingVenue != null) {
            selectedVenueId = existingVenue['pk'].toString();
        }

        slotController.text = match['slot_total'].toString();
        startTime = DateTime.parse(match['start_time']);
        endTime = DateTime.parse(match['end_time']);
        selectedDifficulty = match['difficulty_level'];
        
        isLoading = false;
      });
    } catch (e) {
      print("Error loading data: $e");
      setState(() => isLoading = false);
    }
  }

  // --- 2. FUNGSI SAVE CHANGES ---
  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (startTime == null || endTime == null || selectedVenueId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua data!")));
      return;
    }

    final request = context.read<CookieRequest>();
    final url = 'http://localhost:8000/match_up/edit-flutter/${widget.matchId}/';

    try {
      final response = await request.post(
        url,
        jsonEncode({
          'venue': selectedVenueId,
          'slot_total': int.parse(slotController.text),
          'start_time': startTime!.toIso8601String(),
          'end_time': endTime!.toIso8601String(),
          'difficulty_level': selectedDifficulty,
        }),
      );

      if (response['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match berhasil diupdate! ✅")));
        Navigator.pop(context, true); // Balik ke halaman sebelumnya dengan sinyal 'true' (refresh)
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- 3. FUNGSI KICK PARTICIPANT ---
  Future<void> kickParticipant(int participantId, String name) async {
    final request = context.read<CookieRequest>();
    // URL Django: kick-flutter/<match_id>/<participant_id>/
    final url = 'http://localhost:8000/match_up/kick-flutter/${widget.matchId}/$participantId/';

    try {
      final response = await request.post(url, {}); // Kirim POST kosong

      if (response['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name berhasil dikeluarkan.")));
        // Refresh data peserta
        loadInitialData(); 
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['message'])));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal kick: $e")));
    }
  }

  // --- PICKERS ---
  Future<void> pickDateTime(bool isStart) async {
    final date = await showDatePicker(
      context: context, 
      initialDate: isStart ? (startTime ?? DateTime.now()) : (endTime ?? DateTime.now()),
      firstDate: DateTime.now(), 
      lastDate: DateTime(2030)
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context, 
      initialTime: TimeOfDay.fromDateTime(isStart ? (startTime ?? DateTime.now()) : (endTime ?? DateTime.now()))
    );
    if (time == null) return;

    final result = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    setState(() {
      if (isStart) startTime = result;
      else endTime = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: const Color(0xFFEF4444), // BACKGROUND MERAH
      appBar: AppBar(
        title: const Text("Edit Match", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            
            // --- BAGIAN 1: FORM EDIT ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("📝 Edit Detail", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const Divider(height: 24),

                    // Venue Dropdown
                    DropdownButtonFormField<String>(
                      value: selectedVenueId,
                      decoration: const InputDecoration(labelText: "Pilih Venue", border: OutlineInputBorder()),
                      items: venues.map((v) {
                        return DropdownMenuItem<String>(
                          value: v['pk'].toString(),
                          child: Text(v['fields']['name'], overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedVenueId = val),
                      validator: (val) => val == null ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Slot Total
                    TextFormField(
                      controller: slotController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Total Slot", border: OutlineInputBorder()),
                      validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null,
                    ),
                    const SizedBox(height: 16),

                    // Start Time
                    ListTile(
                      title: const Text("Waktu Mulai"),
                      subtitle: Text(startTime != null ? DateFormat('dd MMM yyyy, HH:mm').format(startTime!) : "Pilih Waktu"),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
                      onTap: () => pickDateTime(true),
                    ),
                    const SizedBox(height: 12),

                    // End Time
                    ListTile(
                      title: const Text("Waktu Selesai"),
                      subtitle: Text(endTime != null ? DateFormat('dd MMM yyyy, HH:mm').format(endTime!) : "Pilih Waktu"),
                      trailing: const Icon(Icons.calendar_today),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8), side: BorderSide(color: Colors.grey.shade400)),
                      onTap: () => pickDateTime(false),
                    ),
                    const SizedBox(height: 16),

                    // Difficulty
                    DropdownButtonFormField<String>(
                      value: selectedDifficulty,
                      decoration: const InputDecoration(labelText: "Difficulty", border: OutlineInputBorder()),
                      items: ['beginner', 'intermediate', 'advanced'].map((lvl) {
                        return DropdownMenuItem(value: lvl, child: Text(lvl.toUpperCase()));
                      }).toList(),
                      onChanged: (val) => setState(() => selectedDifficulty = val!),
                    ),
                    const SizedBox(height: 24),

                    // SAVE BUTTON
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        onPressed: saveChanges,
                        child: const Text("Save Changes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // --- BAGIAN 2: MANAGE PARTICIPANTS ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("👥 Manage Participants (${participants.length})", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const Divider(height: 24),

                  if (participants.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: Center(child: Text("Belum ada peserta.", style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic))),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: participants.length,
                      itemBuilder: (context, index) {
                        final p = participants[index];
                        // Asumsi backend mengirim data peserta yg lengkap. 
                        // Karena kita pakai endpoint detail_json, biasanya strukturnya: 
                        // "full_name": "...", "phone": "..."
                        // Kita butuh ID Participant untuk nge-kick.
                        // Pastikan di show_match_detail_json kamu menambahkan 'id' peserta!
                        // Kalau belum, update view show_match_detail_json di Django:
                        // "id": p.id, "full_name": p.full_name...
                        
                        // Fallback kalau ID ga ada (harus diupdate di backend biar jalan)
                        final pId = p['id'] ?? 0; 
                        
                        return Card(
                          color: Colors.grey[50],
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(p['full_name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(p['phone']),
                            trailing: IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context, 
                                  builder: (ctx) => AlertDialog(
                                    title: const Text("Kick User?"),
                                    content: Text("Yakin ingin mengeluarkan ${p['full_name']}?"),
                                    actions: [
                                      TextButton(onPressed: ()=>Navigator.pop(ctx), child: const Text("Batal")),
                                      TextButton(onPressed: () {
                                        Navigator.pop(ctx);
                                        kickParticipant(pId, p['full_name']);
                                      }, child: const Text("Kick", style: TextStyle(color: Colors.red))),
                                    ],
                                  )
                                );
                              },
                            ),
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
    );
  }
}