class Player {
  final String id;
  final String name;
  final String team;
  final String role;
  final String? subTeam;
  final String? matchId;
  final String avatar;
  final String status;
  final DateTime createdAt;

  Player({
    required this.id,
    required this.name,
    required this.team,
    required this.role,
    this.subTeam,
    this.matchId,
    this.avatar = 'agent1',
    this.status = 'waiting',
    required this.createdAt,
  });

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      team: json['team'] ?? '',
      role: json['role'] ?? '',
      subTeam: json['sub_team'],
      matchId: json['match_id'],
      avatar: json['avatar'] ?? 'agent1',
      status: json['status'] ?? 'waiting',
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'team': team,
      'role': role,
      'sub_team': subTeam,
      'match_id': matchId,
      'avatar': avatar,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Player copyWith({
    String? id,
    String? name,
    String? team,
    String? role,
    String? subTeam,
    String? matchId,
    String? avatar,
    String? status,
    DateTime? createdAt,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      team: team ?? this.team,
      role: role ?? this.role,
      subTeam: subTeam ?? this.subTeam,
      matchId: matchId ?? this.matchId,
      avatar: avatar ?? this.avatar,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Player(id: $id, name: $name, team: $team, role: $role, subTeam: $subTeam, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Player && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
