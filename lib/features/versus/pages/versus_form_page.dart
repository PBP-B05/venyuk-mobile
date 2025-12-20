import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/versus_model.dart';

/// Base URL backend
const String _webBase = 'http://127.0.0.1:8000';
const String _emulatorBase = 'http://10.0.2.2:8000';
String get baseUrl => kIsWeb ? _webBase : _emulatorBase;

class VersusFormPage extends StatefulWidget {
  const VersusFormPage({super.key});

  @override
  State<VersusFormPage> createState() => _VersusFormPageState();
}

class _VersusFormPageState extends State<VersusFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _venueNameController = TextEditingController();
  final _costController = TextEditingController(text: '0');
  final _prizeController = TextEditingController(text: '0');
  final _descController = TextEditingController();
  final _posterController = TextEditingController();

  String _selectedSport = 'futsal';
  String _selectedCategory = 'league';
  DateTime? _startAt;
  bool _submitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _venueNameController.dispose();
    _costController.dispose();
    _prizeController.dispose();
    _descController.dispose();
    _posterController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _startAt ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: _startAt != null
          ? TimeOfDay.fromDateTime(_startAt!)
          : const TimeOfDay(hour: 20, minute: 0),
    );
    if (time == null) return;

    setState(() {
      _startAt = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  String _formatDateTime(DateTime? dt) {
    if (dt == null) return 'Pilih waktu mulai';
    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startAt == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih waktu mulai.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      final uri = Uri.parse('$baseUrl/versus/api/challenges/create/');

      final body = jsonEncode({
        'title': _titleController.text.trim(),
        'sport': _selectedSport,
        'match_category': _selectedCategory,
        'start_at': _startAt!.toIso8601String(),
        // ⬇️ hanya kirim venue_name, TIDAK ada field "venue"
        'venue_name': _venueNameController.text.trim(),
        'cost_per_person': int.tryParse(_costController.text) ?? 0,
        'prize_pool': int.tryParse(_prizeController.text) ?? 0,
        'description': _descController.text.trim(),
        'poster_url': _posterController.text.trim(),
      });

      final resp = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (resp.statusCode != 200) {
        throw Exception(
            'Server error: ${resp.statusCode} ${resp.reasonPhrase}');
      }

      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      if (data['ok'] != true) {
        throw Exception(data['message'] ?? 'Gagal membuat matchup');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message'] ?? 'Matchup berhasil dibuat.'),
        ),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan matchup: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1FF),
        elevation: 0,
        title: const Text('Buat Matchup'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Match Title',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Contoh: Friendly Match Minggu Malam',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Kategori',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    items: const [
                      DropdownMenuItem(
                        value: 'league',
                        child: Text('League'),
                      ),
                      DropdownMenuItem(
                        value: 'friendly',
                        child: Text('Friendly'),
                      ),
                      DropdownMenuItem(
                        value: 'knockout',
                        child: Text('Knockout'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedCategory = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Olahraga',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    value: _selectedSport,
                    items: const [
                      DropdownMenuItem(
                        value: 'futsal',
                        child: Text('Futsal'),
                      ),
                      DropdownMenuItem(
                        value: 'sepak bola',
                        child: Text('Sepak Bola'),
                      ),
                      DropdownMenuItem(
                        value: 'basketball',
                        child: Text('Basketball'),
                      ),
                      DropdownMenuItem(
                        value: 'badminton',
                        child: Text('Badminton'),
                      ),
                      DropdownMenuItem(
                        value: 'voli',
                        child: Text('Voli'),
                      ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _selectedSport = v);
                    },
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Waktu mulai',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  InkWell(
                    onTap: _pickDateTime,
                    borderRadius: BorderRadius.circular(8),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 18),
                          const SizedBox(width: 8),
                          Text(_formatDateTime(_startAt)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ⬇️ Venue kembali ke TextFormField biasa
                  const Text(
                    'Venue',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _venueNameController,
                    decoration: const InputDecoration(
                      hintText: 'Nama venue (mis. Active Zone)',
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Wajib diisi' : null,
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Harga (per orang)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _costController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0 jika gratis',
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Prize Pool (Rp)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _prizeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      hintText: '0 jika tidak ada hadiah',
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Deskripsi singkat match (opsional)',
                    ),
                  ),
                  const SizedBox(height: 16),

                  const Text(
                    'Poster Image (URL)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  TextFormField(
                    controller: _posterController,
                    decoration: const InputDecoration(
                      hintText: 'https://contoh.com/poster.jpg (opsional)',
                    ),
                  ),
                  const SizedBox(height: 24),

                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84040),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                      ),
                      child: _submitting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text(
                              'Buat Matchup',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
