class Challenge {
  final int id;
  final String title;
  final String sport;
  final String sportLabel;
  final String matchCategory;
  final String matchCategoryLabel;
  final String? startAt; // ISO string
  final String status;
  final String statusLabel;

  final int costPerPerson;
  final int prizePool;

  final String venueName;
  final String displayVenueName;

  final int playersJoined;
  final int maxPlayers;

  final int hostId;
  final String hostName;
  final int? opponentId;
  final String opponentName;

  final bool hasOpponent;
  final int stageCommunitySize;

  final String description;
  final String posterUrl;

  final bool canManage;

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
    required this.hostId,
    required this.hostName,
    required this.opponentId,
    required this.opponentName,
    required this.hasOpponent,
    required this.stageCommunitySize,
    required this.description,
    required this.posterUrl,
    required this.canManage,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse(v?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic v) {
    if (v is bool) return v;
    final s = (v ?? '').toString().toLowerCase().trim();
    return s == 'true' || s == '1' || s == 'yes';
  }

  factory Challenge.fromJson(Map<String, dynamic> json) {
    final map = (json as Map).cast<String, dynamic>();

    return Challenge(
      id: _toInt(map['id']),
      title: (map['title'] ?? '').toString(),
      sport: (map['sport'] ?? '').toString(),
      sportLabel: (map['sport_label'] ?? '').toString(),
      matchCategory: (map['match_category'] ?? '').toString(),
      matchCategoryLabel: (map['match_category_label'] ?? '').toString(),
      startAt: map['start_at']?.toString(),
      status: (map['status'] ?? '').toString(),
      statusLabel: (map['status_label'] ?? '').toString(),
      costPerPerson: _toInt(map['cost_per_person']),
      prizePool: _toInt(map['prize_pool']),
      venueName: (map['venue_name'] ?? '').toString(),
      displayVenueName: (map['display_venue_name'] ?? map['venue_name'] ?? '').toString(),
      playersJoined: _toInt(map['players_joined']),
      maxPlayers: _toInt(map['max_players']),
      hostId: _toInt(map['host_id']),
      hostName: (map['host_name'] ?? '').toString(),
      opponentId: map['opponent_id'] == null ? null : _toInt(map['opponent_id']),
      opponentName: (map['opponent_name'] ?? '').toString(),
      hasOpponent: _toBool(map['has_opponent']),
      stageCommunitySize: _toInt(map['stage_community_size']),
      description: (map['description'] ?? '').toString(),
      posterUrl: (map['poster_url'] ?? '').toString(),
      canManage: _toBool(map['can_manage'] ?? false), 
    );
  }

  String get displayVenue => displayVenueName;
}
