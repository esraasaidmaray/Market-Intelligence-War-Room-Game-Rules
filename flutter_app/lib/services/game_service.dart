import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../models/battle_submission.dart';
import '../models/company_reference.dart';

class GameService {
  static const String _playersKey = 'players';
  static const String _matchesKey = 'matches';
  static const String _submissionsKey = 'submissions';
  static const String _companyReferenceKey = 'company_reference';
  
  final Uuid _uuid = const Uuid();

  // Player operations
  Future<Player> createPlayer({
    required String name,
    required String team,
    required String role,
    String? avatar,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final player = Player(
      id: _uuid.v4(),
      name: name,
      team: team,
      role: role,
      avatar: avatar ?? 'agent1',
      createdAt: DateTime.now(),
    );
    
    final players = await getPlayers();
    players.add(player);
    await _savePlayers(players);
    
    return player;
  }

  Future<List<Player>> getPlayers() async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = prefs.getStringList(_playersKey) ?? [];
    
    return playersJson
        .map((json) => Player.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<Player?> getPlayer(String id) async {
    final players = await getPlayers();
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updatePlayer(String id, Map<String, dynamic> updates) async {
    final players = await getPlayers();
    final index = players.indexWhere((p) => p.id == id);
    
    if (index != -1) {
      final player = players[index];
      final updatedPlayer = Player(
        id: player.id,
        name: updates['name'] ?? player.name,
        team: updates['team'] ?? player.team,
        role: updates['role'] ?? player.role,
        subTeam: updates['sub_team'] ?? player.subTeam,
        matchId: updates['match_id'] ?? player.matchId,
        avatar: updates['avatar'] ?? player.avatar,
        status: updates['status'] ?? player.status,
        createdAt: player.createdAt,
      );
      
      players[index] = updatedPlayer;
      await _savePlayers(players);
    }
  }

  Future<void> deletePlayer(String id) async {
    final players = await getPlayers();
    players.removeWhere((p) => p.id == id);
    await _savePlayers(players);
  }

  // Match operations
  Future<Match> createMatch({
    required String company,
    required String createdBy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final match = Match(
      id: _uuid.v4(),
      matchId: 'match_${DateTime.now().millisecondsSinceEpoch}_${_uuid.v4().substring(0, 8)}',
      company: company,
      createdAt: DateTime.now(),
    );
    
    final matches = await getMatches();
    matches.add(match);
    await _saveMatches(matches);
    
    return match;
  }

  Future<List<Match>> getMatches() async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = prefs.getStringList(_matchesKey) ?? [];
    
    return matchesJson
        .map((json) => Match.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<Match?> getMatch(String matchId) async {
    final matches = await getMatches();
    try {
      return matches.firstWhere((m) => m.matchId == matchId);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateMatch(String id, Map<String, dynamic> updates) async {
    final matches = await getMatches();
    final index = matches.indexWhere((m) => m.id == id);
    
    if (index != -1) {
      final match = matches[index];
      final updatedMatch = Match(
        id: match.id,
        matchId: match.matchId,
        company: updates['company'] ?? match.company,
        status: updates['status'] ?? match.status,
        startTime: updates['start_time'] != null 
            ? DateTime.parse(updates['start_time']) 
            : match.startTime,
        durationMinutes: updates['duration_minutes'] ?? match.durationMinutes,
        alphaLeaderReady: updates['alpha_leader_ready'] ?? match.alphaLeaderReady,
        deltaLeaderReady: updates['delta_leader_ready'] ?? match.deltaLeaderReady,
        alphaScore: updates['alpha_score'] ?? match.alphaScore,
        deltaScore: updates['delta_score'] ?? match.deltaScore,
        battles: match.battles,
        createdAt: match.createdAt,
      );
      
      matches[index] = updatedMatch;
      await _saveMatches(matches);
    }
  }

  Future<void> deleteMatch(String id) async {
    final matches = await getMatches();
    matches.removeWhere((m) => m.id == id);
    await _saveMatches(matches);
  }

  // Battle submission operations
  Future<BattleSubmission> submitBattleData({
    required String matchId,
    required String battleId,
    required String team,
    required String subTeam,
    required Map<String, dynamic> submissionData,
    required List<Source> sources,
    required int timeRemaining,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final submission = BattleSubmission(
      id: _uuid.v4(),
      matchId: matchId,
      battleId: battleId,
      team: team,
      subTeam: subTeam,
      submissionData: submissionData,
      submittedAt: DateTime.now(),
      timeRemaining: timeRemaining,
      sources: sources,
      scores: await _calculateScores(submissionData, battleId, sources, timeRemaining),
    );
    
    final submissions = await getSubmissions();
    submissions.add(submission);
    await _saveSubmissions(submissions);
    
    return submission;
  }

  Future<List<BattleSubmission>> getSubmissions() async {
    final prefs = await SharedPreferences.getInstance();
    final submissionsJson = prefs.getStringList(_submissionsKey) ?? [];
    
    return submissionsJson
        .map((json) => BattleSubmission.fromJson(jsonDecode(json)))
        .toList();
  }

  Future<List<BattleSubmission>> getMatchSubmissions(String matchId) async {
    final submissions = await getSubmissions();
    return submissions.where((s) => s.matchId == matchId).toList();
  }

  Future<BattleSubmission?> getSubmission(String id) async {
    final submissions = await getSubmissions();
    try {
      return submissions.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> updateSubmission(String id, Map<String, dynamic> updates) async {
    final submissions = await getSubmissions();
    final index = submissions.indexWhere((s) => s.id == id);
    
    if (index != -1) {
      final submission = submissions[index];
      final updatedSubmission = BattleSubmission(
        id: submission.id,
        matchId: submission.matchId,
        battleId: submission.battleId,
        team: submission.team,
        subTeam: submission.subTeam,
        submissionData: updates['submission_data'] ?? submission.submissionData,
        submittedAt: updates['submitted_at'] != null 
            ? DateTime.parse(updates['submitted_at']) 
            : submission.submittedAt,
        timeRemaining: updates['time_remaining'] ?? submission.timeRemaining,
        sources: submission.sources,
        scores: updates['scores'] != null 
            ? BattleScores.fromJson(updates['scores']) 
            : submission.scores,
      );
      
      submissions[index] = updatedSubmission;
      await _saveSubmissions(submissions);
    }
  }

  Future<void> deleteSubmission(String id) async {
    final submissions = await getSubmissions();
    submissions.removeWhere((s) => s.id == id);
    await _saveSubmissions(submissions);
  }

  // Company reference operations
  Future<CompanyReference?> getCompanyReference() async {
    final prefs = await SharedPreferences.getInstance();
    final referenceJson = prefs.getString(_companyReferenceKey);
    
    if (referenceJson != null) {
      return CompanyReference.fromJson(jsonDecode(referenceJson));
    }
    
    return null;
  }

  Future<void> saveCompanyReference(CompanyReference reference) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_companyReferenceKey, jsonEncode(reference.toJson()));
  }

  // Helper methods for data persistence
  Future<void> _savePlayers(List<Player> players) async {
    final prefs = await SharedPreferences.getInstance();
    final playersJson = players
        .map((player) => jsonEncode(player.toJson()))
        .toList();
    await prefs.setStringList(_playersKey, playersJson);
  }

  Future<void> _saveMatches(List<Match> matches) async {
    final prefs = await SharedPreferences.getInstance();
    final matchesJson = matches
        .map((match) => jsonEncode(match.toJson()))
        .toList();
    await prefs.setStringList(_matchesKey, matchesJson);
  }

  Future<void> _saveSubmissions(List<BattleSubmission> submissions) async {
    final prefs = await SharedPreferences.getInstance();
    final submissionsJson = submissions
        .map((submission) => jsonEncode(submission.toJson()))
        .toList();
    await prefs.setStringList(_submissionsKey, submissionsJson);
  }

  // Scoring engine
  Future<BattleScores> _calculateScores(
    Map<String, dynamic> submissionData,
    String battleId,
    List<Source> sources,
    int timeRemaining,
  ) async {
    // Get reference data
    final reference = await getCompanyReference();
    if (reference == null) {
      return BattleScores(
        dataAccuracy: 0.0,
        speed: 0.0,
        sourceQuality: 0.0,
        teamwork: 0.0,
        total: 0.0,
      );
    }

    // Calculate data accuracy (60% weight)
    final dataAccuracy = _calculateDataAccuracy(submissionData, reference, battleId);
    
    // Calculate speed score (10% weight)
    final speed = _calculateSpeedScore(timeRemaining);
    
    // Calculate source quality (15% weight)
    final sourceQuality = _calculateSourceQuality(sources);
    
    // Calculate teamwork score (15% weight)
    final teamwork = _calculateTeamworkScore();

    // Calculate final score
    final total = (dataAccuracy * 0.60) + (speed * 0.10) + (sourceQuality * 0.15) + (teamwork * 0.15);

    return BattleScores(
      dataAccuracy: dataAccuracy,
      speed: speed,
      sourceQuality: sourceQuality,
      teamwork: teamwork,
      total: total,
    );
  }

  double _calculateDataAccuracy(
    Map<String, dynamic> submissionData,
    CompanyReference reference,
    String battleId,
  ) {
    // This is a simplified version of the scoring algorithm
    // In a real implementation, you would compare each field with reference data
    double accuracy = 0.0;
    int fieldCount = 0;

    // Get reference data based on battle type
    Map<String, dynamic> referenceData = {};
    switch (battleId) {
      case 'leadership_recon':
        referenceData = reference.battle1Leadership.toJson();
        break;
      case 'product_arsenal':
        referenceData = reference.battle2Products.toJson();
        break;
      case 'funding_fortification':
        referenceData = reference.battle3Funding.toJson();
        break;
      case 'customer_frontlines':
        referenceData = reference.battle4Customers.toJson();
        break;
      case 'alliance_forge':
        referenceData = reference.battle5Partnerships.toJson();
        break;
    }

    // Compare fields (simplified comparison)
    for (final key in submissionData.keys) {
      if (submissionData[key] != null && submissionData[key].toString().isNotEmpty) {
        fieldCount++;
        // Simple string similarity check
        if (_calculateStringSimilarity(
          submissionData[key].toString(),
          _getReferenceValue(referenceData, key),
        ) > 0.7) {
          accuracy += 1.0;
        }
      }
    }

    return fieldCount > 0 ? (accuracy / fieldCount) * 100 : 0.0;
  }

  double _calculateSpeedScore(int timeRemaining) {
    // Speed score based on time remaining (0-100)
    return (timeRemaining / 60.0 * 100).clamp(0.0, 100.0);
  }

  double _calculateSourceQuality(List<Source> sources) {
    if (sources.isEmpty) return 0.0;

    const trustedDomains = [
      'linkedin.com',
      'crunchbase.com',
      'pitchbook.com',
      'statista.com',
      'sec.gov',
      'reuters.com',
      'bloomberg.com',
    ];

    double totalScore = 0.0;
    for (final source in sources) {
      double sourceScore = 0.0;
      
      // Check if domain is trusted
      try {
        final uri = Uri.parse(source.url);
        final domain = uri.host.toLowerCase();
        if (trustedDomains.any((trusted) => domain.contains(trusted))) {
          sourceScore += 70.0;
        }
      } catch (e) {
        // Invalid URL
      }
      
      // Check description quality
      if (source.description.length > 10) {
        sourceScore += 30.0;
      }
      
      totalScore += sourceScore;
    }

    return (totalScore / sources.length).clamp(0.0, 100.0);
  }

  double _calculateTeamworkScore() {
    // Simplified teamwork score
    // In a real implementation, this would consider chat activity, collaboration, etc.
    return 75.0; // Default score
  }

  double _calculateStringSimilarity(String str1, String str2) {
    if (str1.isEmpty || str2.isEmpty) return 0.0;
    
    final s1 = str1.toLowerCase().trim();
    final s2 = str2.toLowerCase().trim();
    
    if (s1 == s2) return 1.0;
    
    // Simple Levenshtein distance calculation
    final matrix = List.generate(
      s2.length + 1,
      (i) => List.generate(s1.length + 1, (j) => 0),
    );
    
    for (int i = 0; i <= s2.length; i++) {
      matrix[i][0] = i;
    }
    for (int j = 0; j <= s1.length; j++) {
      matrix[0][j] = j;
    }
    
    for (int i = 1; i <= s2.length; i++) {
      for (int j = 1; j <= s1.length; j++) {
        if (s2[i - 1] == s1[j - 1]) {
          matrix[i][j] = matrix[i - 1][j - 1];
        } else {
          matrix[i][j] = [
            matrix[i - 1][j - 1],
            matrix[i][j - 1],
            matrix[i - 1][j],
          ].reduce((a, b) => a < b ? a : b) + 1;
        }
      }
    }
    
    final distance = matrix[s2.length][s1.length];
    final maxLength = s1.length > s2.length ? s1.length : s2.length;
    
    return maxLength > 0 ? (maxLength - distance) / maxLength : 0.0;
  }

  String _getReferenceValue(Map<String, dynamic> referenceData, String key) {
    // Simplified reference value extraction
    // In a real implementation, this would use the complex mapping from the web app
    return referenceData[key]?.toString() ?? '';
  }

  // Utility methods
  Future<List<Player>> getMatchPlayers(String matchId) async {
    final players = await getPlayers();
    return players.where((p) => p.matchId == matchId).toList();
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_playersKey);
    await prefs.remove(_matchesKey);
    await prefs.remove(_submissionsKey);
    await prefs.remove(_companyReferenceKey);
  }
}
