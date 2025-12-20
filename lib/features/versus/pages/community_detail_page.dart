// lib/features/versus/pages/community_detail_page.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import 'community_form_page.dart';

class CommunityDetailPage extends StatefulWidget {
  final int communityId;

  const CommunityDetailPage({super.key, required this.communityId});

  @override
  State<CommunityDetailPage> createState() => _CommunityDetailPageState();
}

class _CommunityDetailPageState extends State<CommunityDetailPage> {
  late Future<Community> _futureDetail;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futureDetail =
        CommunityOverview.fetchDetail(request, widget.communityId);
  }

  Future<void> _reload() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _futureDetail =
          CommunityOverview.fetchDetail(request, widget.communityId);
    });
  }

  Future<void> _join(Community comm) async {
    final request = context.read<CookieRequest>();
    final resp = await CommunityOverview.join(request, comm.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resp['message'] ?? 'Gagal join community')),
    );
    if (resp['ok'] == true || resp['status'] == 'success') {
      await _reload();
      // beri tahu halaman sebelumnya bahwa ada perubahan
      Navigator.pop(context, true);
    }
  }

  Future<void> _leave() async {
    final request = context.read<CookieRequest>();
    final resp = await CommunityOverview.leave(request);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resp['message'] ?? 'Gagal leave community')),
    );
    if (resp['ok'] == true || resp['status'] == 'success') {
      Navigator.pop(context, true);
    }
  }

  Future<void> _delete(Community comm) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus community'),
        content: Text(
            "Yakin ingin menghapus community '${comm.name}'? Tindakan ini tidak dapat dibatalkan."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: const Color(0xFFD84040),
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final request = context.read<CookieRequest>();
    final resp = await CommunityOverview.delete(request, comm.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(resp['message'] ?? 'Gagal menghapus community')),
    );
    if (resp['ok'] == true || resp['status'] == 'success') {
      Navigator.pop(context, true);
    }
  }

  void _edit(Community comm) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityFormPage(community: comm),
      ),
    );
    if (updated == true) {
      await _reload();
      Navigator.pop(context, true); // beritahu list untuk refresh
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
        future: _futureDetail,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Text(
                'Gagal memuat detail community:\n${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          final comm = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comm.name,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${comm.primarySportLabel} • ${comm.totalMembers} members',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Owner: ${comm.ownerUsername}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Deskripsi',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comm.bio.isEmpty
                          ? 'Belum ada deskripsi.'
                          : comm.bio,
                    ),
                    const SizedBox(height: 24),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (comm.isOwner)
                          ElevatedButton.icon(
                            onPressed: () => _edit(comm),
                            icon: const Icon(Icons.edit),
                            label: const Text('Edit'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4B7BEC),
                            ),
                          ),
                        if (comm.isOwner)
                          ElevatedButton.icon(
                            onPressed: () => _delete(comm),
                            icon: const Icon(Icons.delete),
                            label: const Text('Delete'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD84040),
                            ),
                          ),
                        if (!comm.isOwner && comm.isMember)
                          ElevatedButton.icon(
                            onPressed: _leave,
                            icon: const Icon(Icons.logout),
                            label: const Text('Leave'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD84040),
                            ),
                          ),
                        if (!comm.isMember)
                          ElevatedButton.icon(
                            onPressed: () => _join(comm),
                            icon: const Icon(Icons.group_add),
                            label: const Text('Join'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFD84040),
                            ),
                          ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
