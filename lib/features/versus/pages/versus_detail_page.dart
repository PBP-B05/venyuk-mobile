import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/versus_model.dart';
import '../services/versus_api.dart';

class VersusDetailPage extends StatefulWidget {
  final int challengeId;
  const VersusDetailPage({super.key, required this.challengeId});

  @override
  State<VersusDetailPage> createState() => _VersusDetailPageState();
}

class _VersusDetailPageState extends State<VersusDetailPage> {
  late Future<Challenge> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Challenge> _load() async {
    final request = context.read<CookieRequest>();
    final resp = await VersusApi.fetchChallengeDetail(request, widget.challengeId);
    return Challenge.fromJson((resp as Map).cast<String, dynamic>());
  }

  Future<void> _join() async {
    final request = context.read<CookieRequest>();
    try {
      final resp = await VersusApi.joinChallenge(request, widget.challengeId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(resp['message'] ?? 'Berhasil join')),
      );
      setState(() => _future = _load());
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal join: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Matchup')),
      body: FutureBuilder<Challenge>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) return Center(child: Text('Error: ${snap.error}'));

          final ch = snap.data!;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ch.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('${ch.sportLabel} • ${ch.matchCategoryLabel}'),
                const SizedBox(height: 8),
                Text('Status: ${ch.statusLabel}'),
                const SizedBox(height: 8),
                Text('Slot: ${ch.playersJoined}/${ch.maxPlayers}'),
                const Divider(height: 24),
                Text('Venue: ${ch.venueName.isEmpty ? '-' : ch.venueName}'),
                const SizedBox(height: 8),
                Text('Host: ${ch.hostName}'),
                const SizedBox(height: 8),
                Text('Opponent: ${ch.opponentName.isEmpty ? '-' : ch.opponentName}'),
                const Divider(height: 24),
                Text(ch.description.isEmpty ? '-' : ch.description),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: request.loggedIn ? _join : null,
                    child: Text(request.loggedIn ? 'Join Matchup' : 'Login dulu untuk join'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
