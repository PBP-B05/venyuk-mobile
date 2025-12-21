import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../versus_config.dart';
import 'versus_session.dart';

class VersusApi {
  static Future<Map<String, dynamic>> _withUsername(
    CookieRequest request,
    Map<String, dynamic> body,
  ) async {
    final username = await VersusSession.getUsername(request);
    if (username == null || username.isEmpty) return body;
    return {...body, 'username': username};
  }

  // Ambil origin dari endpoint yang sudah ada di config (biar gak perlu edit config lagi)
  static String _originFromConfig() {
    final u = Uri.parse(communitiesUrl());
    return u.origin; // scheme + host (+port)
  }

  // ============ VENUE (UNTUK DROPDOWN) ============
  // GET: /venue/json/ -> List[{id,name,...}]
  static Future<List<Map<String, dynamic>>> fetchVenues(
    CookieRequest request,
  ) async {
    final url = '${_originFromConfig()}/venue/json/';
    final resp = await request.get(url);

    if (resp is List) {
      return resp.map((e) => (e as Map).cast<String, dynamic>()).toList();
    }
    return [];
  }

  // ============ COMMUNITY ============
  static Future<dynamic> fetchCommunities(CookieRequest request) async {
    return await request.get(communitiesUrl());
  }

  static Future<dynamic> fetchCommunityDetail(
    CookieRequest request,
    int id,
  ) async {
    return await request.get(communityDetailUrl(id));
  }

  static Future<Map<String, dynamic>> createCommunity(
    CookieRequest request, {
    required String name,
    required String primarySport,
    required String bio,
  }) async {
    final body = await _withUsername(request, {
      'name': name,
      'primary_sport': primarySport,
      'bio': bio,
    });
    final resp = await request.post(communityCreateUrl(), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> updateCommunity(
    CookieRequest request, {
    required int id,
    required String name,
    required String primarySport,
    required String bio,
  }) async {
    final body = await _withUsername(request, {
      'name': name,
      'primary_sport': primarySport,
      'bio': bio,
    });
    final resp = await request.post(communityUpdateUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> deleteCommunity(
    CookieRequest request,
    int id,
  ) async {
    final body = await _withUsername(request, {});
    final resp = await request.post(communityDeleteUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> joinCommunity(
    CookieRequest request,
    int id,
  ) async {
    final body = await _withUsername(request, {});
    final resp = await request.post(communityJoinUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> leaveCommunity(
    CookieRequest request,
  ) async {
    final body = await _withUsername(request, {});
    final resp = await request.post(communityLeaveUrl(), body);
    return (resp as Map).cast<String, dynamic>();
  }

  // ============ CHALLENGE / MATCHUP ============
  static Future<dynamic> fetchChallenges(CookieRequest request) async {
    return await request.get(challengesUrl());
  }

  static Future<dynamic> fetchChallengeDetail(
    CookieRequest request,
    int id,
  ) async {
    return await request.get(challengeDetailUrl(id));
  }

  static Future<Map<String, dynamic>> createChallenge(
    CookieRequest request, {
    required String title,
    required String sport,
    required String matchCategory,
    required String startAt, // ISO string
    required String venueName,
    String? venueId, // ✅ NEW
    required String costPerPerson,
    required String prizePool,
    required String description,
    required String posterUrl,
  }) async {
    final raw = <String, dynamic>{
      'title': title,
      'sport': sport,
      'match_category': matchCategory,
      'start_at': startAt,
      'venue_name': venueName, // fallback/compat
      if (venueId != null && venueId.trim().isNotEmpty) 'venue': venueId.trim(),
      'cost_per_person': costPerPerson,
      'prize_pool': prizePool,
      'description': description,
      'poster_url': posterUrl,
    };

    final body = await _withUsername(request, raw);
    final resp = await request.post(challengeCreateUrl(), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> updateChallenge(
    CookieRequest request, {
    required int id,
    required String title,
    required String sport,
    required String matchCategory,
    required String startAt, // ISO string
    required String venueName,
    String? venueId, // ✅ NEW (opsional)
    required String costPerPerson,
    required String prizePool,
    required String description,
    required String posterUrl,
  }) async {
    final raw = <String, dynamic>{
      'title': title,
      'sport': sport,
      'match_category': matchCategory,
      'start_at': startAt,
      'venue_name': venueName,
      if (venueId != null && venueId.trim().isNotEmpty) 'venue': venueId.trim(),
      'cost_per_person': costPerPerson,
      'prize_pool': prizePool,
      'description': description,
      'poster_url': posterUrl,
    };

    final body = await _withUsername(request, raw);
    final resp = await request.post(challengeUpdateUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> deleteChallenge(
    CookieRequest request,
    int id,
  ) async {
    final body = await _withUsername(request, {});
    final resp = await request.post(challengeDeleteUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> joinChallenge(
    CookieRequest request,
    int id,
  ) async {
    final body = await _withUsername(request, {});
    final resp = await request.post(challengeJoinUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }
}
