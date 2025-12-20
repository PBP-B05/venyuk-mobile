import 'dart:convert';

class Challenge {
  final int id;
  final String title;
  final String sport;
  final String sportLabel;
  final String matchCategory;
  final String matchCategoryLabel;
  final DateTime? startAt;
  final String status;
  final String statusLabel;
  final int costPerPerson;
  final int prizePool;
  final String venueName;
  final String displayVenueName;
  final int playersJoined;
  final int maxPlayers;
  final String detailUrl;
  final int? hostId;
  final String hostName;
  final int? opponentId;
  final String opponentName;
  final bool hasOpponent;
  final int stageCommunitySize;

  // tambahan utk mobile
  final String? description;
  final String? posterUrl;

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
    required this.displayVenueName,
    required this.playersJoined,
    required this.maxPlayers,
    required this.detailUrl,
    required this.hostId,
    required this.hostName,
    required this.opponentId,
    required this.opponentName,
    required this.hasOpponent,
    required this.stageCommunitySize,
    this.description,
    this.posterUrl,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final startAtRaw = json['start_at'];

    return Challenge(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      sport: json['sport'] as String? ?? '',
      sportLabel: json['sport_label'] as String? ?? '',
      matchCategory: json['match_category'] as String? ?? '',
      matchCategoryLabel: json['match_category_label'] as String? ?? '',
      startAt:
          startAtRaw is String && startAtRaw.isNotEmpty ? DateTime.parse(startAtRaw) : null,
      status: json['status'] as String? ?? '',
      statusLabel: json['status_label'] as String? ?? '',

      // ==== FIX DI SINI: tanpa ??, langsung cek is num ====
      costPerPerson: json['cost_per_person'] is num
          ? (json['cost_per_person'] as num).toInt()
          : 0,
      prizePool: json['prize_pool'] is num
          ? (json['prize_pool'] as num).toInt()
          : 0,
      venueName: json['venue_name'] as String? ?? '',
      displayVenueName: json['display_venue_name'] as String? ?? '',
      playersJoined: json['players_joined'] is num
          ? (json['players_joined'] as num).toInt()
          : 0,
      maxPlayers: json['max_players'] is num
          ? (json['max_players'] as num).toInt()
          : 0,
      detailUrl: json['detail_url'] as String? ?? '',
      hostId: json['host_id'] as int?,
      hostName: json['host_name'] as String? ?? '',
      opponentId: json['opponent_id'] as int?,
      opponentName: json['opponent_name'] as String? ?? '',
      hasOpponent: json['has_opponent'] as bool? ?? false,
      stageCommunitySize: json['stage_community_size'] is num
          ? (json['stage_community_size'] as num).toInt()
          : 0,

      description: json['description'] as String?,
      posterUrl: json['poster_url'] as String?,
    );
  }

  static List<Challenge> listFromJson(String body) {
    final List<dynamic> decoded = jsonDecode(body) as List<dynamic>;
    return decoded
        .map((e) => Challenge.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
