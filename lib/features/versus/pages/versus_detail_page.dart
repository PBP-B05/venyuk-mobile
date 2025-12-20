import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/versus_model.dart';

/// Base URL backend
/// - Web (Chrome / DevicePreview): pakai 127.0.0.1
/// - Emulator / device: pakai 10.0.2.2
const String _webBase = 'http://127.0.0.1:8000';
const String _emulatorBase = 'http://10.0.2.2:8000';

String get baseUrl => kIsWeb ? _webBase : _emulatorBase;

class VersusDetailPage extends StatefulWidget {
  final int challengeId;

  const VersusDetailPage({
    Key? key,
    required this.challengeId,
  }) : super(key: key);

  @override
  State<VersusDetailPage> createState() => _VersusDetailPageState();
}

class _VersusDetailPageState extends State<VersusDetailPage> {
  late Future<Challenge> _futureChallenge;

  @override
  void initState() {
    super.initState();
    _futureChallenge = _fetchDetail();
  }

  Future<Challenge> _fetchDetail() async {
    final uri =
        Uri.parse('$baseUrl/versus/api/challenges/${widget.challengeId}/');

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception(
          'Gagal memuat detail (status ${response.statusCode}).');
    }

    final Map<String, dynamic> data = jsonDecode(response.body);
    return Challenge.fromJson(data);
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';

    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _joinChallenge(Challenge ch) async {
    try {
      final uri =
          Uri.parse('$baseUrl/versus/api/challenges/${ch.id}/join/');

      // Body boleh kosong, API akan pakai Public Community
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({}),
      );

      if (response.statusCode != 200) {
        // Kalau error, backend kirim JSON {"message": "..."}
        String msg = 'Gagal join matchup.';
        try {
          final Map<String, dynamic> body = jsonDecode(response.body);
          if (body['message'] is String) {
            msg = body['message'];
          }
        } catch (_) {}
        throw Exception(msg);
      }

      final Map<String, dynamic> body = jsonDecode(response.body);
      final String msg = body['message']?.toString() ??
          'Berhasil join matchup.';

      // refresh detail (players_joined, status, dll)
      setState(() {
        _futureChallenge = _fetchDetail();
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menghubungi server: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1FF),
        elevation: 0,
        title: const Text('Detail Matchup'),
      ),
      body: FutureBuilder<Challenge>(
        future: _futureChallenge,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Gagal memuat detail.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final ch = snapshot.data!;
          final canJoin = ch.statusLabel.toLowerCase() == 'open';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Judul & status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        ch.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: Colors.grey.shade200,
                      ),
                      child: Text(
                        ch.statusLabel,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  '${ch.sportLabel} • ${ch.matchCategoryLabel}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 16),

                // Waktu & venue
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      _formatDate(ch.startAt),
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                if (ch.displayVenueName.isNotEmpty)
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          ch.displayVenueName,
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.people, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      '${ch.playersJoined}/${ch.maxPlayers} communities',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Host: ${ch.hostName.isEmpty ? "-" : ch.hostName}',
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Opponent: ${ch.hasOpponent ? ch.opponentName : "-"}',
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 16),
                if (ch.costPerPerson > 0 || ch.prizePool > 0)
                  Row(
                    children: [
                      if (ch.costPerPerson > 0) ...[
                        const Icon(Icons.payments, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'Biaya/orang: Rp${ch.costPerPerson.toStringAsFixed(0)}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ],
                  ),
                if (ch.prizePool > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.emoji_events, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'Prize pool: Rp${ch.prizePool.toStringAsFixed(0)}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],

                const SizedBox(height: 24),
                const Text(
                  'Deskripsi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  ch.description?.isNotEmpty == true
                      ? ch.description!
                      : 'Tidak ada deskripsi.',
                  style: const TextStyle(fontSize: 14),
                ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: FutureBuilder<Challenge>(
        future: _futureChallenge,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();

          final ch = snapshot.data!;
          final canJoin = ch.statusLabel.toLowerCase() == 'open';

          return SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ElevatedButton(
                onPressed: canJoin ? () => _joinChallenge(ch) : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  canJoin ? 'Join Matchup' : 'Matchup tidak open',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
