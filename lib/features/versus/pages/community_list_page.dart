// lib/features/versus/pages/community_list_page.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import 'community_detail_page.dart';
import 'community_form_page.dart';

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  late Future<CommunityOverview> _future;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  void _refresh() {
    final request = context.read<CookieRequest>();
    _future = CommunityOverview.fetch(request);
  }

  Future<void> _handleCreate() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CommunityFormPage()),
    );
    if (result == true) {
      setState(_refresh);
    }
  }

  Future<void> _handleLeave() async {
    final request = context.read<CookieRequest>();
    try {
      final resp = await CommunityOverview.leave(request);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Berhasil leave community.')),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        setState(_refresh);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal leave: $e')),
      );
    }
  }

  Future<void> _handleJoin(int id) async {
    final request = context.read<CookieRequest>();
    try {
      final resp = await CommunityOverview.join(request, id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Berhasil join community.')),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        setState(_refresh);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal join: $e')),
      );
    }
  }

  Future<void> _handleDelete(int id) async {
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
      final resp = await CommunityOverview.delete(request, id);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Community dihapus.')),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        setState(_refresh);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal hapus: $e')),
      );
    }
  }

  Future<void> _openDetail(int id) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CommunityDetailPage(id: id)),
    );

    if (result == true) {
      setState(_refresh);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1FF),
        elevation: 0,
        title: const Text('Communities'),
        actions: [
          IconButton(
            onPressed: () => setState(_refresh),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _handleCreate,
        backgroundColor: const Color(0xFFD84040),
        icon: const Icon(Icons.add),
        label: const Text('Create'),
      ),
      body: FutureBuilder<CommunityOverview>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          final data = snapshot.data!;
          final myCurrent = data.myCurrent;
          final communities = data.communities;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // ====== MY CURRENT COMMUNITY ======
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: myCurrent == null
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Current Community',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Kamu belum join / punya community.'),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: _handleCreate,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD84040),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                ),
                                child: const Text('Buat Community'),
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'My Current Community',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              myCurrent.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text('Sport: ${myCurrent.primarySportLabel}'),
                            Text('Owner: ${myCurrent.ownerUsername}'),
                            Text('Members: ${myCurrent.totalMembers}'),
                            const SizedBox(height: 14),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _openDetail(myCurrent.id),
                                    child: const Text('Detail'),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _handleLeave,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          const Color(0xFFD84040),
                                    ),
                                    child: const Text('Leave'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // ====== ALL COMMUNITIES ======
              const Text(
                'All Communities',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 10),

              ...communities.map((c) {
                final isMy = myCurrent != null && c.id == myCurrent.id;
                final canJoin = !c.isOwner && !c.isMember && !isMy;

                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    onTap: () => _openDetail(c.id),
                    title: Text(
                      c.name + (isMy ? ' (My)' : ''),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    subtitle: Text(
                      '${c.primarySportLabel} • ${c.totalMembers} members',
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (c.isOwner) ...[
                          IconButton(
                            tooltip: 'Delete',
                            onPressed: () => _handleDelete(c.id),
                            icon: const Icon(Icons.delete_outline),
                          ),
                        ],
                        if (canJoin)
                          ElevatedButton(
                            onPressed: () => _handleJoin(c.id),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD84040),
                            ),
                            child: const Text('Join'),
                          )
                        else
                          const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}