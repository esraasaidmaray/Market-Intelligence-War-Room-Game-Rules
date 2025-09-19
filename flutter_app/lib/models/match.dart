class Match {
  final String id;
  final String matchId;
  final String? company;
  final String status;
  final DateTime? startTime;
  final int durationMinutes;
  final bool alphaLeaderReady;
  final bool deltaLeaderReady;
  final int alphaScore;
  final int deltaScore;
  final List<Battle> battles;
  final DateTime createdAt;

  Match({
    required this.id,
    required this.matchId,
    this.company,
    this.status = 'setup',
    this.startTime,
    this.durationMinutes = 60,
    this.alphaLeaderReady = false,
    this.deltaLeaderReady = false,
    this.alphaScore = 0,
    this.deltaScore = 0,
    this.battles = const [],
    required this.createdAt,
  });

  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] ?? '',
      matchId: json['match_id'] ?? '',
      company: json['company'],
      status: json['status'] ?? 'setup',
      startTime: json['start_time'] != null 
          ? DateTime.parse(json['start_time']) 
          : null,
      durationMinutes: json['duration_minutes'] ?? 60,
      alphaLeaderReady: json['alpha_leader_ready'] ?? false,
      deltaLeaderReady: json['delta_leader_ready'] ?? false,
      alphaScore: json['alpha_score'] ?? 0,
      deltaScore: json['delta_score'] ?? 0,
      battles: (json['battles'] as List<dynamic>?)
          ?.map((battle) => Battle.fromJson(battle))
          .toList() ?? [],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'company': company,
      'status': status,
      'start_time': startTime?.toIso8601String(),
      'duration_minutes': durationMinutes,
      'alpha_leader_ready': alphaLeaderReady,
      'delta_leader_ready': deltaLeaderReady,
      'alpha_score': alphaScore,
      'delta_score': deltaScore,
      'battles': battles.map((battle) => battle.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  Match copyWith({
    String? id,
    String? matchId,
    String? company,
    String? status,
    DateTime? startTime,
    int? durationMinutes,
    bool? alphaLeaderReady,
    bool? deltaLeaderReady,
    int? alphaScore,
    int? deltaScore,
    List<Battle>? battles,
    DateTime? createdAt,
  }) {
    return Match(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      company: company ?? this.company,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      alphaLeaderReady: alphaLeaderReady ?? this.alphaLeaderReady,
      deltaLeaderReady: deltaLeaderReady ?? this.deltaLeaderReady,
      alphaScore: alphaScore ?? this.alphaScore,
      deltaScore: deltaScore ?? this.deltaScore,
      battles: battles ?? this.battles,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get canStart => alphaLeaderReady && deltaLeaderReady && status == 'setup';
  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';

  @override
  String toString() {
    return 'Match(id: $id, matchId: $matchId, company: $company, status: $status)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Match && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Battle {
  final String battleId;
  final String name;
  final List<String> subTeams;
  final String status;
  final Map<String, dynamic>? alphaSubmission;
  final Map<String, dynamic>? deltaSubmission;

  Battle({
    required this.battleId,
    required this.name,
    required this.subTeams,
    this.status = 'waiting',
    this.alphaSubmission,
    this.deltaSubmission,
  });

  factory Battle.fromJson(Map<String, dynamic> json) {
    return Battle(
      battleId: json['battle_id'] ?? '',
      name: json['name'] ?? '',
      subTeams: List<String>.from(json['sub_teams'] ?? []),
      status: json['status'] ?? 'waiting',
      alphaSubmission: json['alpha_submission'],
      deltaSubmission: json['delta_submission'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'battle_id': battleId,
      'name': name,
      'sub_teams': subTeams,
      'status': status,
      'alpha_submission': alphaSubmission,
      'delta_submission': deltaSubmission,
    };
  }

  Battle copyWith({
    String? battleId,
    String? name,
    List<String>? subTeams,
    String? status,
    Map<String, dynamic>? alphaSubmission,
    Map<String, dynamic>? deltaSubmission,
  }) {
    return Battle(
      battleId: battleId ?? this.battleId,
      name: name ?? this.name,
      subTeams: subTeams ?? this.subTeams,
      status: status ?? this.status,
      alphaSubmission: alphaSubmission ?? this.alphaSubmission,
      deltaSubmission: deltaSubmission ?? this.deltaSubmission,
    );
  }
}
