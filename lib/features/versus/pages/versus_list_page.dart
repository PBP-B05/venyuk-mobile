import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/versus_model.dart';
import 'versus_form_page.dart';
import 'versus_detail_page.dart';
import 'community_list_page.dart';

/// Base URL backend
const String _webBase = 'http://127.0.0.1:8000';
const String _emulatorBase = 'http://10.0.2.2:8000';
String get baseUrl => kIsWeb ? _webBase : _emulatorBase;

/// Warna-warna utama agar konsisten dengan web
const Color _bgColor = Color(0xFFF5F7FB); // background halaman
const Color _accentRed = Color(0xFFD84040); // tombol merah
const Color _cardBg = Colors.white;

class VersusListPage extends StatefulWidget {
  const VersusListPage({Key? key}) : super(key: key);

  @override
  State<VersusListPage> createState() => _VersusListPageState();
}

class _VersusListPageState extends State<VersusListPage> {
  late Future<List<Challenge>> _futureChallenges;
  String? _selectedSport; // null = All sports
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _futureChallenges = _fetchChallenges();
  }

  Future<List<Challenge>> _fetchChallenges() async {
    setState(() {
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('$baseUrl/versus/api/challenges/').replace(
        queryParameters: _selectedSport != null && _selectedSport!.isNotEmpty
            ? {'sport': _selectedSport}
            : null,
      );

      final response = await http.get(uri);

      if (response.statusCode != 200) {
        throw Exception(
            'Server error: ${response.statusCode} ${response.reasonPhrase}');
      }

      final List<dynamic> data = jsonDecode(response.body);
      return data.map((e) => Challenge.fromJson(e)).toList();
    } catch (e) {
      setState(() {
        _errorMessage = 'Gagal memuat data.\n$e';
      });
      rethrow;
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _futureChallenges = _fetchChallenges();
    });
  }

  void _openCreateForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VersusFormPage()),
    );

    if (created == true) {
      _refresh();
    }
  }

  void _openCommunityList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityListPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: CustomScrollView(
            slivers: [
              // “App bar” ala card putih seperti di web
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Banner / Hero tipis (tanpa gambar dulu)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'VERSUS',
                          style: TextStyle(
                            fontSize: 24,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                  color: Colors.black38,
                                  blurRadius: 8,
                                  offset: Offset(0, 2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: _cardBg,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'VERSUS',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Match antar komunitas olahraga. '
                              'Cari, buat, dan join challenge sebagai community.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Filter + tombol-tombol
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField<String>(
                                        value: _selectedSport,
                                        decoration: const InputDecoration(
                                          labelText: 'Filter olahraga',
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                              Radius.circular(999),
                                            ),
                                          ),
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 10,
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: null,
                                            child: Text('All Sports'),
                                          ),
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
                                        onChanged: (value) {
                                          setState(() {
                                            _selectedSport = value;
                                            _futureChallenges =
                                                _fetchChallenges();
                                          });
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      onPressed: _refresh,
                                      icon: const Icon(Icons.refresh),
                                      tooltip: 'Reload',
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    OutlinedButton(
                                      onPressed: _openCommunityList,
                                      style: OutlinedButton.styleFrom(
                                        shape: const StadiumBorder(),
                                        side: const BorderSide(
                                          color: Colors.grey,
                                        ),
                                      ),
                                      child: const Text('Communities'),
                                    ),
                                    ElevatedButton(
                                      onPressed: _openCreateForm,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _accentRed,
                                        foregroundColor: Colors.white,
                                        shape: const StadiumBorder(),
                                      ),
                                      child: const Text('+ Create VERSUS'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // List atau state lain
              SliverFillRemaining(
                hasScrollBody: true,
                child: FutureBuilder<List<Challenge>>(
                  future: _futureChallenges,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(_accentRed),
                        ),
                      );
                    }

                    if (snapshot.hasError || _errorMessage != null) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24.0,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '⚠️',
                                style: TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _errorMessage ??
                                    'Terjadi kesalahan: ${snapshot.error}',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    final challenges = snapshot.data ?? [];
                    if (challenges.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '🕳️',
                                style: TextStyle(fontSize: 40),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Belum ada Versus',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Coba ubah filter atau buat Versus baru sekarang.',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _openCreateForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _accentRed,
                                  foregroundColor: Colors.white,
                                  shape: const StadiumBorder(),
                                ),
                                child: const Text('+ Create VERSUS'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      itemCount: challenges.length,
                      itemBuilder: (context, index) {
                        final ch = challenges[index];
                        return _VersusCard(
                          challenge: ch,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    VersusDetailPage(challengeId: ch.id),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VersusCard extends StatelessWidget {
  final Challenge challenge;
  final VoidCallback onTap;

  const _VersusCard({
    Key? key,
    required this.challenge,
    required this.onTap,
  }) : super(key: key);

  String _formatDate(DateTime? dt) {
    if (dt == null) return '-';

    return '${dt.day.toString().padLeft(2, '0')}-'
        '${dt.month.toString().padLeft(2, '0')}-'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final venue = challenge.displayVenueName.isNotEmpty
        ? challenge.displayVenueName
        : (challenge.venueName ?? '-');

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: _cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lingkaran kecil sebagai “ikon” sport
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFF5F5F5),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      challenge.sportLabel.isNotEmpty
                          ? challenge.sportLabel[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${challenge.sportLabel} • ${challenge.matchCategoryLabel}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          challenge.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Host: ${challenge.hostName ?? '-'}',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: Colors.grey.shade100,
                    ),
                    child: Text(
                      challenge.statusLabel,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // info rows
              _infoRow('🗓️', _formatDate(challenge.startAt)),
              const SizedBox(height: 4),
              _infoRow('📍', venue),
              const SizedBox(height: 4),
              _infoRow(
                '💲',
                (challenge.costPerPerson ?? 0) > 0
                    ? 'Rp ${(challenge.costPerPerson ?? 0).toStringAsFixed(0)} / orang'
                    : 'Gratis',
              ),
              if ((challenge.prizePool ?? 0) > 0) ...[
                const SizedBox(height: 4),
                _infoRow(
                  '🏆',
                  'Prize Pool: Rp ${(challenge.prizePool ?? 0).toStringAsFixed(0)}',
                ),
              ],
              const SizedBox(height: 4),
              _infoRow(
                '👥',
                '${challenge.playersJoined}/${challenge.maxPlayers} communities joined',
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Lihat detail →',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: _accentRed,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String emoji, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(emoji),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 12, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
