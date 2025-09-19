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
  
  // Getters
  bool get isLoading => _isLoading;
  String get error => _error;
  Player? get currentPlayer => _currentPlayer;
  Match? get currentMatch => _currentMatch;
  List<Player> get players => _players;
  List<BattleSubmission> get submissions => _submissions;
  CompanyReference? get companyReference => _companyReference;
  
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
