class Match {
  final int id;
  final String venueId; // UUID atau String ID
  final String venueName;
  final String venueCity;
  final String venueImage; // URL Gambar (Sudah Fix Localhost)
  
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
    String safeString(dynamic val) => val?.toString() ?? "";
    int safeInt(dynamic val) {
      if (val is int) return val;
      if (val is String) return int.tryParse(val) ?? 0;
      return 0;
    }

    // --- LOGIC PROXY IMAGE ---
    String rawImage = safeString(json['venue_image']);
    String finalImageUrl = "";

    if (rawImage.isNotEmpty) {
      if (rawImage.startsWith('http')) {
        // KASUS 1: URL Eksternal (https://google.com/...)
        // Kita bungkus pakai Proxy Django biar tidak kena blokir Chrome
        // Encode URL biar karakter aneh (%) aman
        final encodedUrl = Uri.encodeComponent(rawImage);
        finalImageUrl = "http://localhost:8000/match_up/proxy-image/?url=$encodedUrl";
      
      } else {
        // KASUS 2: Gambar Lokal Django (/media/...)
        finalImageUrl = "http://localhost:8000$rawImage";
      }
    }
    // -------------------------

    return Match(
      id: safeInt(json['id']),
      venueId: safeString(json['venue']),
      venueName: safeString(json['venue_name']).isEmpty ? "Venue Unknown" : safeString(json['venue_name']),
      venueCity: safeString(json['venue_city']),
      
      // Pakai URL hasil logic di atas
      venueImage: finalImageUrl, 
      
      creatorUsername: safeString(json['creator_username']).isEmpty ? "User" : safeString(json['creator_username']),
      slotTotal: safeInt(json['slot_total']),
      slotTerisi: safeInt(json['slot_terisi']),
      startTime: json['start_time'] != null ? DateTime.tryParse(safeString(json['start_time'])) ?? DateTime.now() : DateTime.now(),
      endTime: json['end_time'] != null ? DateTime.tryParse(safeString(json['end_time'])) ?? DateTime.now().add(const Duration(hours: 1)) : DateTime.now(),
      difficultyLevel: safeString(json['difficulty_level']).isEmpty ? "beginner" : safeString(json['difficulty_level']),
    );
  }
}