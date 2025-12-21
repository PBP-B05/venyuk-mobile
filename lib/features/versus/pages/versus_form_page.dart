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

  String _two(int v) => v.toString().padLeft(2, '0');
  String _formatDt(DateTime dt) => '${dt.year}-${_two(dt.month)}-${_two(dt.day)}T${_two(dt.hour)}:${_two(dt.minute)}';

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
        venueName: _venueName.text.trim(),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Matchup')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Judul'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib' : null,
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: _sport,
                    decoration: const InputDecoration(labelText: 'Sport'),
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
                    decoration: const InputDecoration(labelText: 'Match Category'),
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
                    decoration: const InputDecoration(
                      labelText: 'Start At (yyyy-MM-ddTHH:mm)',
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                    onTap: _pickDateTime,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Waktu wajib' : null,
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _venueName,
                    decoration: const InputDecoration(labelText: 'Venue Name (opsional)'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _cost,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cost per person'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _prize,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Prize pool'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _desc,
                    minLines: 3,
                    maxLines: 5,
                    decoration: const InputDecoration(labelText: 'Description'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _poster,
                    decoration: const InputDecoration(labelText: 'Poster URL (opsional)'),
                  ),
                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      child: Text(_submitting ? 'Menyimpan...' : 'Buat Matchup'),
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
