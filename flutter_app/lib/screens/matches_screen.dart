import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class MatchesScreen extends StatefulWidget {
  const MatchesScreen({super.key});

  @override
  State<MatchesScreen> createState() => _MatchesScreenState();
}

class _MatchesScreenState extends State<MatchesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatches();
    });
  }

  Future<void> _loadMatches() async {
    try {
      // This would load matches from the game provider
      // For now, we'll just show a placeholder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load matches: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CyberBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Matches List
                Expanded(
                  child: _buildMatchesList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          'Match History',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 8),
        
        Text(
          'View past and current matches',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildMatchesList() {
    // Mock matches data
    final matches = [
      {
        'id': 'match_1',
        'company': 'Apple Inc.',
        'status': 'completed',
        'date': '2024-01-15',
        'alphaScore': 85,
        'deltaScore': 92,
        'winner': 'Delta',
      },
      {
        'id': 'match_2',
        'company': 'Microsoft Corporation',
        'status': 'active',
        'date': '2024-01-16',
        'alphaScore': 0,
        'deltaScore': 0,
        'winner': null,
      },
      {
        'id': 'match_3',
        'company': 'Tesla Inc.',
        'status': 'setup',
        'date': '2024-01-17',
        'alphaScore': 0,
        'deltaScore': 0,
        'winner': null,
      },
    ];

    return ListView.builder(
      itemCount: matches.length,
      itemBuilder: (context, index) {
        final match = matches[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: _buildMatchCard(match),
        ).animate(delay: (index * 100).ms)
            .fadeIn(duration: 600.ms)
            .slideY(begin: 0.2);
      },
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final status = match['status'] as String;
    final isCompleted = status == 'completed';
    final isActive = status == 'active';
    final isSetup = status == 'setup';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match['company'] as String,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Match ID: ${match['id']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textGray,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(status),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Scores (if completed)
          if (isCompleted) ...[
            Row(
              children: [
                Expanded(
                  child: _buildScoreCard(
                    'Team Alpha',
                    match['alphaScore'] as int,
                    AppTheme.primaryCyan,
                    match['winner'] == 'Alpha',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildScoreCard(
                    'Team Delta',
                    match['deltaScore'] as int,
                    AppTheme.primaryOrange,
                    match['winner'] == 'Delta',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          // Actions
          Row(
            children: [
              if (isCompleted) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _viewMatchSummary(match['id'] as String),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryCyan),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.barChart3, color: AppTheme.primaryCyan, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'View Summary',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryCyan,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (isActive) ...[
                Expanded(
                  child: GradientButton(
                    onPressed: () => _joinActiveMatch(match['id'] as String),
                    gradient: AppTheme.cyanBlueGradient,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.play, color: Colors.black, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Join Battle',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (isSetup) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _joinLobby(match['id'] as String),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryGreen),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.users, color: AppTheme.primaryGreen, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Join Lobby',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'completed':
        color = AppTheme.primaryGreen;
        text = 'Completed';
        icon = LucideIcons.checkCircle;
        break;
      case 'active':
        color = AppTheme.primaryYellow;
        text = 'Active';
        icon = LucideIcons.play;
        break;
      case 'setup':
        color = AppTheme.primaryCyan;
        text = 'Setup';
        icon = LucideIcons.settings;
        break;
      default:
        color = AppTheme.textGray;
        text = 'Unknown';
        icon = LucideIcons.helpCircle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 14),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(String team, int score, Color color, bool isWinner) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isWinner ? color : color.withOpacity(0.3),
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            team,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(height: 4),
            Icon(
              LucideIcons.trophy,
              color: color,
              size: 16,
            ),
          ],
        ],
      ),
    );
  }

  void _viewMatchSummary(String matchId) {
    context.go('/match-summary?match=$matchId');
  }

  void _joinActiveMatch(String matchId) {
    context.go('/battle?match=$matchId');
  }

  void _joinLobby(String matchId) {
    context.go('/lobby?match=$matchId');
  }
}
