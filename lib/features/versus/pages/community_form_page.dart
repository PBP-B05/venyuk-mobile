// lib/features/versus/pages/community_form_page.dart
import 'package:flutter/material.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

import '../models/community_model.dart';

class CommunityFormPage extends StatefulWidget {
  final Community? community; // null = create, not null = edit

  const CommunityFormPage({super.key, this.community});

  @override
  State<CommunityFormPage> createState() => _CommunityFormPageState();
}

class _CommunityFormPageState extends State<CommunityFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  String _selectedSport = 'futsal';
  bool _submitting = false;

  final List<Map<String, String>> _sportChoices = const [
    {'value': 'futsal', 'label': 'Futsal'},
    {'value': 'sepak bola', 'label': 'Sepak Bola'},
    {'value': 'basketball', 'label': 'Basketball'},
    {'value': 'badminton', 'label': 'Badminton'},
    {'value': 'voli', 'label': 'Voli'},
  ];

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.community?.name ?? '');
    _bioController =
        TextEditingController(text: widget.community?.bio ?? '');
    _selectedSport = widget.community?.primarySport ?? 'futsal';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
    });

    final request = context.read<CookieRequest>();

    try {
      Map<String, dynamic> resp;
      if (widget.community == null) {
        // CREATE
        resp = await CommunityOverview.create(
          request,
          name: _nameController.text.trim(),
          primarySport: _selectedSport,
          bio: _bioController.text.trim(),
        );
      } else {
        // UPDATE
        resp = await CommunityOverview.update(
          request,
          id: widget.community!.id,
          name: _nameController.text.trim(),
          primarySport: _selectedSport,
          bio: _bioController.text.trim(),
        );
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            resp['message'] ??
                (widget.community == null
                    ? 'Community berhasil dibuat'
                    : 'Community berhasil diupdate'),
          ),
        ),
      );

      if (resp['ok'] == true || resp['status'] == 'success') {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan community: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _submitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.community != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F1FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F1FF),
        elevation: 0,
        title: Text(isEdit ? 'Edit Community' : 'Create Community'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nama Community',
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama tidak boleh kosong';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedSport,
                    decoration: const InputDecoration(
                      labelText: 'Olahraga utama',
                    ),
                    items: _sportChoices
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e['value'],
                            child: Text(e['label']!),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSport = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _bioController,
                    decoration: const InputDecoration(
                      labelText: 'Deskripsi / Bio',
                    ),
                    minLines: 3,
                    maxLines: 5,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD84040),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        _submitting
                            ? 'Menyimpan...'
                            : (isEdit ? 'Simpan Perubahan' : 'Buat Community'),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
