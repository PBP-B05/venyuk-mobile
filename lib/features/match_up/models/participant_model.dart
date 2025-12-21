import 'dart:convert';

List<Participant> participantFromJson(String str) => List<Participant>.from(json.decode(str).map((x) => Participant.fromJson(x)));

String participantToJson(List<Participant> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Participant {
    int id;
    int matchId;
    int userId;
    String fullName;
    String phone;
    DateTime joinedAt;

    Participant({
        required this.id,
        required this.matchId,
        required this.userId,
        required this.fullName,
        required this.phone,
        required this.joinedAt,
    });

    factory Participant.fromJson(Map<String, dynamic> json) => Participant(
        id: json["id"],
        matchId: json["match"],
        userId: json["user"],
        fullName: json["full_name"],
        phone: json["phone"],
        joinedAt: DateTime.parse(json["joined_at"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "match": matchId,
        "user": userId,
        "full_name": fullName,
        "phone": phone,
        "joined_at": joinedAt.toIso8601String(),
    };
}