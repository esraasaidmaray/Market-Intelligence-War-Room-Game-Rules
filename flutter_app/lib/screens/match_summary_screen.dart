import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class MatchSummaryScreen extends StatefulWidget {
  final String matchId;

  const MatchSummaryScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<MatchSummaryScreen> createState() => _MatchSummaryScreenState();
}

class _MatchSummaryScreenState extends State<MatchSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatchSummary();
    });
  }

  Future<void> _loadMatchSummary() async {
    try {
      // This would load match summary from the game provider
      // For now, we'll just show a placeholder
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load match summary: $e'),
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                
                // Header
                _buildHeader(),
                
                const SizedBox(height: 32),
                
                // Match Overview
                _buildMatchOverview(),
                
                const SizedBox(height: 24),
                
                // Team Scores
                _buildTeamScores(),
                
                const SizedBox(height: 24),
                
                // Battle Breakdown
                _buildBattleBreakdown(),
                
                const SizedBox(height: 24),
                
                // Performance Metrics
                _buildPerformanceMetrics(),
                
                const SizedBox(height: 32),
                
                // Actions
                _buildActions(),
                
                const SizedBox(height: 32),
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
          'Match Summary',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 8),
        
        Text(
          'Intelligence Report - ${widget.matchId}',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
            fontFamily: 'monospace',
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildMatchOverview() {
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
          Text(
            'Mission Overview',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Company',
                  'Apple Inc.',
                  LucideIcons.building,
                  AppTheme.primaryCyan,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewItem(
                  'Duration',
                  '58:32',
                  LucideIcons.clock,
                  AppTheme.primaryYellow,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildOverviewItem(
                  'Status',
                  'Completed',
                  LucideIcons.checkCircle,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildOverviewItem(
                  'Winner',
                  'Team Delta',
                  LucideIcons.trophy,
                  AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildOverviewItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamScores() {
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
          Text(
            'Final Scores',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          Row(
            children: [
              Expanded(
                child: _buildTeamScoreCard(
                  'Team Alpha',
                  AppTheme.primaryCyan,
                  85,
                  false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamScoreCard(
                  'Team Delta',
                  AppTheme.primaryOrange,
                  92,
                  true,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildTeamScoreCard(String team, Color color, int score, bool isWinner) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWinner ? color : color.withOpacity(0.3),
          width: isWinner ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isWinner ? LucideIcons.trophy : LucideIcons.users,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                team,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (isWinner) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'WINNER',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBattleBreakdown() {
    final battles = [
      {'name': 'Leadership Recon', 'alpha': 18, 'delta': 20, 'winner': 'Delta'},
      {'name': 'Product Arsenal', 'alpha': 16, 'delta': 19, 'winner': 'Delta'},
      {'name': 'Funding Fortification', 'alpha': 17, 'delta': 18, 'winner': 'Delta'},
      {'name': 'Customer Frontlines', 'alpha': 19, 'delta': 17, 'winner': 'Alpha'},
      {'name': 'Alliance Forge', 'alpha': 15, 'delta': 18, 'winner': 'Delta'},
    ];

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
          Text(
            'Battle Breakdown',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          ...battles.asMap().entries.map((entry) {
            final index = entry.key;
            final battle = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildBattleRow(
                battle['name'] as String,
                battle['alpha'] as int,
                battle['delta'] as int,
                battle['winner'] as String,
              ),
            ).animate(delay: (800 + index * 100).ms)
                .fadeIn(duration: 400.ms)
                .slideX(begin: -0.2);
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBattleRow(String name, int alphaScore, int deltaScore, String winner) {
    final isAlphaWinner = winner == 'Alpha';
    final isDeltaWinner = winner == 'Delta';
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              name,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textWhite,
              ),
            ),
          ),
          Expanded(
            child: _buildScoreIndicator(
              alphaScore,
              AppTheme.primaryCyan,
              isAlphaWinner,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildScoreIndicator(
              deltaScore,
              AppTheme.primaryOrange,
              isDeltaWinner,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator(int score, Color color, bool isWinner) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isWinner ? color : color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isWinner ? color : color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isWinner) ...[
            Icon(
              LucideIcons.crown,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            score.toString(),
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isWinner ? Colors.white : color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceMetrics() {
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
          Text(
            'Performance Metrics',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Accuracy',
                  '94%',
                  LucideIcons.target,
                  AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Speed',
                  '87%',
                  LucideIcons.zap,
                  AppTheme.primaryYellow,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  'Sources',
                  '91%',
                  LucideIcons.link,
                  AppTheme.primaryCyan,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  'Teamwork',
                  '89%',
                  LucideIcons.users,
                  AppTheme.primaryOrange,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 1200.ms, duration: 600.ms).slideY(begin: 0.2);
  }

  Widget _buildMetricCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => context.go('/matches'),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.borderGray),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.arrowLeft, color: AppTheme.textGray, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Back to Matches',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GradientButton(
            onPressed: () => context.go('/'),
            gradient: AppTheme.cyanBlueGradient,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(LucideIcons.home, color: Colors.black, size: 16),
                const SizedBox(width: 8),
                Text(
                  'New Match',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate().fadeIn(delay: 1400.ms, duration: 600.ms).slideY(begin: 0.2);
  }
}
