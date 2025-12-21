import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/versus_model.dart';
import '../services/versus_api.dart';
import 'versus_detail_page.dart';
import 'versus_form_page.dart';

class VersusListPage extends StatefulWidget {
  const VersusListPage({super.key});

  @override
  State<VersusListPage> createState() => _VersusListPageState();
}

class _VersusListPageState extends State<VersusListPage> {
  late Future<List<Challenge>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Challenge>> _load() async {
    final request = context.read<CookieRequest>();
    final resp = await VersusApi.fetchChallenges(request);
    final list = (resp as List).map((e) => Challenge.fromJson((e as Map).cast<String, dynamic>())).toList();
    return list;
  }

  Future<void> _refresh() async {
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Challenge>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: [
                  const SizedBox(height: 24),
                  Center(child: Text('Error: ${snapshot.error}')),
                ],
              );
            }

            final items = snapshot.data ?? [];
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 24),
                  Center(child: Text('Belum ada matchup.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final ch = items[i];
                return Card(
                  child: ListTile(
                    title: Text(ch.title),
                    subtitle: Text(
                      '${ch.sportLabel} • ${ch.matchCategoryLabel}\n'
                      '${ch.statusLabel} • ${ch.playersJoined}/${ch.maxPlayers}\n'
                      'Host: ${ch.hostName} • Opp: ${ch.opponentName.isEmpty ? '-' : ch.opponentName}',
                    ),
                    onTap: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => VersusDetailPage(challengeId: ch.id)),
                      );
                      _refresh();
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          if (!request.loggedIn) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Silakan login terlebih dahulu.')),
            );
            return;
          }
          final changed = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const VersusFormPage()),
          );
          if (changed == true) _refresh();
        },
        label: const Text('Buat Matchup'),
        icon: const Icon(Icons.add),
      ),
    );
  }
}
