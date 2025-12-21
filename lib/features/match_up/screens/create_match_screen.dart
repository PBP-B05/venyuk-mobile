import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

class CreateMatchScreen extends StatefulWidget {
  const CreateMatchScreen({super.key});

  @override
  State<CreateMatchScreen> createState() => _CreateMatchScreenState();
}

class _CreateMatchScreenState extends State<CreateMatchScreen> {
  final _formKey = GlobalKey<FormState>();

  // --- State Data ---
  List<Map<String, dynamic>> _venues = [];
  bool _isLoadingVenues = true;
  
  // Input User
  String? _selectedVenueId; // <--- UBAH JADI STRING (Untuk support UUID)
  int _slotTotal = 0;
  DateTime? _startDate;
  TimeOfDay? _startTime;
  DateTime? _endDate;
  TimeOfDay? _endTime;
  String _difficulty = 'beginner'; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchVenues();
    });
  }

  Future<void> _fetchVenues() async {
    final request = context.read<CookieRequest>();
    String url = 'http://localhost:8000/json/';

    // Jika aplikasi berjalan di Android emulator, ganti localhost -> 10.0.2.2
    try {
      if (!kIsWeb && Platform.isAndroid) {
        url = url.replaceFirst('localhost', '10.0.2.2');
      }
    } catch (_) {
      // jika import dart:io gagal di web, sudah di-handle oleh kIsWeb
    }

    try {
      final response = await request.get(url);

      // Debug: cetak response untuk melihat bentuknya
      debugPrint('Fetch venues response: $response');

      List<Map<String, dynamic>> parsed = [];

      if (response is List) {
        parsed = List<Map<String, dynamic>>.from(response);
      } else if (response is Map) {
        if (response['results'] is List) {
          parsed = List<Map<String, dynamic>>.from(response['results']);
        } else if (response['venues'] is List) {
          parsed = List<Map<String, dynamic>>.from(response['venues']);
        } else {
          // jika server mengembalikan map tunggal / object, coba konversi ke list satu elemen
          parsed = [Map<String, dynamic>.from(response)];
        }
      } else {
        throw Exception('Unexpected response type: ${response.runtimeType}');
      }

      if (mounted) {
        setState(() {
          _venues = parsed;
          _isLoadingVenues = false;
        });
      }
    } catch (e, st) {
      debugPrint('Error fetching venues: $e\n$st');
      if (mounted) {
        setState(() {
          _venues = [];
          _isLoadingVenues = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil venue: $e')),
        );
      }
    }
  }

  Future<void> _submitForm(CookieRequest request) async {
    if (_formKey.currentState!.validate()) {
      if (_startDate == null || _startTime == null || _endDate == null || _endTime == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Lengkapi waktu mulai dan selesai!")));
        return;
      }

      final startDt = DateTime(_startDate!.year, _startDate!.month, _startDate!.day, _startTime!.hour, _startTime!.minute);
      final endDt = DateTime(_endDate!.year, _endDate!.month, _endDate!.day, _endTime!.hour, _endTime!.minute);

      if (startDt.isBefore(DateTime.now())) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Waktu mulai tidak boleh di masa lalu.")));
         return;
      }
      if (endDt.isBefore(startDt) || endDt.isAtSameMomentAs(startDt)) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Waktu selesai harus setelah waktu mulai.")));
         return;
      }

      const String url = "http://localhost:8000/match_up/create-match/";
      
      try {
        final response = await request.postJson(
          url, 
          jsonEncode({
            'venue': _selectedVenueId, // Ini sekarang mengirim String UUID
            'slot_total': _slotTotal,
            'start_time': startDt.toIso8601String(),
            'end_time': endDt.toIso8601String(),
            'difficulty_level': _difficulty,
          }),
        );

        if (mounted) {
          if (response['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Match berhasil dibuat!")));
            Navigator.pop(context); 
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(response['message'] ?? "Gagal membuat match."),
              backgroundColor: Colors.red,
            ));
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error koneksi: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();
    final Color primaryRed = const Color(0xFFEF4444);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Buat Match Baru", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: primaryRed,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. VENUE DROPDOWN (Updated for UUID)
              const Text("Pilih Venue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              
              _isLoadingVenues 
                  ? const Center(child: LinearProgressIndicator()) 
                  : _venues.isEmpty 
                      ? const Text("Gagal mengambil data venue.", style: TextStyle(color: Colors.red))
                      : DropdownButtonFormField<String>( // <--- TIPE UBAH JADI STRING
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                          ),
                          hint: const Text("Pilih lokasi venue"),
                          items: _venues.map((v) {
                            // Parsing ID sebagai String (UUID)
                            String id;
                            String name;
                            
                            if (v.containsKey('pk')) {
                              id = v['pk'].toString(); // <--- toString() PENTING
                              if (v['fields'] != null && v['fields']['name'] != null) {
                                name = v['fields']['name'];
                              } else {
                                name = v['name'] ?? "Venue";
                              }
                            } else {
                              id = v['id'].toString(); // <--- toString() PENTING
                              name = v['name'] ?? "Unknown Venue";
                            }
                            
                            return DropdownMenuItem<String>( // <--- TIPE UBAH JADI STRING
                              value: id,
                              child: Text(name),
                            );
                          }).toList(),
                          onChanged: (val) => setState(() => _selectedVenueId = val),
                          validator: (val) => val == null ? "Venue harus dipilih" : null,
                        ),
              
              const SizedBox(height: 20),

              // 2. SLOT TOTAL
              const Text("Total Slot Pemain", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              TextFormField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: "Contoh: 10",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                onChanged: (val) => _slotTotal = int.tryParse(val) ?? 0,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Wajib diisi";
                  if (int.tryParse(val) == null) return "Harus angka";
                  return null;
                },
              ),
              
              const SizedBox(height: 20),

              // 3. START TIME
              const Text("Waktu Mulai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_startDate == null ? "Tanggal" : DateFormat('dd-MM-yyyy').format(_startDate!)),
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                        if (picked != null) setState(() => _startDate = picked);
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_startTime == null ? "Jam" : _startTime!.format(context)),
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (picked != null) setState(() => _startTime = picked);
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 4. END TIME
              const Text("Waktu Selesai", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(_endDate == null ? "Tanggal" : DateFormat('dd-MM-yyyy').format(_endDate!)),
                      onPressed: () async {
                        final picked = await showDatePicker(context: context, initialDate: _startDate ?? DateTime.now(), firstDate: DateTime.now(), lastDate: DateTime(2030));
                        if (picked != null) setState(() => _endDate = picked);
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.access_time),
                      label: Text(_endTime == null ? "Jam" : _endTime!.format(context)),
                      onPressed: () async {
                        final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                        if (picked != null) setState(() => _endTime = picked);
                      },
                      style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 5. DIFFICULTY
              const Text("Tingkat Kesulitan", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _difficulty,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
                items: ['beginner', 'intermediate', 'advanced'].map((lvl) {
                  return DropdownMenuItem(value: lvl, child: Text(lvl[0].toUpperCase() + lvl.substring(1)));
                }).toList(),
                onChanged: (val) => setState(() => _difficulty = val!),
              ),
              
              const SizedBox(height: 40),

              // 6. SUBMIT BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _submitForm(request),
                  child: const Text("Buat Match", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}