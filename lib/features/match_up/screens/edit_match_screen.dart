import 'dart:convert';
import 'dart:math';
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

  // Helpers to safely extract venue name / pk from various JSON shapes
  String? _venueNameOf(dynamic v) {
    if (v == null) return null;
    if (v is Map) {
      if (v['fields'] is Map && v['fields']['name'] != null) return v['fields']['name'].toString();
      if (v['name'] != null) return v['name'].toString();
      if (v['title'] != null) return v['title'].toString();
      if (v['venue_name'] != null) return v['venue_name'].toString();
    }
    return null;
  }

  String? _venuePkOf(dynamic v) {
    if (v == null) return null;
    if (v is Map) {
      if (v['pk'] != null) return v['pk'].toString();
      if (v['id'] != null) return v['id'].toString();
      if (v['venue_id'] != null) return v['venue_id'].toString();
    }
    return null;
  }

  // --- 1. LOAD DATA AWAL (Match Detail & List Venue) ---
  Future<void> loadInitialData() async {
    final request = context.read<CookieRequest>();
    try {
      // Fetch List Venue (Buat Dropdown)
      final rawVenueRes = await request.get('https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/json/');

      // Normalize venues into a List<dynamic>
      List<dynamic> parsedVenues = [];
      if (rawVenueRes == null) {
        parsedVenues = [];
      } else if (rawVenueRes is List) {
        parsedVenues = rawVenueRes;
      } else if (rawVenueRes is Map) {
        if (rawVenueRes['results'] is List) parsedVenues = List<dynamic>.from(rawVenueRes['results']);
        else if (rawVenueRes['venues'] is List) parsedVenues = List<dynamic>.from(rawVenueRes['venues']);
        else if (rawVenueRes['data'] is List) parsedVenues = List<dynamic>.from(rawVenueRes['data']);
        else {
          // Try to find the first list value inside the map
          final firstList = rawVenueRes.values.firstWhere((v) => v is List, orElse: () => null);
          if (firstList is List) parsedVenues = List<dynamic>.from(firstList);
        }
      } else if (rawVenueRes is String) {
        try {
          final decoded = jsonDecode(rawVenueRes);
          if (decoded is List) parsedVenues = decoded;
          else if (decoded is Map && decoded['results'] is List) parsedVenues = List<dynamic>.from(decoded['results']);
        } catch (_) {
          parsedVenues = [];
        }
      }

      // Fetch Detail Match (Buat ngisi form)
      final rawMatchRes = await request.get('https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/match_up/${widget.matchId}/json/');

      // Normalize match structure
      dynamic matchObj;
      List<dynamic> parsedParticipants = [];
      if (rawMatchRes == null) {
        matchObj = null;
      } else if (rawMatchRes is Map && rawMatchRes.containsKey('match')) {
        matchObj = rawMatchRes['match'];
        if (rawMatchRes['participants'] is List) parsedParticipants = List<dynamic>.from(rawMatchRes['participants']);
      } else if (rawMatchRes is Map && rawMatchRes.containsKey('data')) {
        matchObj = rawMatchRes['data'];
        if (rawMatchRes['participants'] is List) parsedParticipants = List<dynamic>.from(rawMatchRes['participants']);
      } else if (rawMatchRes is Map && rawMatchRes['match'] == null) {
        // Maybe the endpoint returned the match directly as a map
        matchObj = rawMatchRes;
        if (rawMatchRes['participants'] is List) parsedParticipants = List<dynamic>.from(rawMatchRes['participants']);
      } else {
        matchObj = rawMatchRes;
      }

      setState(() {
        venues = parsedVenues;
        participants = parsedParticipants;

        if (matchObj != null && matchObj is Map) {
          // Fill form with existing data (guard nulls)
          final match = matchObj;
          final matchVenueName = match['venue_name'] ?? match['venue'] ?? match['venue_name_display'] ?? null;

          final existingVenue = venues.firstWhere(
              (v) => _venueNameOf(v) != null && _venueNameOf(v) == (matchVenueName?.toString() ?? ''),
              orElse: () => null);

          if (existingVenue != null) {
            selectedVenueId = _venuePkOf(existingVenue);
          }

          slotController.text = (match['slot_total'] ?? match['slot'] ?? '').toString();
          try {
            if (match['start_time'] != null) startTime = DateTime.parse(match['start_time'].toString());
            if (match['end_time'] != null) endTime = DateTime.parse(match['end_time'].toString());
          } catch (_) {
            startTime = null;
            endTime = null;
          }
          selectedDifficulty = (match['difficulty_level'] ?? 'beginner').toString();
        } else {
          // If matchObj is null or unexpected, keep sensible defaults
          slotController.text = '';
          selectedDifficulty = 'beginner';
        }

        isLoading = false;
      });
    } catch (e, st) {
      // Keep UI responsive and show an error message instead of crashing
      print("Error loading data: $e\n$st");
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Gagal memuat data: $e")));
      }
    }
  }

  // --- 2. FUNGSI SAVE CHANGES ---
  Future<void> saveChanges() async {
    if (!_formKey.currentState!.validate()) return;
    if (startTime == null || endTime == null || selectedVenueId == null || selectedVenueId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi semua data!")));
      return;
    }

    final request = context.read<CookieRequest>();
    final url = 'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/match_up/edit-flutter/${widget.matchId}/';

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

      if (response != null && response['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match berhasil diupdate! ✅")));
        Navigator.pop(context, true); // Balik ke halaman sebelumnya dengan sinyal 'true' (refresh)
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response?['message']?.toString() ?? "Gagal update.")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  // --- 3. FUNGSI KICK PARTICIPANT ---
  Future<void> kickParticipant(int participantId, String name) async {
    final request = context.read<CookieRequest>();
    // URL Django: kick-flutter/<match_id>/<participant_id>/
    final url = 'https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/match_up/kick-flutter/${widget.matchId}/$participantId/';

    try {
      final response = await request.post(url, {}); // Kirim POST kosong

      if (response != null && response['status'] == 'success') {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("$name berhasil dikeluarkan.")));
        // Refresh data peserta
        loadInitialData();
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response?['message']?.toString() ?? "Gagal kick.")));
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
      lastDate: DateTime(2030),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(isStart ? (startTime ?? DateTime.now()) : (endTime ?? DateTime.now())),
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

    // Make sure participants is always a list
    participants = participants ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFEF4444), // BACKGROUND MERAH
      appBar: AppBar(
        title: const Text("Edit Match", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      // Ensure UI adjusts when keyboard appears
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          children: [
            // --- BAGIAN 1: FORM EDIT ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
              ]),
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
                        final name = _venueNameOf(v) ?? 'Unknown';
                        final pk = _venuePkOf(v) ?? '';
                        return DropdownMenuItem<String>(
                          value: pk,
                          child: Text(name, overflow: TextOverflow.ellipsis),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => selectedVenueId = val),
                      validator: (val) => (val == null || val.isEmpty) ? "Wajib diisi" : null,
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
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
              ]),
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
                    // constrain participants list height so it doesn't force overflow
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: min(400, MediaQuery.of(context).size.height * 0.45),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemCount: participants.length,
                        itemBuilder: (context, index) {
                          final p = participants[index];
                          final pId = (p is Map && p['id'] != null) ? p['id'] as int : 0;

                          return Card(
                            color: Colors.grey[50],
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(p['full_name'] ?? p['name'] ?? '-', style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text(p['phone'] ?? '-'),
                              trailing: IconButton(
                                icon: const Icon(Icons.close, color: Colors.red),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text("Kick User?"),
                                      content: Text("Yakin ingin mengeluarkan ${p['full_name'] ?? p['name'] ?? '-'}?"),
                                      actions: [
                                        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Batal")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                              kickParticipant(pId, p['full_name'] ?? p['name'] ?? '');
                                            },
                                            child: const Text("Kick", style: TextStyle(color: Colors.red))),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
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