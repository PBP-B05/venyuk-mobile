import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/versus_model.dart';
import '../services/versus_api.dart' as api;
import 'versus_detail_page.dart';
import 'versus_form_page.dart';

class VersusListPage extends StatefulWidget {
  const VersusListPage({super.key});

  @override
  State<VersusListPage> createState() => _VersusListPageState();
}

class _VersusListPageState extends State<VersusListPage> {
  late Future<List<Challenge>> _future;

  String _sportFilter = "";

  static const Color kPrimary = Color(0xFFD84040);
  static const Color kBg = Color(0xFFF6F7FB);

  static const List<Map<String, String>> _sportOptions = [
    {"value": "", "label": "All Sports"},
    {"value": "sepak bola", "label": "Sepak Bola"},
    {"value": "futsal", "label": "Futsal"},
    {"value": "mini soccer", "label": "Mini Soccer"},
    {"value": "basketball", "label": "Basketball"},
    {"value": "tennis", "label": "Tennis"},
    {"value": "badminton", "label": "Badminton"},
    {"value": "padel", "label": "Padel"},
    {"value": "pickle ball", "label": "Pickle Ball"},
    {"value": "squash", "label": "Squash"},
    {"value": "voli", "label": "Voli"},
    {"value": "biliard", "label": "Biliard"},
    {"value": "golf", "label": "Golf"},
    {"value": "shooting", "label": "Shooting"},
    {"value": "tennis meja", "label": "Tennis Meja"},
  ];

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<List<Challenge>> _fetch() async {
    final request = context.read<CookieRequest>();
    final resp = await api.VersusApi.fetchChallenges(request);

    if (resp is List) {
      return resp
          .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    if (resp is Map && resp['data'] is List) {
      return (resp['data'] as List)
          .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return [];
  }

  void _refresh() {
    setState(() => _future = _fetch());
  }

  List<Challenge> _applyFilter(List<Challenge> data) {
    final f = _sportFilter.trim().toLowerCase();
    if (f.isEmpty) return data;
    return data.where((c) => c.sport.toLowerCase() == f).toList();
  }

  Future<void> _goDetail(int id) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => VersusDetailPage(challengeId: id)),
    );
    _refresh();
  }

  Future<void> _goCreate() async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const VersusFormPage()),
    );
    if (ok == true) _refresh();
  }

  Future<void> _joinChallenge(Challenge ch) async {
    final request = context.read<CookieRequest>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Join Matchup'),
        content: const Text('Yakin mau join matchup ini sebagai community kamu?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final resp = await api.VersusApi.joinChallenge(request, ch.id);
      final msg =
          (resp['message'] ?? resp['detail'] ?? 'Request berhasil diproses')
              .toString();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      _refresh();
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal join. Coba lagi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Versus'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        onPressed: request.loggedIn ? _goCreate : null,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Challenge>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return _ErrorState(onRetry: _refresh);
          }

          final data = _applyFilter(snapshot.data ?? []);

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                sliver: SliverToBoxAdapter(
                  child: _HeaderCard(
                    sportFilter: _sportFilter,
                    sportOptions: _sportOptions,
                    onChangedSport: (v) => setState(() => _sportFilter = v ?? ""),
                    onApply: _refresh,
                  ),
                ),
              ),

              if (data.isEmpty)
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: _EmptyStateCard(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        if (i.isOdd) return const SizedBox(height: 12);

                        final idx = i ~/ 2;
                        final ch = data[idx];

                        return _VersusCard(
                          ch: ch,
                          onTapDetail: () => _goDetail(ch.id),
                          onJoin: request.loggedIn &&
                                  ch.status.toLowerCase() == 'open'
                              ? () => _joinChallenge(ch)
                              : null,
                        );
                      },
                      childCount: data.length * 2 - 1,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String sportFilter;
  final List<Map<String, String>> sportOptions;
  final ValueChanged<String?> onChangedSport;
  final VoidCallback onApply;

  static const Color kPrimary = Color(0xFFD84040);

  const _HeaderCard({
    required this.sportFilter,
    required this.sportOptions,
    required this.onChangedSport,
    required this.onApply,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
          Text(
            'VERSUS',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Match antar komunitas olahraga. Cari, buat, dan join challenge sebagai community.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black54,
                ),
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _SportDropdown(
                  value: sportFilter,
                  options: sportOptions,
                  onChanged: onChangedSport,
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: onApply,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  side: const BorderSide(color: Color(0xFFDDDDDD)),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                child: const Text('Apply'),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: const [
              _Chip(text: 'Filter by sport'),
              _Chip(text: 'Tap card to see detail'),
            ],
          ),
        ],
      ),
    );
  }
}

class _SportDropdown extends StatelessWidget {
  final String value;
  final List<Map<String, String>> options;
  final ValueChanged<String?> onChanged;

  const _SportDropdown({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color(0xFFF1F3F6), // mirip chip bg di detail
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(999),
          borderSide: BorderSide.none,
        ),
      ),
      items: options
          .map(
            (o) => DropdownMenuItem(
              value: o["value"] ?? "",
              child: Text(o["label"] ?? ""),
            ),
          )
          .toList(),
      onChanged: onChanged,
    );
  }
}

class _VersusCard extends StatelessWidget {
  final Challenge ch;
  final VoidCallback onTapDetail;
  final VoidCallback? onJoin;

  static const Color kPrimary = Color(0xFFD84040);

  const _VersusCard({
    required this.ch,
    required this.onTapDetail,
    required this.onJoin,
  });

  @override
  Widget build(BuildContext context) {
    final venueLabel = (ch.displayVenueName.trim().isNotEmpty)
        ? ch.displayVenueName
        : (ch.venueName.trim().isNotEmpty ? ch.venueName : "-");

    final dateStr = _fmtDate(ch.startAt);

    return Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SportIcon(sport: ch.sport, label: ch.sportLabel),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: onTapDetail,
                      child: Text(
                        ch.title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                            ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Hosted by: ${ch.hostName.trim().isNotEmpty ? ch.hostName : "-"}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black54,
                          ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: '${ch.sportLabel} • ${ch.matchCategoryLabel}'),
                        _Chip(text: ch.statusLabel),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 12),

          _EmojiRow(emoji: '🗓️', text: dateStr),
          _EmojiRow(emoji: '📍', text: venueLabel),
          _EmojiRow(
            emoji: '💲',
            text: (ch.costPerPerson > 0)
                ? 'Rp ${_rupiah(ch.costPerPerson)} / orang'
                : 'Gratis',
          ),
          if (ch.prizePool > 0)
            _EmojiRow(
              emoji: '🏆',
              text: 'Prize Pool: Rp ${_rupiah(ch.prizePool)}',
            ),
          _EmojiRow(
            emoji: '👥',
            text: '${ch.playersJoined}/${ch.maxPlayers} communities joined',
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              TextButton(
                onPressed: onTapDetail,
                style: TextButton.styleFrom(foregroundColor: kPrimary),
                child: const Text('Lihat detail →'),
              ),
              const Spacer(),
              if (ch.status.toLowerCase() == "open")
                FilledButton(
                  onPressed: onJoin,
                  style: FilledButton.styleFrom(
                    backgroundColor: kPrimary,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  child: const Text('Join as Community'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  static String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return "-";
    try {
      final dt = DateTime.parse(iso).toLocal();
      const months = [
        'Januari',
        'Februari',
        'Maret',
        'April',
        'Mei',
        'Juni',
        'Juli',
        'Agustus',
        'September',
        'Oktober',
        'November',
        'Desember'
      ];
      final m = months[dt.month - 1];
      final hh = dt.hour.toString().padLeft(2, '0');
      final mm = dt.minute.toString().padLeft(2, '0');
      return '${dt.day} $m ${dt.year} • $hh:$mm';
    } catch (_) {
      return iso;
    }
  }

  static String _rupiah(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    int count = 0;
    for (int i = s.length - 1; i >= 0; i--) {
      buf.write(s[i]);
      count++;
      if (count % 3 == 0 && i != 0) buf.write('.');
    }
    return buf.toString().split('').reversed.join();
  }
}

class _SportIcon extends StatelessWidget {
  final String sport;
  final String label;

  const _SportIcon({required this.sport, required this.label});

  String _iconAsset(String s) {
    final k = s.toLowerCase().trim();
    const map = {
      "futsal": "futsal.png",
      "sepak bola": "soccer.png",
      "mini soccer": "soccer.png",
      "badminton": "badminton.png",
      "basketball": "basketball.png",
      "voli": "volleyball.png",
      "volleyball": "volleyball.png",
      "tennis": "tennis.png",
    };
    return 'assets/images/sports/${map[k] ?? "default.png"}';
  }

  @override
  Widget build(BuildContext context) {
    final asset = _iconAsset(sport);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        asset,
        width: 48,
        height: 48,
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => Container(
          width: 48,
          height: 48,
          color: Colors.black12,
          child: const Icon(Icons.sports, size: 26),
        ),
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

class _EmojiRow extends StatelessWidget {
  final String emoji;
  final String text;

  const _EmojiRow({required this.emoji, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 22, child: Text(emoji)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFDDDDDD), width: 1),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text('🕳️', style: TextStyle(fontSize: 28)),
              SizedBox(height: 8),
              Text(
                'Belum ada Versus',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              SizedBox(height: 6),
              Text(
                'Coba ubah filter, atau buat Versus baru sekarang.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
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
            border: Border.all(color: const Color(0xFFD84040), width: 1),
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 28)),
              const SizedBox(height: 8),
              const Text(
                'Gagal memuat data.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              const Text(
                'Coba lagi nanti.',
                style: TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 14),
              FilledButton(
                onPressed: onRetry,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
