const String baseUrl = 'http://127.0.0.1:8000';

// AUTH
String authUserDataUrl() => '$baseUrl/authenticate/user-data/';

// COMMUNITY API
String communitiesUrl() => '$baseUrl/versus/api/communities/';
String communityDetailUrl(int id) => '$baseUrl/versus/api/communities/$id/';
String communityCreateUrl() => '$baseUrl/versus/api/communities/create/';
String communityUpdateUrl(int id) => '$baseUrl/versus/api/communities/$id/update/';
String communityDeleteUrl(int id) => '$baseUrl/versus/api/communities/$id/delete/';
String communityJoinUrl(int id) => '$baseUrl/versus/api/communities/$id/join/';
String communityLeaveUrl() => '$baseUrl/versus/api/communities/leave/';

// CHALLENGE API
String challengesUrl() => '$baseUrl/versus/api/challenges/';
String challengeDetailUrl(int id) => '$baseUrl/versus/api/challenges/$id/';
String challengeCreateUrl() => '$baseUrl/versus/api/challenges/create/';
String challengeJoinUrl(int id) => '$baseUrl/versus/api/challenges/$id/join/';
String challengeUpdateUrl(int id) => '$baseUrl/versus/api/challenges/$id/update/';
String challengeDeleteUrl(int id) => '$baseUrl/versus/api/challenges/$id/delete/';

