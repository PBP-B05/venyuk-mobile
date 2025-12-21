import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import '../services/versus_api.dart' as api;
import 'community_form_page.dart';

class CommunityDetailPage extends StatefulWidget {
  final int communityId;
  const CommunityDetailPage({super.key, required this.communityId});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  static const Color kPrimary = Color(0xFFD84040);
  static const Color kBg = Color(0xFFF6F7FB);

  late Future<Community> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<Community> _fetch() async {
    final request = context.read<CookieRequest>();
    final resp =
        await api.VersusApi.fetchCommunityDetail(request, widget.communityId);

    final raw = Map<String, dynamic>.from(resp as Map);
    final commJson = (raw['community'] ?? raw) as Map<String, dynamic>;
    return Community.fromJson(commJson);
  }

  void _refresh() => setState(() => _future = _fetch());

  Future<void> _snack(String msg) async {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _edit(Community c) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => CommunityFormPage(communityId: c.id)),
    );
    if (ok == true) _refresh();
  }

  Future<void> _delete(Community c) async {
    final request = context.read<CookieRequest>();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Community'),
        content: const Text('Yakin mau hapus community ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: kPrimary),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final resp = await api.VersusApi.deleteCommunity(request, c.id);
    await _snack((resp['message'] ?? 'OK').toString());
    if (mounted) Navigator.pop(context, true);
  }

  Future<void> _join(Community c) async {
    final request = context.read<CookieRequest>();
    final resp = await api.VersusApi.joinCommunity(request, c.id);
    await _snack((resp['message'] ?? 'OK').toString());
    _refresh();
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Community Detail'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: FutureBuilder<Community>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          if (!snap.hasData) {
            return const Center(child: Text('Gagal memuat detail community.'));
          }

          final c = snap.data!;

          // label aman
          final name = c.name.trim().isEmpty ? '-' : c.name;
          final sportLabel =
              c.primarySportLabel.trim().isEmpty ? '-' : c.primarySportLabel;
          final owner = c.ownerUsername.trim().isEmpty ? '-' : c.ownerUsername;
          final members = c.totalMembers.toString();

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              // Card utama (mirip VersusDetailPage)
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
                    // ✅ Judul besar
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 10),

                    // ✅ Badges / chips ala web
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _Chip(text: 'Sport: $sportLabel'),
                        _Chip(text: c.isOwner ? 'You are the owner' : 'Community'),
                      ],
                    ),

                    const SizedBox(height: 14),
                    const Divider(height: 1),
                    const SizedBox(height: 12),

                    // ✅ Info rows emoji (konsisten sama VersusDetailPage)
                    _infoRow(emoji: '🏷️', text: 'Primary Sport: $sportLabel'),
                    _infoRow(emoji: '👑', text: 'Owner: $owner'),
                    _infoRow(emoji: '👥', text: 'Members: $members'),

                    if (c.bio.trim().isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(height: 1),
                      const SizedBox(height: 12),
                      Text(
                        'Bio',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        c.bio,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.black87,
                              height: 1.35,
                            ),
                      ),
                    ],

                    const SizedBox(height: 16),

                    // ✅ Actions (owner vs non-owner)
                    if (c.isOwner) ...[
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _edit(c),
                              icon: const Icon(Icons.edit),
                              label: const Text('Edit'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _delete(c),
                              icon: const Icon(Icons.delete),
                              label: const Text('Delete'),
                              style: FilledButton.styleFrom(
                                backgroundColor: kPrimary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(999),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: request.loggedIn ? () => _join(c) : null,
                          style: FilledButton.styleFrom(
                            backgroundColor: kPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                          child: const Text('Join Community'),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
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
