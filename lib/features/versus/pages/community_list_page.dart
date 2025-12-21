import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import '../services/versus_api.dart' as api;
import 'community_detail_page.dart';
import 'community_form_page.dart';

class CommunityListPage extends StatefulWidget {
  const CommunityListPage({super.key});

  @override
  State<CommunityListPage> createState() => _CommunityListPageState();
}

class _CommunityListPageState extends State<CommunityListPage> {
  static const Color kPrimary = Color(0xFFD84040);
  static const Color kBg = Color(0xFFF6F7FB);

  late Future<CommunityOverview> _future;

  @override
  void initState() {
    super.initState();
    _future = _fetch();
  }

  Future<CommunityOverview> _fetch() async {
    final request = context.read<CookieRequest>();
    final resp = await api.VersusApi.fetchCommunities(request);
    return CommunityOverview.fromJson(resp);
  }

  void _refresh() => setState(() => _future = _fetch());

  Future<void> _snackFromResp(Map<String, dynamic> resp) async {
    final msg = (resp['message'] ?? resp['detail'] ?? 'OK').toString();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<bool> _confirm(String title, String message) async {
    return (await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: kPrimary),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Ya'),
              ),
            ],
          ),
        )) ??
        false;
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
      ),
    );
  }

  Widget _chip(String text) {
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

  Widget _communityCard({
    required dynamic c,
    required bool loggedIn,
    required VoidCallback onTap,
    required Widget trailing,
    bool emphasize = false,
  }) {
    final String name = (c?.name ?? '').toString();
    final String sportLabel = (c?.primarySportLabel ?? '').toString();
    final int members = (c?.totalMembers ?? 0) as int;
    final bool isOwner = (c?.isOwner ?? false) as bool;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: emphasize ? Border.all(color: kPrimary.withOpacity(0.35), width: 1) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: kPrimary.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: kPrimary),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            height: 1.1,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (sportLabel.trim().isNotEmpty) _chip(sportLabel),
                        _chip('Members: $members'),
                        if (isOwner) _chip('Owner'),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),
              Opacity(opacity: loggedIn ? 1 : 0.6, child: trailing),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: const Text('Communities'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        actions: [
          IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: kPrimary,
        foregroundColor: Colors.white,
        onPressed: request.loggedIn
            ? () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(builder: (_) => const CommunityFormPage()),
                );
                if (ok == true) _refresh();
              }
            : null,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<CommunityOverview>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snap.hasData) {
            return const Center(child: Text('Gagal memuat communities.'));
          }

          final overview = snap.data!;
          final my = overview.myCurrent;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            children: [
              if (my != null) ...[
                _sectionTitle('My Community'),

                _communityCard(
                  c: my,
                  loggedIn: request.loggedIn,
                  emphasize: true,
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => CommunityDetailPage(communityId: my.id),
                      ),
                    );
                    _refresh();
                  },
                  trailing: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: kPrimary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    onPressed: request.loggedIn
                        ? () async {
                            final ok = await _confirm(
                              'Leave community?',
                              'Kamu yakin mau keluar dari community ini?',
                            );
                            if (!ok) return;

                            final resp = await api.VersusApi.leaveCommunity(request);
                            await _snackFromResp(resp);
                            _refresh();
                          }
                        : null,
                    child: const Text('Leave'),
                  ),
                ),

                const SizedBox(height: 10),
              ],

              _sectionTitle('All Communities'),

              if (overview.communities.isEmpty)
                Container(
                  padding: const EdgeInsets.all(18),
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
                  child: const Text('Belum ada community.'),
                )
              else
                ...overview.communities.map((c) {
                  final bool isMy = my != null && my.id == c.id;

                  Widget trailing;
                  if (c.isOwner) {
                    trailing = Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Edit',
                          onPressed: () async {
                            final ok = await Navigator.push<bool>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CommunityFormPage(communityId: c.id),
                              ),
                            );
                            if (ok == true) _refresh();
                          },
                          icon: const Icon(Icons.edit, color: Colors.black54),
                        ),
                        IconButton(
                          tooltip: 'Delete',
                          onPressed: () async {
                            final ok = await _confirm(
                              'Delete community?',
                              'Kamu yakin mau hapus community "${c.name}"?',
                            );
                            if (!ok) return;

                            final resp = await api.VersusApi.deleteCommunity(request, c.id);
                            await _snackFromResp(resp);
                            _refresh();
                          },
                          icon: const Icon(Icons.delete, color: Colors.black54),
                        ),
                      ],
                    );
                  } else {
                    trailing = FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: isMy ? Colors.black26 : kPrimary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                      onPressed: request.loggedIn && !isMy
                          ? () async {
                              final ok = await _confirm(
                                'Join community?',
                                'Kamu yakin mau join community "${c.name}"?',
                              );
                              if (!ok) return;

                              final resp = await api.VersusApi.joinCommunity(request, c.id);
                              await _snackFromResp(resp);
                              _refresh();
                            }
                          : null,
                      child: Text(isMy ? 'Joined' : 'Join'),
                    );
                  }

                  return _communityCard(
                    c: c,
                    loggedIn: request.loggedIn,
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommunityDetailPage(communityId: c.id),
                        ),
                      );
                      _refresh();
                    },
                    trailing: trailing,
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
