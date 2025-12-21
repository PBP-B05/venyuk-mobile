// lib/features/versus/pages/community_detail_page.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import 'community_form_page.dart';

class CommunityDetailPage extends StatefulWidget {
  final int id;

  const CommunityDetailPage({super.key, required this.id});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late Future<Community> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final request = context.read<CookieRequest>();
    _future = CommunityOverview.fetchDetail(request, widget.id);
  }

  Future<void> _handleJoin() async {
    final request = context.read<CookieRequest>();
    try {
      final resp = await CommunityOverview.join(request, widget.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Berhasil join community.')),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        setState(_refresh);
        Navigator.pop(context, true); // refresh list page juga
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal join: $e')),
      );
    }
  }

  Future<void> _handleEdit(Community c) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityFormPage(community: c)),
    );

    if (result == true) {
      setState(_refresh);
      Navigator.pop(context, true); // refresh list page juga
    }
  }

  Future<void> _handleDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Community?'),
        content: const Text('Aksi ini tidak bisa dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (ok != true) return;

    final request = context.read<CookieRequest>();
    try {
      final resp = await CommunityOverview.delete(request, widget.id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Community dihapus.')),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: $e')),
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
        title: const Text('Community Detail'),
      ),
      body: FutureBuilder<Community>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final c = snapshot.data!;
          final isOwner = c.isOwner;
          final isMember = c.isMember;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        c.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Sport: ${c.primarySportLabel}'),
                      Text('Owner: ${c.ownerUsername}'),
                      Text('Members: ${c.totalMembers}'),
                      const SizedBox(height: 12),
                      const Text(
                        'Bio',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 6),
                      Text(c.bio.isEmpty ? '-' : c.bio),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (isOwner) ...[
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _handleEdit(c),
                        child: const Text('Edit'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleDelete,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD84040),
                        ),
                        child: const Text('Delete'),
                      ),
                    ),
                  ],
                ),
              ] else if (!isMember) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _handleJoin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD84040),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('Join Community'),
                  ),
                ),
              ] else ...[
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Kamu sudah tergabung di community ini.',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
