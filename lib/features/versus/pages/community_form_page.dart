import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';
import '../services/versus_api.dart' as api;

class CommunityFormPage extends StatefulWidget {
  final int? communityId; // null = create, not null = edit
  const CommunityFormPage({super.key, this.communityId});

  @override
  State<CommunityFormPage> createState() => _CommunityFormPageState();
}

class _CommunityFormPageState extends State<CommunityFormPage> {
  static const Color kPrimary = Color(0xFFD84040);
  static const Color kBg = Color(0xFFF6F7FB);
  static const Color kFieldBg = Color(0xFFF1F3F6);

  final _formKey = GlobalKey<FormState>();

  final _nameC = TextEditingController();
  final _bioC = TextEditingController();
  String _sport = 'futsal';

  bool _loading = false;

  bool get isEdit => widget.communityId != null;

  final sports = const [
    'sepak bola',
    'futsal',
    'mini soccer',
    'basketball',
    'tennis',
    'badminton',
    'padel',
    'pickle ball',
    'squash',
    'voli',
    'biliard',
    'golf',
    'shooting',
    'tennis meja',
  ];

  @override
  void initState() {
    super.initState();
    if (isEdit) _load();
  }

  @override
  void dispose() {
    _nameC.dispose();
    _bioC.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, {String? hint}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      filled: true,
      fillColor: kFieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
    );
  }

  Future<void> _load() async {
    final request = context.read<CookieRequest>();
    setState(() => _loading = true);
    try {
      final resp =
          await api.VersusApi.fetchCommunityDetail(request, widget.communityId!);

      final Map<String, dynamic> raw = Map<String, dynamic>.from(resp as Map);
      final comm =
          Community.fromJson((raw['community'] ?? raw) as Map<String, dynamic>);

      _nameC.text = comm.name;
      _bioC.text = comm.bio;
      _sport = comm.primarySport;

      if (mounted) setState(() {});
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal memuat data community.')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (_loading) return;

    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    final request = context.read<CookieRequest>();

    setState(() => _loading = true);

    try {
      Map<String, dynamic> resp;

      if (isEdit) {
        resp = await api.VersusApi.updateCommunity(
          request,
          id: widget.communityId!,
          name: _nameC.text.trim(),
          primarySport: _sport,
          bio: _bioC.text.trim(),
        );
      } else {
        resp = await api.VersusApi.createCommunity(
          request,
          name: _nameC.text.trim(),
          primarySport: _sport,
          bio: _bioC.text.trim(),
        );
      }

      final ok = resp['ok'] == true ||
          resp['status'] == true ||
          resp['status'] == 'success';

      final msg = (resp['message'] ?? (ok ? 'Berhasil.' : 'Gagal.')).toString();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      if (ok) Navigator.pop(context, true);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal submit. Coba lagi.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Community' : 'Create Community'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
        children: [
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
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEdit ? 'Update your community' : 'Create a new community',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Lengkapi detail komunitas agar mudah ditemukan & di-join.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _nameC,
                    decoration: _dec('Nama Community', hint: 'Contoh: Futsal UI'),
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Nama community wajib diisi.';
                      }
                      if (v.trim().length < 3) {
                        return 'Minimal 3 karakter.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),

                  DropdownButtonFormField<String>(
                    value: sports.contains(_sport) ? _sport : sports.first,
                    items: sports
                        .map((s) => DropdownMenuItem(
                              value: s,
                              child: Text(s),
                            ))
                        .toList(),
                    onChanged: _loading ? null : (v) => setState(() => _sport = v ?? _sport),
                    decoration: _dec('Primary Sport'),
                  ),
                  const SizedBox(height: 12),

                  TextFormField(
                    controller: _bioC,
                    maxLines: 4,
                    decoration: _dec('Bio', hint: 'Ceritain komunitas kamu singkat aja.'),
                  ),

                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: _loading ? null : _submit,
                      style: FilledButton.styleFrom(
                        backgroundColor: kPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: Text(_loading
                          ? 'Processing...'
                          : (isEdit ? 'Update Community' : 'Create Community')),
                    ),
                  ),

                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _loading ? null : () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_loading && isEdit) ...[
            const SizedBox(height: 14),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}
