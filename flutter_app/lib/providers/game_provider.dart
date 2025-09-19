import 'package:flutter/foundation.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../models/battle_submission.dart';
import '../models/company_reference.dart';
import '../services/game_service.dart';

class GameProvider extends ChangeNotifier {
  final GameService _gameService = GameService();
  
  // Game state
  bool _isLoading = false;
  String _error = '';
  Player? _currentPlayer;
  Match? _currentMatch;
  List<Player> _players = [];
  List<BattleSubmission> _submissions = [];
  CompanyReference? _companyReference;
  
  // Game requirements state
  bool _alphaLeaderReady = false;
  bool _deltaLeaderReady = false;
  String? _selectedCompany;
  Map<String, Map<String, dynamic>> _battleTemplates = {};
  Map<String, bool> _battleCompletionStatus = {};
  Map<String, Map<String, dynamic>> _battleSubmissions = {};
  DateTime? _matchStartTime;
  int _matchDurationMinutes = 60;
  
  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  Player? get currentPlayer => _currentPlayer;
  Match? get currentMatch => _currentMatch;
  List<Player> get players => _players;
  List<BattleSubmission> get submissions => _submissions;
  CompanyReference? get companyReference => _companyReference;
  
  // Game requirements getters
  bool get alphaLeaderReady => _alphaLeaderReady;
  bool get deltaLeaderReady => _deltaLeaderReady;
  String? get selectedCompany => _selectedCompany;
  Map<String, Map<String, dynamic>> get battleTemplates => _battleTemplates;
  Map<String, bool> get battleCompletionStatus => _battleCompletionStatus;
  Map<String, Map<String, dynamic>> get battleSubmissions => _battleSubmissions;
  DateTime? get matchStartTime => _matchStartTime;
  int get matchDurationMinutes => _matchDurationMinutes;
  
  // Computed getters
  bool get canStartMatch => _alphaLeaderReady && _deltaLeaderReady && _selectedCompany != null;
  bool get isMatchActive => _matchStartTime != null;
  Duration? get timeRemaining {
    if (_matchStartTime == null) return null;
    final elapsed = DateTime.now().difference(_matchStartTime!);
    final remaining = Duration(minutes: _matchDurationMinutes) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }
  
  // Team getters
  List<Player> get alphaPlayers => _players.where((p) => p.team == 'Alpha').toList();
  List<Player> get deltaPlayers => _players.where((p) => p.team == 'Delta').toList();
  Player? get alphaLeader => alphaPlayers.where((p) => p.role == 'Leader').firstOrNull;
  Player? get deltaLeader => deltaPlayers.where((p) => p.role == 'Leader').firstOrNull;
  
  // Battle status
  Map<String, String> get battleStatus {
    final status = <String, String>{};
    for (final submission in _submissions) {
      final key = '${submission.team}_${submission.battleId}';
      status[key] = submission.submittedAt != null ? 'completed' : 'active';
    }
    return status;
  }
  
  // Initialize game
  Future<void> initializeGame() async {
    _setLoading(true);
    try {
      // Load sample company reference data
      await _loadCompanyReference();
      // Initialize battle templates
      _initializeBattleTemplates();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize game: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Player management
  Future<void> createPlayer({
    required String name,
    required String team,
    required String role,
    String? avatar,
  }) async {
    _setLoading(true);
    try {
      final player = await _gameService.createPlayer(
        name: name,
        team: team,
        role: role,
        avatar: avatar ?? 'agent1',
      );
      _currentPlayer = player;
      _clearError();
    } catch (e) {
      _setError('Failed to create player: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> joinMatch(String matchId) async {
    if (_currentPlayer == null) return;
    
    _setLoading(true);
    try {
      final updatedPlayer = _currentPlayer!.copyWith(matchId: matchId);
      _currentPlayer = updatedPlayer;
      await _loadMatchData(matchId);
      _clearError();
    } catch (e) {
      _setError('Failed to join match: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Match management
  Future<void> createMatch({required String company}) async {
    if (_currentPlayer == null) return;
    
    _setLoading(true);
    try {
      final match = await _gameService.createMatch(
        company: company,
        createdBy: _currentPlayer!.id,
      );
      _currentMatch = match;
      _currentPlayer = _currentPlayer!.copyWith(matchId: match.matchId);
      _clearError();
    } catch (e) {
      _setError('Failed to create match: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> loadMatchData(String matchId) async {
    _setLoading(true);
    try {
      await _loadMatchData(matchId);
      _clearError();
    } catch (e) {
      _setError('Failed to load match data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  Future<void> _loadMatchData(String matchId) async {
    final match = await _gameService.getMatch(matchId);
    _currentMatch = match;
    
    final players = await _gameService.getMatchPlayers(matchId);
    _players = players;
    
    final submissions = await _gameService.getMatchSubmissions(matchId);
    _submissions = submissions;
  }
  
  Future<void> updatePlayerStatus(String playerId, String status) async {
    try {
      await _gameService.updatePlayerStatus(playerId, status);
      final index = _players.indexWhere((p) => p.id == playerId);
      if (index != -1) {
        _players[index] = _players[index].copyWith(status: status);
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to update player status: $e');
    }
  }
  
  Future<void> assignSubTeam(String playerId, String subTeam) async {
    try {
      await _gameService.assignSubTeam(playerId, subTeam);
      final index = _players.indexWhere((p) => p.id == playerId);
      if (index != -1) {
        _players[index] = _players[index].copyWith(
          subTeam: subTeam,
          status: 'assigned',
        );
        notifyListeners();
      }
    } catch (e) {
      _setError('Failed to assign sub-team: $e');
    }
  }
  
  Future<void> toggleLeaderReady() async {
    if (_currentPlayer == null || _currentMatch == null) return;
    
    try {
      final isAlpha = _currentPlayer!.team == 'Alpha';
      final field = isAlpha ? 'alphaLeaderReady' : 'deltaLeaderReady';
      final newValue = isAlpha ? !_currentMatch!.alphaLeaderReady : !_currentMatch!.deltaLeaderReady;
      
      await _gameService.updateMatch(_currentMatch!.id, {field: newValue});
      
      _currentMatch = _currentMatch!.copyWith(
        alphaLeaderReady: isAlpha ? newValue : _currentMatch!.alphaLeaderReady,
        deltaLeaderReady: !isAlpha ? newValue : _currentMatch!.deltaLeaderReady,
      );
      
      notifyListeners();
    } catch (e) {
      _setError('Failed to update ready status: $e');
    }
  }
  
  Future<void> startMatch() async {
    if (_currentMatch == null) return;
    
    _setLoading(true);
    try {
      await _gameService.startMatch(_currentMatch!.id);
      _currentMatch = _currentMatch!.copyWith(
        status: 'active',
        startTime: DateTime.now(),
      );
      _clearError();
    } catch (e) {
      _setError('Failed to start match: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Battle submission
  Future<void> submitBattleData({
    required String battleId,
    required Map<String, dynamic> submissionData,
    required List<Source> sources,
  }) async {
    if (_currentPlayer == null || _currentMatch == null) return;
    
    _setLoading(true);
    try {
      final timeRemaining = _calculateTimeRemaining();
      
      final submission = await _gameService.submitBattleData(
        matchId: _currentMatch!.matchId,
        battleId: battleId,
        team: _currentPlayer!.team,
        subTeam: _currentPlayer!.subTeam ?? '',
        submissionData: submissionData,
        sources: sources,
        timeRemaining: timeRemaining,
      );
      
      _submissions.add(submission);
      await updatePlayerStatus(_currentPlayer!.id, 'completed');
      _clearError();
    } catch (e) {
      _setError('Failed to submit battle data: $e');
    } finally {
      _setLoading(false);
    }
  }
  
  // Company reference
  Future<void> _loadCompanyReference() async {
    try {
      _companyReference = await _gameService.getCompanyReference();
    } catch (e) {
      // Create default company reference if none exists
      _companyReference = _createDefaultCompanyReference();
    }
  }
  
  CompanyReference _createDefaultCompanyReference() {
    return CompanyReference(
      id: 'default',
      companyName: 'Fawry for Banking Technology and Electronic Payments S.A.E.',
      companyDescription: 'Egypt\'s leading provider of electronic payment solutions and digital financial services',
      battle1Leadership: LeadershipData(
        founders: [
          Founder(
            fullName: 'Ashraf Sabry',
            foundingYear: '2008',
            currentRole: 'Founder and CEO',
            previousVentures: 'Previously worked at IBM and other technology companies',
            linkedinUrl: 'https://linkedin.com/in/ashraf-sabry',
            notes: 'Leading digital transformation in Egypt\'s financial sector',
          ),
        ],
        keyExecutives: [
          KeyExecutive(
            name: 'Ahmed El Sobky',
            title: 'Chief Operating Officer',
            function: 'Operations',
            yearsWithFirm: '8',
            linkedinUrl: 'https://linkedin.com/in/ahmed-el-sobky',
            notes: 'Oversees day-to-day operations and business development',
          ),
        ],
        marketShare: MarketShare(
          tamUsd: '15 Billion',
          samUsd: '3 Billion',
          somUsd: '500 Million',
          annualGrowthRate: '25',
          competitiveRank: 1,
          companySharePercentage: '45',
          differentiators: 'First-mover advantage in Egypt, comprehensive payment ecosystem, strong government partnerships',
        ),
        geographicFootprint: [
          GeographicFootprint(
            location: 'Cairo, Egypt',
            openedYear: '2008',
            facilityType: 'Headquarters',
            notes: 'Main corporate headquarters and technology center',
          ),
        ],
      ),
      battle2Products: ProductsData(
        productLines: [
          ProductLine(
            productName: 'Fawry Plus',
            productType: 'Mobile Payment App',
            launchDate: '2019',
            category: 'Fintech',
            targetSegment: 'Consumers',
            keyFeatures: 'Bill payments, mobile top-ups, online shopping, peer-to-peer transfers',
            pricingModel: 'Transaction fees',
            reviewsScore: '4.2',
            primaryCompetitors: 'Vodafone Cash, Orange Money, Etisalat Cash',
          ),
        ],
        socialPresence: [
          SocialPresence(
            platformName: 'Facebook',
            pageLink: 'https://facebook.com/FawryOfficial',
            followers: '2.5M',
            engagementRate: '3.5',
            runningAds: '15',
          ),
        ],
      ),
      battle3Funding: FundingData(
        totalFunding: TotalFunding(
          amountUsd: '100 Million',
          numberOfRounds: 3,
        ),
        fundingRounds: [
          FundingRound(
            date: '2019',
            series: 'Series C',
            amountUsd: '50 Million',
            numberOfInvestors: 5,
            leadInvestor: 'Helios Investment Partners',
            notes: 'Used for regional expansion and technology development',
          ),
        ],
        investors: [
          Investor(
            name: 'Helios Investment Partners',
            type: 'PE',
            stakePercentage: '35',
            notes: 'Lead investor with significant stake',
          ),
        ],
        revenueValuation: RevenueValuation(
          revenueUsd: '150 Million',
          growthRate: '30',
          latestValuationUsd: '800 Million',
          notes: 'Strong growth trajectory with expanding market presence',
        ),
      ),
      battle4Customers: CustomersData(
        b2cSegments: [
          B2CSegment(
            ageRange: '25-45',
            incomeLevel: 'Middle to High',
            educationalLevel: 'Bachelor\'s and above',
            interestsLifestyle: 'Tech-savvy, urban professionals, digital natives',
            behavior: 'Frequent mobile app users, prefer digital transactions',
            needsPainPoints: 'Need for convenient payment solutions, security concerns',
            location: 'Urban Egypt',
            revenueSharePercentage: '60',
          ),
        ],
        b2bSegments: [
          B2BSegment(
            businessSize: 'SME to Enterprise',
            industry: 'Retail, Telecom, Utilities',
            revenueOfTargetedCompany: '10M - 100M USD',
            technographic: 'Digital-first businesses with online presence',
            behavior: 'Seek integrated payment solutions for customer convenience',
            needsPainPoints: 'Need for reliable payment infrastructure, compliance requirements',
            revenueSharePercentage: '40',
          ),
        ],
        reviewsOverview: ReviewsOverview(
          avgRating: '4.1',
          positivePercentage: '78',
          negativePercentage: '22',
          commonThemes: 'Convenience, reliability, user-friendly interface, occasional technical issues',
        ),
        painPoints: [
          PainPoint(
            description: 'Occasional app crashes during peak usage times',
            impact: 'Medium',
            frequency: 'Weekly',
            suggestedFix: 'Improve server capacity and app stability',
          ),
        ],
      ),
      battle5Partnerships: PartnershipsData(
        strategicPartners: [
          StrategicPartner(
            name: 'Vodafone Egypt',
            type: 'Technology',
            region: 'Egypt',
            startDate: '2018',
            notes: 'Mobile payment integration and customer acquisition',
          ),
        ],
        keySuppliers: [
          KeySupplier(
            name: 'IBM',
            commodity: 'Technology Infrastructure',
            region: 'Global',
            contractValue: '20 Million USD',
          ),
        ],
        growthRates: [
          GrowthRate(
            period: '2023',
            revenueGrowthPercentage: '30',
            userGrowthPercentage: '45',
          ),
        ],
        expansions: [
          Expansion(
            type: 'Geographic',
            regionMarket: 'Saudi Arabia',
            date: '2024',
            investment: '25 Million USD',
            notes: 'Planned expansion into Saudi market',
          ),
        ],
      ),
      createdAt: DateTime.now(),
    );
  }
  
  int _calculateTimeRemaining() {
    if (_currentMatch == null || _currentMatch!.startTime == null) return 0;
    
    final startTime = _currentMatch!.startTime!;
    final endTime = startTime.add(Duration(minutes: _currentMatch!.durationMinutes));
    final now = DateTime.now();
    
    if (now.isAfter(endTime)) return 0;
    
    return endTime.difference(now).inMinutes;
  }
  
  // Game requirements methods
  void _initializeBattleTemplates() {
    _battleTemplates = {
      'battle1': {
        'name': 'Leadership Recon',
        'fields': {
          'founders': {'required': true, 'weight': 12.0, 'type': 'text'},
          'key_executives': {'required': true, 'weight': 18.0, 'type': 'text'},
          'market_share': {'required': true, 'weight': 20.0, 'type': 'percentage'},
          'geographic_footprint': {'required': true, 'weight': 10.0, 'type': 'text'},
        }
      },
      'battle2': {
        'name': 'Product Arsenal',
        'fields': {
          'product_lines': {'required': true, 'weight': 30.0, 'type': 'text'},
          'pricing': {'required': true, 'weight': 15.0, 'type': 'number'},
          'social_presence': {'required': true, 'weight': 20.0, 'type': 'text'},
          'influencers': {'required': true, 'weight': 15.0, 'type': 'text'},
        }
      },
      'battle3': {
        'name': 'Funding Fortification',
        'fields': {
          'funding': {'required': true, 'weight': 40.0, 'type': 'number'},
          'investors': {'required': true, 'weight': 20.0, 'type': 'text'},
          'revenue': {'required': true, 'weight': 25.0, 'type': 'number'},
          'citations': {'required': true, 'weight': 15.0, 'type': 'url'},
        }
      },
      'battle4': {
        'name': 'Customer Frontlines',
        'fields': {
          'b2c': {'required': true, 'weight': 25.0, 'type': 'text'},
          'b2b': {'required': true, 'weight': 25.0, 'type': 'text'},
          'reviews': {'required': true, 'weight': 25.0, 'type': 'number'},
          'citations': {'required': true, 'weight': 25.0, 'type': 'url'},
        }
      },
      'battle5': {
        'name': 'Alliance Forge',
        'fields': {
          'partners': {'required': true, 'weight': 25.0, 'type': 'text'},
          'suppliers': {'required': true, 'weight': 20.0, 'type': 'text'},
          'growth': {'required': true, 'weight': 25.0, 'type': 'percentage'},
          'expansions': {'required': true, 'weight': 15.0, 'type': 'text'},
          'citations': {'required': true, 'weight': 15.0, 'type': 'url'},
        }
      },
    };
  }
  
  // Company selection (only for leaders)
  void selectCompany(String company) {
    if (_currentPlayer?.role != 'Leader') {
      _setError('Only team leaders can select companies');
      return;
    }
    _selectedCompany = company;
    notifyListeners();
  }
  
  // Leader ready status
  void setLeaderReady(bool ready) {
    if (_currentPlayer?.role != 'Leader') {
      _setError('Only team leaders can set ready status');
      return;
    }
    
    if (_currentPlayer?.team == 'Alpha') {
      _alphaLeaderReady = ready;
    } else if (_currentPlayer?.team == 'Delta') {
      _deltaLeaderReady = ready;
    }
    notifyListeners();
  }
  
  // Start match (both leaders must be ready)
  void startMatch() {
    if (!canStartMatch) {
      _setError('Both team leaders must be ready and company must be selected');
      return;
    }
    
    _matchStartTime = DateTime.now();
    _initializeBattleSubmissions();
    notifyListeners();
  }
  
  // Initialize battle submissions for all players
  void _initializeBattleSubmissions() {
    _battleSubmissions.clear();
    _battleCompletionStatus.clear();
    
    for (final player in _players) {
      for (final battleId in _battleTemplates.keys) {
        final key = '${player.id}_$battleId';
        _battleSubmissions[key] = {};
        _battleCompletionStatus[key] = false;
      }
    }
  }
  
  // Submit battle data
  void submitBattleData(String battleId, Map<String, dynamic> data) {
    if (_currentPlayer == null) return;
    
    final key = '${_currentPlayer!.id}_$battleId';
    
    // Validate all required fields are filled
    final template = _battleTemplates[battleId];
    if (template == null) return;
    
    final fields = template['fields'] as Map<String, dynamic>;
    bool allRequiredFieldsFilled = true;
    
    for (final fieldName in fields.keys) {
      final fieldConfig = fields[fieldName] as Map<String, dynamic>;
      if (fieldConfig['required'] == true) {
        if (!data.containsKey(fieldName) || data[fieldName] == null || data[fieldName].toString().isEmpty) {
          allRequiredFieldsFilled = false;
          break;
        }
      }
    }
    
    if (!allRequiredFieldsFilled) {
      _setError('All required fields must be filled before submission');
      return;
    }
    
    _battleSubmissions[key] = data;
    _battleCompletionStatus[key] = true;
    notifyListeners();
  }
  
  // Check if player can leave current battle
  bool canLeaveBattle(String battleId) {
    if (_currentPlayer == null) return false;
    
    final key = '${_currentPlayer!.id}_$battleId';
    return _battleCompletionStatus[key] == true;
  }
  
  // Get battle completion status for player
  bool isBattleCompleted(String battleId) {
    if (_currentPlayer == null) return false;
    
    final key = '${_currentPlayer!.id}_$battleId';
    return _battleCompletionStatus[key] == true;
  }
  
  // Calculate scoring (exact algorithm as specified)
  Map<String, double> calculateBattleScore(String battleId, Map<String, dynamic> submittedData) {
    final template = _battleTemplates[battleId];
    if (template == null) return {};
    
    final fields = template['fields'] as Map<String, dynamic>;
    double dataAccuracy = 0.0;
    double speed = 0.0;
    double sourceLink = 0.0;
    double teamwork = 0.0;
    
    // Data Accuracy (60%)
    double totalWeight = 0.0;
    double totalScore = 0.0;
    
    for (final fieldName in fields.keys) {
      final fieldConfig = fields[fieldName] as Map<String, dynamic>;
      final weight = fieldConfig['weight'] as double;
      totalWeight += weight;
      
      // Simple scoring for now - in production this would use the scoring service
      final submittedValue = submittedData[fieldName]?.toString() ?? '';
      final matchScore = submittedValue.isNotEmpty ? 1.0 : 0.0;
      totalScore += matchScore * weight;
    }
    
    dataAccuracy = totalWeight > 0 ? (totalScore / totalWeight) * 60.0 : 0.0;
    
    // Speed (10%)
    if (_matchStartTime != null) {
      final elapsed = DateTime.now().difference(_matchStartTime!);
      final timeLeft = Duration(minutes: _matchDurationMinutes) - elapsed;
      speed = timeLeft.isNegative ? 0.0 : (timeLeft.inMinutes / _matchDurationMinutes) * 10.0;
    }
    
    // Source Link (15%) - simplified for now
    sourceLink = 15.0; // Would be calculated based on source validation
    
    // Teamwork (15%) - simplified for now
    teamwork = 15.0; // Would be calculated based on collaboration metrics
    
    return {
      'dataAccuracy': dataAccuracy,
      'speed': speed,
      'sourceLink': sourceLink,
      'teamwork': teamwork,
      'total': dataAccuracy + speed + sourceLink + teamwork,
    };
  }
  
  // Check if team has won (95% threshold)
  bool hasTeamWon(String team) {
    final teamPlayers = _players.where((p) => p.team == team).toList();
    double totalScore = 0.0;
    int completedBattles = 0;
    
    for (final player in teamPlayers) {
      for (final battleId in _battleTemplates.keys) {
        final key = '${player.id}_$battleId';
        if (_battleCompletionStatus[key] == true && _battleSubmissions.containsKey(key)) {
          final score = calculateBattleScore(battleId, _battleSubmissions[key]!);
          totalScore += score['total'] ?? 0.0;
          completedBattles++;
        }
      }
    }
    
    if (completedBattles == 0) return false;
    
    final averageScore = totalScore / completedBattles;
    return averageScore >= 95.0; // 95% threshold
  }
  
  // Utility methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
  
  void _setError(String error) {
    _error = error;
    notifyListeners();
  }
  
  void _clearError() {
    _error = '';
    notifyListeners();
  }
  
  void clearGame() {
    _currentPlayer = null;
    _currentMatch = null;
    _players.clear();
    _submissions.clear();
    _clearError();
    notifyListeners();
  }
}
