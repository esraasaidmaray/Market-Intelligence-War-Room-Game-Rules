import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/battle_timer.dart';
import '../widgets/battle_form.dart';
import '../widgets/tools_panel.dart';
import '../widgets/team_info_panel.dart';
import '../theme/app_theme.dart';

class BattleScreen extends StatefulWidget {
  final String matchId;

  const BattleScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBattleData();
    });
  }

  Future<void> _loadBattleData() async {
    try {
      await context.read<GameProvider>().loadMatchData(widget.matchId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load battle data: $e'),
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
          child: Consumer<GameProvider>(
            builder: (context, gameProvider, child) {
              if (gameProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppTheme.primaryCyan,
                  ),
                );
              }

              if (gameProvider.currentMatch == null || 
                  gameProvider.currentPlayer == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        LucideIcons.alertTriangle,
                        size: 64,
                        color: AppTheme.primaryRed,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Battle data not found',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context.go('/lobby?match=${widget.matchId}'),
                        child: const Text('Return to Lobby'),
                      ),
                    ],
                  ),
                );
              }

              // Check if player has completed their battle
              if (gameProvider.currentPlayer!.status == 'completed') {
                return _buildCompletionScreen(gameProvider);
              }

              return _buildBattleInterface(gameProvider);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildBattleInterface(GameProvider gameProvider) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Main Battle Form
          Expanded(
            flex: 3,
            child: BattleForm(
              matchId: widget.matchId,
              player: gameProvider.currentPlayer!,
              match: gameProvider.currentMatch!,
            ),
          ),
          
          const SizedBox(width: 16),
          
          // Side Panels
          Expanded(
            flex: 1,
            child: Column(
              children: [
                // Battle Timer
                BattleTimer(
                  startTime: gameProvider.currentMatch!.startTime!,
                  duration: gameProvider.currentMatch!.durationMinutes,
                ),
                
                const SizedBox(height: 16),
                
                // Tools Panel
                ToolsPanel(
                  battleId: _getBattleIdForPlayer(gameProvider.currentPlayer!),
                ),
                
                const SizedBox(height: 16),
                
                // Team Info Panel
                TeamInfoPanel(
                  player: gameProvider.currentPlayer!,
                  match: gameProvider.currentMatch!,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionScreen(GameProvider gameProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            LucideIcons.checkCircle,
            size: 80,
            color: AppTheme.primaryGreen,
          ).animate().scale(duration: 600.ms),
          
          const SizedBox(height: 24),
          
          Text(
            'Mission Accomplished',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
          
          const SizedBox(height: 16),
          
          Text(
            'Intelligence submitted successfully. Awaiting redeployment orders from command.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppTheme.textGray,
            ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          
          const SizedBox(height: 32),
          
          // Score Card
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderGray.withOpacity(0.5),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Battle Score',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Total Score
                Text(
                  '0', // This would come from the actual submission
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Score Breakdown
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildScoreItem('Data Accuracy', '0%'),
                    _buildScoreItem('Speed', '0%'),
                    _buildScoreItem('Sources', '0%'),
                    _buildScoreItem('Teamwork', '0%'),
                  ],
                ),
              ],
            ),
          ).animate().fadeIn(delay: 600.ms, duration: 600.ms).slideY(begin: 0.2),
          
          const SizedBox(height: 32),
          
          GradientButton(
            onPressed: () => context.go('/leader-dashboard?match=${widget.matchId}'),
            gradient: AppTheme.cyanBlueGradient,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(LucideIcons.barChart3, color: Colors.black, size: 20),
                const SizedBox(width: 8),
                Text(
                  'View Leader Dashboard',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 800.ms, duration: 600.ms).slideY(begin: 0.2),
        ],
      ),
    );
  }

  Widget _buildScoreItem(String label, String value) {
    return Column(
      children: [
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
    );
  }

  String _getBattleIdForPlayer(player) {
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
    
    return battleMap[player.subTeam] ?? 'leadership_recon';
  }
}
