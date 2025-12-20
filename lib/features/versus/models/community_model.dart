// lib/features/versus/models/community_model.dart
import 'package:flutter/foundation.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';

const String _webBase = 'http://127.0.0.1:8000';
const String _emulatorBase = 'http://10.0.2.2:8000';
String get baseUrl => kIsWeb ? _webBase : _emulatorBase;

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

  Community({
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
    // Kalau backend return { "community": {...} }
    final Map<String, dynamic> data =
        json['community'] is Map<String, dynamic> ? json['community'] : json;

    return Community(
      id: data['id'] as int,
      name: data['name'] ?? '',
      primarySport: data['primary_sport'] ?? '',
      primarySportLabel: data['primary_sport_label'] ?? '',
      bio: data['bio'] ?? '',
      ownerUsername: data['owner_username'] ?? '',
      totalMembers: data['total_members'] ?? 0,
      isOwner: data['is_owner'] ?? false,
      isMember: data['is_member'] ?? false,
    );
  }
}

/// Response untuk halaman list:
/// - myCurrent = komunitas yang sedang kita ikuti (atau null)
/// - communities = semua komunitas (list)
class CommunityOverview {
  final Community? myCurrent;
  final List<Community> communities;

  CommunityOverview({
    required this.myCurrent,
    required this.communities,
  });

  factory CommunityOverview.fromJson(dynamic raw) {
    // Support 2 bentuk:
    // 1) [ {...}, {...} ]              (simple list)
    // 2) { ok, my_current, communities }
    if (raw is List) {
      final list = raw
          .map((e) => Community.fromJson(e as Map<String, dynamic>))
          .toList();
      return CommunityOverview(myCurrent: null, communities: list);
    }

    if (raw is Map<String, dynamic>) {
      final myCurrentJson = raw['my_current'];
      final myCurrent = myCurrentJson == null
          ? null
          : Community.fromJson(myCurrentJson as Map<String, dynamic>);
      final listJson = raw['communities'] ?? raw['data'] ?? [];
      final list = (listJson as List)
          .map((e) => Community.fromJson(e as Map<String, dynamic>))
          .toList();
      return CommunityOverview(myCurrent: myCurrent, communities: list);
    }

    throw Exception('Format response community tidak dikenali');
  }

  /// GET /versus/api/communities/
  static Future<CommunityOverview> fetch(CookieRequest request) async {
    final resp = await request.get('$baseUrl/versus/api/communities/');
    // resp bisa List atau Map
    return CommunityOverview.fromJson(resp);
  }

  /// GET /versus/api/communities/<id>/
  static Future<Community> fetchDetail(
      CookieRequest request, int id) async {
    final resp =
        await request.get('$baseUrl/versus/api/communities/$id/');
    // Bisa berupa { ..field.. } atau { ok, community: {...} }
    if (resp is Map<String, dynamic> &&
        resp.containsKey('ok') &&
        resp['ok'] == false) {
      throw Exception(resp['message'] ?? 'Gagal memuat detail community');
    }
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
    return resp as Map<String, dynamic>;
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
    return resp as Map<String, dynamic>;
  }

  /// POST /versus/api/communities/<id>/delete/
  static Future<Map<String, dynamic>> delete(
      CookieRequest request, int id) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/$id/delete/',
      {},
    );
    return resp as Map<String, dynamic>;
  }

  /// POST /versus/api/communities/<id>/join/
  static Future<Map<String, dynamic>> join(
      CookieRequest request, int id) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/$id/join/',
      {},
    );
    return resp as Map<String, dynamic>;
  }

  /// POST /versus/api/communities/leave/
  static Future<Map<String, dynamic>> leave(CookieRequest request) async {
    final resp = await request.post(
      '$baseUrl/versus/api/communities/leave/',
      {},
    );
    return resp as Map<String, dynamic>;
  }
}
