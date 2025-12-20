class Match {
  final int id;
  final String venueId; // UUID
  final String venueName;
  final String venueCity;
  final String venueImage; // URL Gambar
  
  final String creatorUsername;
  
  final int slotTotal;
  final int slotTerisi;
  final DateTime startTime;
  final DateTime endTime;
  final String difficultyLevel;

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
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    // Helper biar gak pusing konversi tipe data
    String safeString(dynamic val) => val?.toString() ?? "";
    int safeInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    return Match(
      id: safeInt(json['id']),
      
      // Handle UUID atau Int ID
      venueId: safeString(json['venue']),
      
      // Pastikan nama venue ada
      venueName: safeString(json['venue_name']).isEmpty ? "Venue Unknown" : safeString(json['venue_name']),
      
      venueCity: safeString(json['venue_city']),
      
      // Ambil gambar. Kalau API belum kirim field 'venue_image', kasih string kosong biar gak null
      venueImage: safeString(json['venue_image']),
      
      creatorUsername: safeString(json['creator_username']).isEmpty ? "User" : safeString(json['creator_username']),
      
      slotTotal: safeInt(json['slot_total']),
      slotTerisi: safeInt(json['slot_terisi']),
      
      // Parsing Waktu Aman
      startTime: json['start_time'] != null 
          ? DateTime.tryParse(safeString(json['start_time'])) ?? DateTime.now() 
          : DateTime.now(),
      endTime: json['end_time'] != null 
          ? DateTime.tryParse(safeString(json['end_time'])) ?? DateTime.now().add(const Duration(hours: 1)) 
          : DateTime.now(),
      
      difficultyLevel: safeString(json['difficulty_level']).isEmpty ? "beginner" : safeString(json['difficulty_level']),
    );
  }
}