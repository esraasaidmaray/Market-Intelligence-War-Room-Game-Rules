class BattleSubmission {
  final String id;
  final String matchId;
  final String battleId;
  final String team;
  final String subTeam;
  final Map<String, dynamic> submissionData;
  final DateTime submittedAt;
  final int timeRemaining;
  final List<Source> sources;
  final BattleScores? scores;

  BattleSubmission({
    required this.id,
    required this.matchId,
    required this.battleId,
    required this.team,
    required this.subTeam,
    required this.submissionData,
    required this.submittedAt,
    required this.timeRemaining,
    this.sources = const [],
    this.scores,
  });

  factory BattleSubmission.fromJson(Map<String, dynamic> json) {
    return BattleSubmission(
      id: json['id'] ?? '',
      matchId: json['match_id'] ?? '',
      battleId: json['battle_id'] ?? '',
      team: json['team'] ?? '',
      subTeam: json['sub_team'] ?? '',
      submissionData: Map<String, dynamic>.from(json['submission_data'] ?? {}),
      submittedAt: DateTime.parse(json['submitted_at'] ?? DateTime.now().toIso8601String()),
      timeRemaining: json['time_remaining'] ?? 0,
      sources: (json['sources'] as List<dynamic>?)
          ?.map((source) => Source.fromJson(source))
          .toList() ?? [],
      scores: json['scores'] != null ? BattleScores.fromJson(json['scores']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'match_id': matchId,
      'battle_id': battleId,
      'team': team,
      'sub_team': subTeam,
      'submission_data': submissionData,
      'submitted_at': submittedAt.toIso8601String(),
      'time_remaining': timeRemaining,
      'sources': sources.map((source) => source.toJson()).toList(),
      'scores': scores?.toJson(),
    };
  }

  BattleSubmission copyWith({
    String? id,
    String? matchId,
    String? battleId,
    String? team,
    String? subTeam,
    Map<String, dynamic>? submissionData,
    DateTime? submittedAt,
    int? timeRemaining,
    List<Source>? sources,
    BattleScores? scores,
  }) {
    return BattleSubmission(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      battleId: battleId ?? this.battleId,
      team: team ?? this.team,
      subTeam: subTeam ?? this.subTeam,
      submissionData: submissionData ?? this.submissionData,
      submittedAt: submittedAt ?? this.submittedAt,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      sources: sources ?? this.sources,
      scores: scores ?? this.scores,
    );
  }

  @override
  String toString() {
    return 'BattleSubmission(id: $id, battleId: $battleId, team: $team, subTeam: $subTeam)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BattleSubmission && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

class Source {
  final String url;
  final String description;
  final double qualityScore;

  Source({
    required this.url,
    required this.description,
    this.qualityScore = 0.0,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      url: json['url'] ?? '',
      description: json['description'] ?? '',
      qualityScore: (json['quality_score'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'description': description,
      'quality_score': qualityScore,
    };
  }

  Source copyWith({
    String? url,
    String? description,
    double? qualityScore,
  }) {
    return Source(
      url: url ?? this.url,
      description: description ?? this.description,
      qualityScore: qualityScore ?? this.qualityScore,
    );
  }
}

class BattleScores {
  final double dataAccuracy;
  final double speed;
  final double sourceQuality;
  final double teamwork;
  final double total;

  BattleScores({
    required this.dataAccuracy,
    required this.speed,
    required this.sourceQuality,
    required this.teamwork,
    required this.total,
  });

  factory BattleScores.fromJson(Map<String, dynamic> json) {
    return BattleScores(
      dataAccuracy: (json['data_accuracy'] ?? 0.0).toDouble(),
      speed: (json['speed'] ?? 0.0).toDouble(),
      sourceQuality: (json['source_quality'] ?? 0.0).toDouble(),
      teamwork: (json['teamwork'] ?? 0.0).toDouble(),
      total: (json['total'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data_accuracy': dataAccuracy,
      'speed': speed,
      'source_quality': sourceQuality,
      'teamwork': teamwork,
      'total': total,
    };
  }

  BattleScores copyWith({
    double? dataAccuracy,
    double? speed,
    double? sourceQuality,
    double? teamwork,
    double? total,
  }) {
    return BattleScores(
      dataAccuracy: dataAccuracy ?? this.dataAccuracy,
      speed: speed ?? this.speed,
      sourceQuality: sourceQuality ?? this.sourceQuality,
      teamwork: teamwork ?? this.teamwork,
      total: total ?? this.total,
    );
  }
}
