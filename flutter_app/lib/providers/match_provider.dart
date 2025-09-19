import 'package:flutter/foundation.dart';
import '../models/match.dart';
import '../models/player.dart';
import '../models/battle_submission.dart';

class MatchProvider extends ChangeNotifier {
  Match? _currentMatch;
  List<Match> _matches = [];
  List<Player> _matchPlayers = [];
  List<BattleSubmission> _submissions = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  Match? get currentMatch => _currentMatch;
  List<Match> get matches => _matches;
  List<Player> get matchPlayers => _matchPlayers;
  List<BattleSubmission> get submissions => _submissions;
  bool get isLoading => _isLoading;
  String get error => _error;

  // Match status
  bool get isMatchActive => _currentMatch?.isActive ?? false;
  bool get isMatchCompleted => _currentMatch?.isCompleted ?? false;
  bool get canStartMatch => _currentMatch?.canStart ?? false;

  // Team data
  List<Player> get alphaPlayers => _matchPlayers.where((p) => p.team == 'Alpha').toList();
  List<Player> get deltaPlayers => _matchPlayers.where((p) => p.team == 'Delta').toList();
  Player? get alphaLeader => alphaPlayers.where((p) => p.role == 'Leader').firstOrNull;
  Player? get deltaLeader => deltaPlayers.where((p) => p.role == 'Leader').firstOrNull;

  // Battle data
  Map<String, List<Player>> get battleAssignments {
    final assignments = <String, List<Player>>{};
    
    for (final player in _matchPlayers) {
      if (player.subTeam != null) {
        final battleId = _getBattleIdForSubTeam(player.subTeam!);
        assignments[battleId] = assignments[battleId] ?? [];
        assignments[battleId]!.add(player);
      }
    }
    
    return assignments;
  }

  // Set current match
  void setCurrentMatch(Match match) {
    _currentMatch = match;
    notifyListeners();
  }

  // Add match
  void addMatch(Match match) {
    _matches.add(match);
    notifyListeners();
  }

  // Update match
  void updateMatch(Match match) {
    final index = _matches.indexWhere((m) => m.id == match.id);
    if (index != -1) {
      _matches[index] = match;
    }
    
    if (_currentMatch?.id == match.id) {
      _currentMatch = match;
    }
    
    notifyListeners();
  }

  // Set match players
  void setMatchPlayers(List<Player> players) {
    _matchPlayers = players;
    notifyListeners();
  }

  // Add player to match
  void addPlayerToMatch(Player player) {
    _matchPlayers.add(player);
    notifyListeners();
  }

  // Update player in match
  void updatePlayerInMatch(Player player) {
    final index = _matchPlayers.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _matchPlayers[index] = player;
      notifyListeners();
    }
  }

  // Remove player from match
  void removePlayerFromMatch(String playerId) {
    _matchPlayers.removeWhere((p) => p.id == playerId);
    notifyListeners();
  }

  // Set submissions
  void setSubmissions(List<BattleSubmission> submissions) {
    _submissions = submissions;
    notifyListeners();
  }

  // Add submission
  void addSubmission(BattleSubmission submission) {
    _submissions.add(submission);
    notifyListeners();
  }

  // Update submission
  void updateSubmission(BattleSubmission submission) {
    final index = _submissions.indexWhere((s) => s.id == submission.id);
    if (index != -1) {
      _submissions[index] = submission;
      notifyListeners();
    }
  }

  // Get submissions for battle
  List<BattleSubmission> getSubmissionsForBattle(String battleId) {
    return _submissions.where((s) => s.battleId == battleId).toList();
  }

  // Get submissions for team
  List<BattleSubmission> getSubmissionsForTeam(String team) {
    return _submissions.where((s) => s.team == team).toList();
  }

  // Get submission for team and battle
  BattleSubmission? getSubmissionForTeamAndBattle(String team, String battleId) {
    try {
      return _submissions.firstWhere(
        (s) => s.team == team && s.battleId == battleId,
      );
    } catch (e) {
      return null;
    }
  }

  // Battle status
  Map<String, Map<String, String>> get battleStatus {
    final status = <String, Map<String, String>>{};
    
    const battles = [
      'leadership_recon',
      'product_arsenal',
      'funding_fortification',
      'customer_frontlines',
      'alliance_forge',
    ];
    
    for (final battleId in battles) {
      status[battleId] = {
        'alpha': 'waiting',
        'delta': 'waiting',
      };
      
      final alphaSubmission = getSubmissionForTeamAndBattle('Alpha', battleId);
      final deltaSubmission = getSubmissionForTeamAndBattle('Delta', battleId);
      
      if (alphaSubmission != null) {
        status[battleId]!['alpha'] = 'completed';
      }
      
      if (deltaSubmission != null) {
        status[battleId]!['delta'] = 'completed';
      }
    }
    
    return status;
  }

  // Team scores
  Map<String, double> get teamScores {
    final scores = <String, double>{
      'Alpha': 0.0,
      'Delta': 0.0,
    };
    
    for (final submission in _submissions) {
      final currentScore = scores[submission.team] ?? 0.0;
      scores[submission.team] = currentScore + (submission.scores?.total ?? 0.0);
    }
    
    return scores;
  }

  // Battle completion status
  bool isBattleCompleted(String battleId) {
    final alphaSubmission = getSubmissionForTeamAndBattle('Alpha', battleId);
    final deltaSubmission = getSubmissionForTeamAndBattle('Delta', battleId);
    return alphaSubmission != null && deltaSubmission != null;
  }

  // All battles completed
  bool get allBattlesCompleted {
    const battles = [
      'leadership_recon',
      'product_arsenal',
      'funding_fortification',
      'customer_frontlines',
      'alliance_forge',
    ];
    
    return battles.every((battleId) => isBattleCompleted(battleId));
  }

  // Get battle winner
  String? getBattleWinner(String battleId) {
    final alphaSubmission = getSubmissionForTeamAndBattle('Alpha', battleId);
    final deltaSubmission = getSubmissionForTeamAndBattle('Delta', battleId);
    
    if (alphaSubmission == null || deltaSubmission == null) {
      return null;
    }
    
    final alphaScore = alphaSubmission.scores?.total ?? 0.0;
    final deltaScore = deltaSubmission.scores?.total ?? 0.0;
    
    if (alphaScore > deltaScore) {
      return 'Alpha';
    } else if (deltaScore > alphaScore) {
      return 'Delta';
    } else {
      return 'Tie';
    }
  }

  // Get overall winner
  String? get overallWinner {
    final scores = teamScores;
    final alphaScore = scores['Alpha'] ?? 0.0;
    final deltaScore = scores['Delta'] ?? 0.0;
    
    if (alphaScore > deltaScore) {
      return 'Alpha';
    } else if (deltaScore > alphaScore) {
      return 'Delta';
    } else {
      return 'Tie';
    }
  }

  // Get battle statistics
  Map<String, dynamic> get battleStats {
    final stats = <String, dynamic>{
      'totalBattles': 5,
      'completedBattles': 0,
      'alphaWins': 0,
      'deltaWins': 0,
      'ties': 0,
    };
    
    const battles = [
      'leadership_recon',
      'product_arsenal',
      'funding_fortification',
      'customer_frontlines',
      'alliance_forge',
    ];
    
    for (final battleId in battles) {
      if (isBattleCompleted(battleId)) {
        stats['completedBattles'] = (stats['completedBattles'] as int) + 1;
        
        final winner = getBattleWinner(battleId);
        if (winner == 'Alpha') {
          stats['alphaWins'] = (stats['alphaWins'] as int) + 1;
        } else if (winner == 'Delta') {
          stats['deltaWins'] = (stats['deltaWins'] as int) + 1;
        } else {
          stats['ties'] = (stats['ties'] as int) + 1;
        }
      }
    }
    
    return stats;
  }

  // Get time remaining
  int get timeRemaining {
    if (_currentMatch == null || _currentMatch!.startTime == null) {
      return 0;
    }
    
    final startTime = _currentMatch!.startTime!;
    final endTime = startTime.add(Duration(minutes: _currentMatch!.durationMinutes));
    final now = DateTime.now();
    
    if (now.isAfter(endTime)) {
      return 0;
    }
    
    return endTime.difference(now).inMinutes;
  }

  // Get progress percentage
  double get progressPercentage {
    if (_currentMatch == null) return 0.0;
    
    final totalTime = _currentMatch!.durationMinutes;
    final remaining = timeRemaining;
    final elapsed = totalTime - remaining;
    
    return (elapsed / totalTime).clamp(0.0, 1.0);
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = '';
    notifyListeners();
  }

  // Helper method to get battle ID for sub-team
  String _getBattleIdForSubTeam(String subTeam) {
    const battleMap = {
      'A1': 'leadership_recon',
      'A2': 'product_arsenal',
      'A3': 'funding_fortification',
      'A4': 'customer_frontlines',
      'A5': 'alliance_forge',
      'D1': 'leadership_recon',
      'D2': 'product_arsenal',
      'D3': 'funding_fortification',
      'D4': 'customer_frontlines',
      'D5': 'alliance_forge',
    };
    
    return battleMap[subTeam] ?? 'leadership_recon';
  }

  // Clear current match
  void clearCurrentMatch() {
    _currentMatch = null;
    _matchPlayers.clear();
    _submissions.clear();
    notifyListeners();
  }

  // Reset provider
  void reset() {
    _currentMatch = null;
    _matches.clear();
    _matchPlayers.clear();
    _submissions.clear();
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
