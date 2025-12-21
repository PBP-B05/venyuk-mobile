import 'package:pbp_django_auth/pbp_django_auth.dart';
import '../versus_config.dart';
import 'versus_session.dart';

class VersusApi {
  static Future<Map<String, dynamic>> _withUsername(Map<String, dynamic> body) async {
    final username = await VersusSession.getUsername();
    if (username == null || username.isEmpty) return body;
    return {...body, 'username': username};
  }

  // ============ COMMUNITY ============
  static Future<dynamic> fetchCommunities(CookieRequest request) async {
    return await request.get(communitiesUrl());
  }

  static Future<dynamic> fetchCommunityDetail(CookieRequest request, int id) async {
    return await request.get(communityDetailUrl(id));
  }

  static Future<Map<String, dynamic>> createCommunity(
    CookieRequest request, {
    required String name,
    required String primarySport,
    required String bio,
  }) async {
    final body = await _withUsername({
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
    final body = await _withUsername({
      'name': name,
      'primary_sport': primarySport,
      'bio': bio,
    });
    final resp = await request.post(communityUpdateUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> deleteCommunity(CookieRequest request, int id) async {
    final body = await _withUsername({});
    final resp = await request.post(communityDeleteUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> joinCommunity(CookieRequest request, int id) async {
    final body = await _withUsername({});
    final resp = await request.post(communityJoinUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> leaveCommunity(CookieRequest request) async {
    final body = await _withUsername({});
    final resp = await request.post(communityLeaveUrl(), body);
    return (resp as Map).cast<String, dynamic>();
  }

  // ============ CHALLENGE / MATCHUP ============
  static Future<dynamic> fetchChallenges(CookieRequest request) async {
    return await request.get(challengesUrl());
  }

  static Future<dynamic> fetchChallengeDetail(CookieRequest request, int id) async {
    return await request.get(challengeDetailUrl(id));
  }

  static Future<Map<String, dynamic>> createChallenge(
    CookieRequest request, {
    required String title,
    required String sport,
    required String matchCategory,
    required String startAt, // format: yyyy-MM-ddTHH:mm
    required String venueName,
    required String costPerPerson,
    required String prizePool,
    required String description,
    required String posterUrl,
  }) async {
    final body = await _withUsername({
      'title': title,
      'sport': sport,
      'match_category': matchCategory,
      'start_at': startAt,
      'venue_name': venueName,
      'cost_per_person': costPerPerson,
      'prize_pool': prizePool,
      'description': description,
      'poster_url': posterUrl,
    });

    final resp = await request.post(challengeCreateUrl(), body);
    return (resp as Map).cast<String, dynamic>();
  }

  static Future<Map<String, dynamic>> joinChallenge(CookieRequest request, int id) async {
    final body = await _withUsername({});
    final resp = await request.post(challengeJoinUrl(id), body);
    return (resp as Map).cast<String, dynamic>();
  }
}
