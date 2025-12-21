// lib/features/versus/versus_config.dart

/// Kamu minta pakai localhost 127.0.0.1.
/// Kalau di Android Emulator biasanya harus 10.0.2.2.
/// Tapi sesuai request kamu, kita pakai 127.0.0.1 dulu.
const String baseUrl = 'http://127.0.0.1:8000';

// ============ COMMUNITY URLS ============
String communitiesUrl() => '$baseUrl/versus/api/communities/';
String communityDetailUrl(int id) => '$baseUrl/versus/api/communities/$id/';
String communityCreateUrl() => '$baseUrl/versus/api/communities/create/';
String communityUpdateUrl(int id) => '$baseUrl/versus/api/communities/$id/update/';
String communityDeleteUrl(int id) => '$baseUrl/versus/api/communities/$id/delete/';
String communityJoinUrl(int id) => '$baseUrl/versus/api/communities/$id/join/';
String communityLeaveUrl() => '$baseUrl/versus/api/communities/leave/';

// ============ CHALLENGE / MATCHUP URLS ============
String challengesUrl() => '$baseUrl/versus/api/challenges/';
String challengeDetailUrl(int id) => '$baseUrl/versus/api/challenges/$id/';
String challengeCreateUrl() => '$baseUrl/versus/api/challenges/create/';
String challengeJoinUrl(int id) => '$baseUrl/versus/api/challenges/$id/join/';

// ============ AUTH HELPERS (opsional, buat VersusSession) ============
String authUserDataUrl() => '$baseUrl/authenticate/user-data/';
