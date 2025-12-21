// lib/features/versus/models/community_model.dart
import 'package:pbp_django_auth/pbp_django_auth.dart';

/// NOTE:
/// Kamu minta pakai 127.0.0.1 (localhost) saja.
/// Kalau kamu run di Android Emulator dan API gak ke-hit,
/// ganti jadi: http://10.0.2.2:8000
const String baseUrl = 'http://127.0.0.1:8000';

class Community {
  final int id;
  final String name;
  final String primarySport;
  final String primarySportLabel;
  final String bio;
  final String ownerUsername;
  final int totalMembers;
  final bool isOwner;
  final bool isMember;

  const Community({
    required this.id,
    required this.name,
    required this.primarySport,
    required this.primarySportLabel,
    required this.bio,
    required this.ownerUsername,
    required this.totalMembers,
    required this.isOwner,
    required this.isMember,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    // support:
    // - { "community": {...} }
    // - { ...fields... }
    final Map<String, dynamic> data =
        (json['community'] is Map<String, dynamic>) ? json['community'] : json;

    return Community(
      id: (data['id'] ?? 0) is int ? data['id'] : int.parse('${data['id']}'),
      name: (data['name'] ?? '').toString(),
      primarySport: (data['primary_sport'] ?? '').toString(),
      primarySportLabel: (data['primary_sport_label'] ?? '').toString(),
      bio: (data['bio'] ?? '').toString(),
      ownerUsername: (data['owner_username'] ?? '').toString(),
      totalMembers: (data['total_members'] ?? 0) is int
          ? data['total_members']
          : int.tryParse('${data['total_members']}') ?? 0,
      isOwner: (data['is_owner'] ?? false) == true,
      isMember: (data['is_member'] ?? false) == true,
    );
  }
}

/// Response untuk halaman list:
/// backend kamu return:
/// {
///   "ok": true,
///   "my_current": {...} | null,
///   "communities": [ {...}, {...} ]
/// }
class CommunityOverview {
  final Community? myCurrent;
  final List<Community> communities;

  const CommunityOverview({
    required this.myCurrent,
    required this.communities,
  });

  factory CommunityOverview.fromJson(dynamic raw) {
    // support 2 bentuk:
    // 1) [ {...}, {...} ]  (kalau backend suatu saat return list doang)
    // 2) { ok, my_current, communities }
    if (raw is List) {
      final list = raw
          .map((e) => Community.fromJson(e as Map<String, dynamic>))
          .toList();
      return CommunityOverview(myCurrent: null, communities: list);
    }

    if (raw is Map<String, dynamic>) {
      final myCurrentJson = raw['my_current'];
      final Community? myCurrent = (myCurrentJson == null)
          ? null
          : Community.fromJson(myCurrentJson as Map<String, dynamic>);

      final listJson = raw['communities'] ?? raw['data'] ?? [];
      final list = (listJson as List)
          .map((e) => Community.fromJson(e as Map<String, dynamic>))
          .toList();

      return CommunityOverview(myCurrent: myCurrent, communities: list);
    }

    throw Exception('Format response community tidak dikenali: ${raw.runtimeType}');
  }

  // ==========================
  // API CALLS (MATCH BACKEND)
  // ==========================

  /// GET /versus/api/communities/
  static Future<CommunityOverview> fetch(CookieRequest request) async {
    final resp = await request.get('$baseUrl/versus/api/communities/');
    return CommunityOverview.fromJson(resp);
  }

  /// GET /versus/api/communities/<id>/
  /// backend kamu return:
  /// { ok: true, community: {...}, challenges_hosted:[], challenges_joined:[] }
  static Future<Community> fetchDetail(CookieRequest request, int id) async {
    final resp = await request.get('$baseUrl/versus/api/communities/$id/');

    if (resp is Map<String, dynamic>) {
      if (resp['ok'] == false) {
        throw Exception(resp['message'] ?? 'Gagal memuat detail community');
      }
      if (resp['community'] is Map<String, dynamic>) {
        return Community.fromJson(resp['community'] as Map<String, dynamic>);
      }
    }

    // fallback kalau backend return field langsung
    return Community.fromJson(resp as Map<String, dynamic>);
  }

  /// POST /versus/api/communities/create/
  static Future<Map<String, dynamic>> create(
    CookieRequest request, {
    required String name,
    required String primarySport,
    required String bio,
  }) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/create/',
      {
        'name': name,
        'primary_sport': primarySport,
        'bio': bio,
      },
    );
    return (resp as Map).cast<String, dynamic>();
  }

  /// POST /versus/api/communities/<id>/update/
  static Future<Map<String, dynamic>> update(
    CookieRequest request, {
    required int id,
    required String name,
    required String primarySport,
    required String bio,
  }) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/$id/update/',
      {
        'name': name,
        'primary_sport': primarySport,
        'bio': bio,
      },
    );
    return (resp as Map).cast<String, dynamic>();
  }

  /// POST /versus/api/communities/<id>/delete/
  static Future<Map<String, dynamic>> delete(
    CookieRequest request,
    int id,
  ) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/$id/delete/',
      {},
    );
    return (resp as Map).cast<String, dynamic>();
  }

  /// POST /versus/api/communities/<id>/join/
  static Future<Map<String, dynamic>> join(
    CookieRequest request,
    int id,
  ) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/$id/join/',
      {},
    );
    return (resp as Map).cast<String, dynamic>();
  }

  /// POST /versus/api/communities/leave/
  static Future<Map<String, dynamic>> leave(CookieRequest request) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/leave/',
      {},
    );
    return (resp as Map).cast<String, dynamic>();
  }
}
