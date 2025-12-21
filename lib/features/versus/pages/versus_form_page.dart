import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../services/versus_api.dart';

class VersusFormPage extends StatefulWidget {
  const VersusFormPage({super.key});

  @override
  State<VersusFormPage> createState() => _VersusFormPageState();
}

class _VersusFormPageState extends State<VersusFormPage> {
  static const Color kPrimary = Color(0xFFD84040);
  static const Color kSoftBg = Color(0xFFFFF4F4); 

  final _formKey = GlobalKey<FormState>();

  final _title = TextEditingController();
  final _startAt = TextEditingController(); // yyyy-MM-ddTHH:mm
  final _venueName = TextEditingController(); 
  final _cost = TextEditingController(text: '0');
  final _prize = TextEditingController(text: '0');
  final _desc = TextEditingController();
  final _poster = TextEditingController();

  String _sport = 'futsal';
  String _category = 'league';
  bool _submitting = false;

  // ===== venue dropdown state =====
  bool _loadingVenues = true;
  String? _venueId; // uuid string
  List<_VenueItem> _venues = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadVenues());
  }

  @override
  void dispose() {
    _title.dispose();
    _startAt.dispose();
    _venueName.dispose();
    _cost.dispose();
    _prize.dispose();
    _desc.dispose();
    _poster.dispose();
    super.dispose();
  }

  Future<void> _loadVenues() async {
    setState(() => _loadingVenues = true);
    final request = context.read<CookieRequest>();

    try {
      final list = await VersusApi.fetchVenues(request);
      final venues = list
          .map((e) => _VenueItem(
                id: (e['id'] ?? '').toString(),
                name: (e['name'] ?? '').toString(),
              ))
          .where((v) => v.id.isNotEmpty && v.name.isNotEmpty)
          .toList();

      if (!mounted) return;
      setState(() {
        _venues = venues;
        _loadingVenues = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _venues = const [];
        _loadingVenues = false;
      });
    }
  }

  String _two(int v) => v.toString().padLeft(2, '0');
  String _formatDt(DateTime dt) =>
      '${dt.year}-${_two(dt.month)}-${_two(dt.day)}T${_two(dt.hour)}:${_two(dt.minute)}';

  Future<void> _pickDateTime() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
      initialDate: now,
    );
    if (d == null) return;

    final t = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now),
    );
    if (t == null) return;

    final dt = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    _startAt.text = _formatDt(dt);
    setState(() {});
  }

  InputDecoration _dec(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: kPrimary, width: 1.5),
      ),
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);
    final request = context.read<CookieRequest>();

    try {
      final resp = await VersusApi.createChallenge(
        request,
        title: _title.text.trim(),
        sport: _sport,
        matchCategory: _category,
        startAt: _startAt.text.trim(),
        venueName: _venueName.text.trim(), // fallback
        venueId: _venueId, 
        costPerPerson: _cost.text.trim(),
        prizePool: _prize.text.trim(),
        description: _desc.text.trim(),
        posterUrl: _poster.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Matchup dibuat')),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal membuat matchup: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canSubmit = !_submitting;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Matchup'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            color: kSoftBg,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                blurRadius: 18,
                color: Colors.black.withOpacity(0.06),
                offset: const Offset(0, 10),
              )
            ],
          ),
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Matchup',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),

                TextFormField(
                  controller: _title,
                  decoration: _dec('Judul'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Judul wajib' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _sport,
                  decoration: _dec('Sport'),
                  items: const [
                    DropdownMenuItem(value: 'futsal', child: Text('Futsal')),
                    DropdownMenuItem(value: 'sepak bola', child: Text('Sepak Bola')),
                    DropdownMenuItem(value: 'basketball', child: Text('Basketball')),
                    DropdownMenuItem(value: 'badminton', child: Text('Badminton')),
                    DropdownMenuItem(value: 'voli', child: Text('Voli')),
                  ],
                  onChanged: (v) => setState(() => _sport = v ?? _sport),
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: _category,
                  decoration: _dec('Match Category'),
                  items: const [
                    DropdownMenuItem(value: 'league', child: Text('League')),
                    DropdownMenuItem(value: 'ro16', child: Text('RO16')),
                    DropdownMenuItem(value: 'quarter_final', child: Text('Quarter Final')),
                    DropdownMenuItem(value: 'semi_final', child: Text('Semi Final')),
                    DropdownMenuItem(value: 'cup_final', child: Text('Cup Final')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _startAt,
                  readOnly: true,
                  decoration: _dec(
                    'Start At (yyyy-MM-ddTHH:mm)',
                    suffixIcon: const Icon(Icons.calendar_month),
                  ),
                  onTap: _pickDateTime,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Waktu wajib' : null,
                ),
                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  value: (_venueId != null && _venueId!.isNotEmpty) ? _venueId : '',
                  isExpanded: true,
                  decoration: _dec(
                    'Venue',
                    suffixIcon: _loadingVenues
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : IconButton(
                            tooltip: 'Refresh venues',
                            onPressed: _loadVenues,
                            icon: const Icon(Icons.refresh),
                          ),
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: '',
                      child: Text('Pilih venue (opsional)'),
                    ),
                    ..._venues.map(
                      (v) => DropdownMenuItem(
                        value: v.id,
                        child: Text(v.name, overflow: TextOverflow.ellipsis),
                      ),
                    ),
                  ],
                  onChanged: _loadingVenues
                      ? null
                      : (val) {
                          final id = (val ?? '').trim();
                          setState(() => _venueId = id.isEmpty ? null : id);

                          if (id.isEmpty) {
                            _venueName.text = '';
                          } else {
                            final picked = _venues.where((x) => x.id == id).toList();
                            _venueName.text = picked.isNotEmpty ? picked.first.name : '';
                          }
                        },
                ),

                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cost,
                        keyboardType: TextInputType.number,
                        decoration: _dec('Cost per person'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _prize,
                        keyboardType: TextInputType.number,
                        decoration: _dec('Prize pool'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _desc,
                  minLines: 3,
                  maxLines: 5,
                  decoration: _dec('Description'),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: _poster,
                  decoration: _dec('Poster URL (opsional)'),
                ),
                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: canSubmit ? _submit : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(999),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(_submitting ? 'Menyimpan...' : 'Buat Matchup'),
                  ),
                ),
                const SizedBox(height: 10),

                Center(
                  child: TextButton(
                    onPressed: canSubmit ? () => Navigator.pop(context, false) : null,
                    style: TextButton.styleFrom(foregroundColor: Colors.deepPurple),
                    child: const Text('Batal'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VenueItem {
  final String id;
  final String name;
  const _VenueItem({required this.id, required this.name});
}
