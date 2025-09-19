import 'package:flutter/foundation.dart';
import '../models/player.dart';

class PlayerProvider extends ChangeNotifier {
  Player? _currentPlayer;
  List<Player> _players = [];
  bool _isLoading = false;
  String _error = '';

  // Getters
  Player? get currentPlayer => _currentPlayer;
  List<Player> get players => _players;
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isLoggedIn => _currentPlayer != null;

  // Team getters
  List<Player> get alphaPlayers => _players.where((p) => p.team == 'Alpha').toList();
  List<Player> get deltaPlayers => _players.where((p) => p.team == 'Delta').toList();
  Player? get alphaLeader => alphaPlayers.where((p) => p.role == 'Leader').firstOrNull;
  Player? get deltaLeader => deltaPlayers.where((p) => p.role == 'Leader').firstOrNull;

  // Set current player
  void setCurrentPlayer(Player player) {
    _currentPlayer = player;
    notifyListeners();
  }

  // Add player to list
  void addPlayer(Player player) {
    _players.add(player);
    notifyListeners();
  }

  // Update player
  void updatePlayer(Player player) {
    final index = _players.indexWhere((p) => p.id == player.id);
    if (index != -1) {
      _players[index] = player;
      if (_currentPlayer?.id == player.id) {
        _currentPlayer = player;
      }
      notifyListeners();
    }
  }

  // Remove player
  void removePlayer(String playerId) {
    _players.removeWhere((p) => p.id == playerId);
    if (_currentPlayer?.id == playerId) {
      _currentPlayer = null;
    }
    notifyListeners();
  }

  // Clear all players
  void clearPlayers() {
    _players.clear();
    _currentPlayer = null;
    notifyListeners();
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

  // Get player by ID
  Player? getPlayerById(String id) {
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get players by team
  List<Player> getPlayersByTeam(String team) {
    return _players.where((p) => p.team == team).toList();
  }

  // Get players by role
  List<Player> getPlayersByRole(String role) {
    return _players.where((p) => p.role == role).toList();
  }

  // Get players by status
  List<Player> getPlayersByStatus(String status) {
    return _players.where((p) => p.status == status).toList();
  }

  // Get available sub-teams for a team
  List<String> getAvailableSubTeams(String team) {
    const subTeams = {
      'Alpha': ['A1', 'A2', 'A3', 'A4', 'A5'],
      'Delta': ['D1', 'D2', 'D3', 'D4', 'D5'],
    };
    
    final usedSubTeams = _players
        .where((p) => p.team == team && p.subTeam != null)
        .map((p) => p.subTeam!)
        .toList();
    
    return subTeams[team]!
        .where((subTeam) => !usedSubTeams.contains(subTeam))
        .toList();
  }

  // Check if player is leader
  bool isPlayerLeader(String playerId) {
    final player = getPlayerById(playerId);
    return player?.role == 'Leader';
  }

  // Check if player is in team
  bool isPlayerInTeam(String playerId, String team) {
    final player = getPlayerById(playerId);
    return player?.team == team;
  }

  // Get player's sub-team
  String? getPlayerSubTeam(String playerId) {
    final player = getPlayerById(playerId);
    return player?.subTeam;
  }

  // Get player's status
  String? getPlayerStatus(String playerId) {
    final player = getPlayerById(playerId);
    return player?.status;
  }

  // Update player status
  void updatePlayerStatus(String playerId, String status) {
    final player = getPlayerById(playerId);
    if (player != null) {
      final updatedPlayer = player.copyWith(status: status);
      updatePlayer(updatedPlayer);
    }
  }

  // Assign sub-team to player
  void assignSubTeam(String playerId, String subTeam) {
    final player = getPlayerById(playerId);
    if (player != null) {
      final updatedPlayer = player.copyWith(
        subTeam: subTeam,
        status: 'assigned',
      );
      updatePlayer(updatedPlayer);
    }
  }

  // Redeploy player to different sub-team
  void redeployPlayer(String playerId, String newSubTeam) {
    final player = getPlayerById(playerId);
    if (player != null) {
      final updatedPlayer = player.copyWith(
        subTeam: newSubTeam,
        status: 'redeployed',
      );
      updatePlayer(updatedPlayer);
    }
  }

  // Get completed players (for redeployment)
  List<Player> getCompletedPlayers(String team) {
    return _players
        .where((p) => p.team == team && p.status == 'completed' && p.role == 'Player')
        .toList();
  }

  // Get players assigned to specific sub-team
  List<Player> getPlayersBySubTeam(String subTeam) {
    return _players.where((p) => p.subTeam == subTeam).toList();
  }

  // Get battle assignment for sub-team
  String getBattleForSubTeam(String subTeam) {
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

  // Get sub-team for battle
  String getSubTeamForBattle(String battleId, String team) {
    const battleSubTeams = {
      'leadership_recon': {'Alpha': 'A1', 'Delta': 'D1'},
      'product_arsenal': {'Alpha': 'A2', 'Delta': 'D2'},
      'funding_fortification': {'Alpha': 'A3', 'Delta': 'D3'},
      'customer_frontlines': {'Alpha': 'A4', 'Delta': 'D4'},
      'alliance_forge': {'Alpha': 'A5', 'Delta': 'D5'},
    };
    
    return battleSubTeams[battleId]?[team] ?? '';
  }

  // Check if all players are assigned
  bool areAllPlayersAssigned() {
    return _players
        .where((p) => p.role == 'Player')
        .every((p) => p.subTeam != null && p.subTeam!.isNotEmpty);
  }

  // Get team statistics
  Map<String, int> getTeamStats(String team) {
    final teamPlayers = getPlayersByTeam(team);
    return {
      'total': teamPlayers.length,
      'leaders': teamPlayers.where((p) => p.role == 'Leader').length,
      'operatives': teamPlayers.where((p) => p.role == 'Player').length,
      'assigned': teamPlayers.where((p) => p.subTeam != null).length,
      'completed': teamPlayers.where((p) => p.status == 'completed').length,
      'active': teamPlayers.where((p) => p.status == 'in_battle').length,
    };
  }

  // Reset provider
  void reset() {
    _currentPlayer = null;
    _players.clear();
    _isLoading = false;
    _error = '';
    notifyListeners();
  }
}
