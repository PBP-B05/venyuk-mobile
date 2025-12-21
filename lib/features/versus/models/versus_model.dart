// lib/features/versus/models/versus_model.dart
import 'package:pbp_django_auth/pbp_django_auth.dart';

/// FIX: samakan host dengan login.dart (auth)
const String baseUrl = 'http://127.0.0.1:8000';

class Challenge {
  final int id;
  final String title;
  final String sport;
  final String sportLabel;
  final String matchCategory;
  final String matchCategoryLabel;
  final String startAt;
  final String status;
  final String statusLabel;
  final int costPerPerson;
  final int prizePool;
  final String venueName;

  final int hostId;
  final String hostName;
  final int? opponentId;
  final String opponentName;

  final int playersJoined;
  final int maxPlayers;

  final String description;
  final String posterUrl;

  Challenge({
    required this.id,
    required this.title,
    required this.sport,
    required this.sportLabel,
    required this.matchCategory,
    required this.matchCategoryLabel,
    required this.startAt,
    required this.status,
    required this.statusLabel,
    required this.costPerPerson,
    required this.prizePool,
    required this.venueName,
    required this.hostId,
    required this.hostName,
    required this.opponentId,
    required this.opponentName,
    required this.playersJoined,
    required this.maxPlayers,
    required this.description,
    required this.posterUrl,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: (json['id'] ?? 0) as int,
      title: (json['title'] ?? '') as String,
      sport: (json['sport'] ?? '') as String,
      sportLabel: (json['sport_label'] ?? '') as String,
      matchCategory: (json['match_category'] ?? '') as String,
      matchCategoryLabel: (json['match_category_label'] ?? '') as String,
      startAt: (json['start_at'] ?? '') as String,
      status: (json['status'] ?? '') as String,
      statusLabel: (json['status_label'] ?? '') as String,
      costPerPerson: (json['cost_per_person'] ?? 0) as int,
      prizePool: (json['prize_pool'] ?? 0) as int,
      venueName: (json['display_venue_name'] ?? '') as String,
      hostId: (json['host_id'] ?? 0) as int,
      hostName: (json['host_name'] ?? '') as String,
      opponentId: json['opponent_id'] as int?,
      opponentName: (json['opponent_name'] ?? '') as String,
      playersJoined: (json['players_joined'] ?? 0) as int,
      maxPlayers: (json['max_players'] ?? 0) as int,
      description: (json['description'] ?? '') as String,
      posterUrl: (json['poster_url'] ?? '') as String,
    );
  }
}

class VersusApi {
  /// GET /versus/api/challenges/
  static Future<List<Challenge>> fetchList(CookieRequest request) async {
    final resp = await request.get('$baseUrl/versus/api/challenges/');
    final list = (resp as List)
        .map((e) => Challenge.fromJson((e as Map).cast<String, dynamic>()))
        .toList();
    return list;
  }

  /// GET /versus/api/challenges/<id>/
  static Future<Challenge> fetchDetail(CookieRequest request, int id) async {
    final resp = await request.get('$baseUrl/versus/api/challenges/$id/');
    return Challenge.fromJson((resp as Map).cast<String, dynamic>());
  }

  /// POST /versus/api/challenges/create/
  static Future<Map<String, dynamic>> create(
    CookieRequest request, {
    required String title,
    required String sport,
    required String matchCategory,
    required String startAt, // yyyy-MM-ddTHH:mm:ss or iso
    required String venueName,
    required String costPerPerson,
    required String prizePool,
    required String description,
    required String posterUrl,
  }) async {
    final resp = await request.post(
      '$baseUrl/versus/api/challenges/create/',
      {
        'title': title,
        'sport': sport,
        'match_category': matchCategory,
        'start_at': startAt,
        'venue_name': venueName,
        'cost_per_person': costPerPerson,
        'prize_pool': prizePool,
        'description': description,
        'poster_url': posterUrl,
      },
    );
    return (resp as Map).cast<String, dynamic>();
  }

  /// POST /versus/api/challenges/<id>/join/
  static Future<Map<String, dynamic>> join(
    CookieRequest request,
    int id,
  ) async {
    final resp = await request.post(
      '$baseUrl/versus/api/challenges/$id/join/',
      {},
    );
    return (resp as Map).cast<String, dynamic>();
  }
}
