class Community {
  final int id;
  final String name;
  final String primarySport;
  final String primarySportLabel;
  final String bio;
  final String ownerUsername;
  final int totalMembers;
  final bool isOwner;
  final bool isMember;
  final bool isMyCurrent;

  Community({
    required this.id,
    required this.name,
    required this.primarySport,
    required this.primarySportLabel,
    required this.bio,
    required this.ownerUsername,
    required this.totalMembers,
    required this.isOwner,
    required this.isMember,
    required this.isMyCurrent,
  });

  factory Community.fromJson(Map<String, dynamic> json) {
    // support { "community": {...} }
    final data = json['community'] is Map<String, dynamic> ? json['community'] : json;
    final map = (data as Map).cast<String, dynamic>();

    return Community(
      id: (map['id'] ?? 0) as int,
      name: (map['name'] ?? '').toString(),
      primarySport: (map['primary_sport'] ?? '').toString(),
      primarySportLabel: (map['primary_sport_label'] ?? '').toString(),
      bio: (map['bio'] ?? '').toString(),
      ownerUsername: (map['owner_username'] ?? '').toString(),
      totalMembers: (map['total_members'] ?? 0) as int,
      isOwner: (map['is_owner'] ?? false) as bool,
      isMember: (map['is_member'] ?? false) as bool,
      isMyCurrent: (map['is_my_current'] ?? false) as bool,
    );
  }
}

class CommunityOverview {
  final Community? myCurrent;
  final List<Community> communities;

  CommunityOverview({
    required this.myCurrent,
    required this.communities,
  });

  factory CommunityOverview.fromJson(dynamic raw) {
    // 1) list langsung
    if (raw is List) {
      final list = raw
          .map((e) => Community.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
      return CommunityOverview(myCurrent: null, communities: list);
    }

    // 2) bentuk map { ok, my_current, communities }
    if (raw is Map) {
      final map = raw.cast<String, dynamic>();
      final myCurrentJson = map['my_current'];
      final myCurrent = myCurrentJson == null
          ? null
          : Community.fromJson((myCurrentJson as Map).cast<String, dynamic>());

      final listJson = (map['communities'] ?? map['data'] ?? []) as List;
      final list = listJson
          .map((e) => Community.fromJson((e as Map).cast<String, dynamic>()))
          .toList();

      return CommunityOverview(myCurrent: myCurrent, communities: list);
    }

    throw Exception('Format response community tidak dikenali');
  }
}
