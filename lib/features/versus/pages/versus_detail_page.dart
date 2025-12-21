import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/versus_model.dart';
import '../services/versus_api.dart' as api;

class VersusDetailPage extends StatefulWidget {
  final int challengeId;
  const VersusDetailPage({super.key, required this.challengeId});

  @override
  State<VersusDetailPage> createState() => _VersusDetailPageState();
}

class _VersusDetailPageState extends State<VersusDetailPage> {
  static const Color kPrimary = Color(0xFFD84040);

  late Future<Challenge> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<Challenge> _fetch() async {
    final request = context.read<CookieRequest>();
    final resp = await api.VersusApi.fetchChallengeDetail(request, widget.challengeId);
    return Challenge.fromJson(resp as Map<String, dynamic>);
  }

  Future<void> _join() async {
    final request = context.read<CookieRequest>();
    final resp = await api.VersusApi.joinChallenge(request, widget.challengeId);

    final msg = (resp['message'] ?? resp['detail'] ?? resp['error'] ?? 'Request berhasil diproses').toString();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

    setState(() => _future = _fetch());
  }

  String _formatDateId(String? iso) {
    if (iso == null || iso.trim().isEmpty) return '-';
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
        'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
      ];
      final m = months[dt.month - 1];
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $m ${dt.year} • $hh:$mm';
    } catch (_) {
      return iso;
    }
  }

  String _rupiah(dynamic x) {
    final n = int.tryParse(x?.toString() ?? '') ?? 0;
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      final idxFromEnd = s.length - i;
      buf.write(s[i]);
      if (idxFromEnd > 1 && idxFromEnd % 3 == 1) buf.write('.');
    }
    return buf.toString();
  }

  Widget _infoRow({required String emoji, required String text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 22, child: Text(emoji)),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        title: const Text('Detail Matchup'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: FutureBuilder<Challenge>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: Text('Gagal memuat detail.'));
          }

          final ch = snap.data!;
          final hostText = ch.hostName.trim().isEmpty ? '-' : ch.hostName;

          final dateStr = _formatDateId(ch.startAt);
          final venueLabel = (ch.displayVenueName.trim().isNotEmpty) ? ch.displayVenueName : '-';

          final cost = ch.costPerPerson;
          final costLabel = (cost > 0) ? 'Rp ${_rupiah(cost)} / orang' : 'Gratis';

          final prize = ch.prizePool;
          final prizeLabel = (prize > 0) ? 'Prize Pool: Rp ${_rupiah(prize)}' : null;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              // Card utama (mirip web)
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ✅ Judul matchup (besar)
                    Text(
                      ch.title,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 6),

                    // ✅ Hosted by (kecil, di bawah judul)
                    Text(
                      'Hosted by: $hostText',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 10),

                    // badges kecil ala web
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: '${ch.sportLabel} • ${ch.matchCategoryLabel}'),
                        _Chip(text: ch.statusLabel),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // Info rows ala web
                    _infoRow(emoji: '🗓️', text: dateStr),
                    _infoRow(emoji: '📍', text: venueLabel),
                    _infoRow(emoji: '💲', text: costLabel),
                    if (prizeLabel != null) _infoRow(emoji: '🏆', text: prizeLabel),
                    _infoRow(
                      emoji: '👥',
                      text: '${ch.playersJoined}/${ch.maxPlayers} communities joined',
                    ),

                    if (ch.description.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        'Description',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ch.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              height: 1.35,
                            ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Button merah ala web
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: request.loggedIn ? _join : null,
                        style: FilledButton.styleFrom(
                          backgroundColor: kPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                        child: const Text('Join Matchup'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String text;
  const _Chip({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
      ),
    );
  }
}
