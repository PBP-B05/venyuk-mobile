// lib/features/versus/pages/community_list_page.dart
import 'package:flutter/foundation.dart';
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
  late Future<CommunityOverview> _futureOverview;

  @override
  void initState() {
    super.initState();
    final request = context.read<CookieRequest>();
    _futureOverview = CommunityOverview.fetch(request);
  }

  Future<void> _reload() async {
    final request = context.read<CookieRequest>();
    setState(() {
      _futureOverview = CommunityOverview.fetch(request);
    });
  }

  Future<void> _leaveCommunity() async {
    final request = context.read<CookieRequest>();
    final resp = await CommunityOverview.leave(request);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(resp['message'] ?? 'Gagal leave community'),
      ),
    );
    if (resp['ok'] == true) {
      await _reload();
    }
  }

  void _openCreateForm() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => const CommunityFormPage(),
      ),
    );
    if (created == true) {
      await _reload();
    }
  }

  void _openDetail(Community comm) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CommunityDetailPage(communityId: comm.id),
      ),
    );
    if (changed == true) {
      await _reload();
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
      ),
      body: RefreshIndicator(
        onRefresh: _reload,
        child: FutureBuilder<CommunityOverview>(
          future: _futureOverview,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 200),
                  Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            final overview = snapshot.data!;
            final myCurrent = overview.myCurrent;
            final communities = overview.communities;

            return ListView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Kartu "Your Community"
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: myCurrent != null
                        ? Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Your Community',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                myCurrent.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '${myCurrent.primarySportLabel} • ${myCurrent.totalMembers} members',
                                style: TextStyle(
                                  color: Colors.grey.shade700,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () => _openDetail(myCurrent),
                                    child: const Text('View Detail'),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: _leaveCommunity,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor:
                                          const Color(0xFFD84040),
                                    ),
                                    child: const Text('Leave'),
                                  ),
                                ],
                              ),
                            ],
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Belum punya community',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Buat community baru atau join dari daftar di bawah.',
                                style: TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: _openCreateForm,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD84040),
                                ),
                                child: const Text('+ Create Community'),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header list
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Semua Communities',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (myCurrent == null)
                      TextButton(
                        onPressed: _openCreateForm,
                        child: const Text('+ Create Community'),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                if (communities.isEmpty)
                  const Text('Belum ada community.')
                else
                  ...communities.map(
                    (c) => Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ListTile(
                        title: Text(c.name),
                        subtitle: Text(
                          '${c.primarySportLabel} • ${c.totalMembers} members',
                        ),
                        onTap: () => _openDetail(c),
                        trailing: Wrap(
                          spacing: 8,
                          children: [
                            OutlinedButton(
                              onPressed: () => _openDetail(c),
                              child: const Text('View'),
                            ),
                            if (myCurrent == null && !c.isMember)
                              ElevatedButton(
                                onPressed: () async {
                                  final request =
                                      context.read<CookieRequest>();
                                  final resp =
                                      await CommunityOverview.join(
                                          request, c.id);
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        resp['message'] ??
                                            'Gagal join community',
                                      ),
                                    ),
                                  );
                                  if (resp['ok'] == true) {
                                    await _reload();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFD84040),
                                ),
                                child: const Text('Join'),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
