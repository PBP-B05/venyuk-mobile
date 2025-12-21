class Match {
  final int id;
  final String venueId;
  final String venueName;
  final String venueCity;
  final String venueImage;
  final String creatorUsername;
  final int slotTotal;
  final int slotTerisi;
  final DateTime startTime;
  final DateTime endTime;
  final String difficultyLevel;

  // NEW: status flags (backend mungkin mengirim ini)
  final bool isJoined;
  final bool isMyMatch;

  Match({
    required this.id,
    required this.venueId,
    required this.venueName,
    required this.venueCity,
    required this.venueImage,
    required this.creatorUsername,
    required this.slotTotal,
    required this.slotTerisi,
    required this.startTime,
    required this.endTime,
    required this.difficultyLevel,
    this.isJoined = false,
    this.isMyMatch = false,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    String safeString(dynamic val) => val?.toString() ?? "";
    int safeInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }
    bool safeBool(dynamic val) {
      if (val == null) return false;
      if (val is bool) return val;
      if (val is String) return val.toLowerCase() == 'true';
      if (val is int) return val != 0;
      return false;
    }

    String rawImage = safeString(json['venue_image']);
    String finalImageUrl = "";
    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        final encodedUrl = Uri.encodeComponent(rawImage);
        finalImageUrl = "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id//match_up/proxy-image/?url=$encodedUrl";
      } else {
        finalImageUrl = "https://muhammad-fattan-venyuk.pbp.cs.ui.ac.id/$rawImage";
      }
    }

    return Match(
      id: safeInt(json['id']),
      venueId: safeString(json['venue']),
      venueName: safeString(json['venue_name']).isEmpty ? "Venue Unknown" : safeString(json['venue_name']),
      venueCity: safeString(json['venue_city']),
      venueImage: finalImageUrl,
      creatorUsername: safeString(json['creator_username']).isEmpty ? "User" : safeString(json['creator_username']),
      slotTotal: safeInt(json['slot_total']),
      slotTerisi: safeInt(json['slot_terisi']),
      startTime: json['start_time'] != null ? DateTime.tryParse(safeString(json['start_time'])) ?? DateTime.now() : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.tryParse(safeString(json['end_time'])) ?? DateTime.now().add(const Duration(hours: 1)) : DateTime.now(),
      difficultyLevel: safeString(json['difficulty_level']).isEmpty ? "beginner" : safeString(json['difficulty_level']),
      // read possible backend-provided flags (try multiple key names)
      isJoined: safeBool(json['is_joined'] ?? json['is_join'] ?? json['joined']),
      isMyMatch: safeBool(json['is_my_match'] ?? json['is_creator'] ?? json['is_owner']),
    );
  }
}