import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/battle_status_card.dart';
import '../widgets/redeployment_panel.dart';
import '../theme/app_theme.dart';

class LeaderDashboardScreen extends StatefulWidget {
  final String matchId;

  const LeaderDashboardScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<LeaderDashboardScreen> createState() => _LeaderDashboardScreenState();
}

class _LeaderDashboardScreenState extends State<LeaderDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboardData();
    });
  }

  Future<void> _loadDashboardData() async {
    try {
      await context.read<GameProvider>().loadMatchData(widget.matchId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load dashboard data: $e'),
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

              if (gameProvider.currentMatch == null) {
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
                        'Match not found',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // Header
                    _buildHeader(gameProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Dashboard Content
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Battle Status
                          Expanded(
                            flex: 2,
                            child: _buildBattleOverview(gameProvider),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          // Redeployment Panel
                          Expanded(
                            flex: 1,
                            child: RedeploymentPanel(
                              matchId: widget.matchId,
                              currentPlayer: gameProvider.currentPlayer!,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(GameProvider gameProvider) {
    return Column(
      children: [
        Text(
          'Leader Dashboard',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 8),
        
        Text(
          'Monitor battle progress and manage team deployment',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildBattleOverview(GameProvider gameProvider) {
    const battles = [
      {'id': 'leadership_recon', 'name': 'Leadership Recon', 'subTeams': ['A1', 'D1']},
      {'id': 'product_arsenal', 'name': 'Product Arsenal', 'subTeams': ['A2', 'D2']},
      {'id': 'funding_fortification', 'name': 'Funding Fortification', 'subTeams': ['A3', 'D3']},
      {'id': 'customer_frontlines', 'name': 'Customer Frontlines', 'subTeams': ['A4', 'D4']},
      {'id': 'alliance_forge', 'name': 'Alliance Forge', 'subTeams': ['A5', 'D5']},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Battle Overview',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.primaryCyan,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        ...battles.map((battle) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: BattleStatusCard(
              battleName: battle['name']!,
              alphaSubTeam: battle['subTeams']![0],
              deltaSubTeam: battle['subTeams']![1],
              alphaStatus: _getBattleStatus(gameProvider, battle['id']!, 'Alpha'),
              deltaStatus: _getBattleStatus(gameProvider, battle['id']!, 'Delta'),
            ),
          );
        }).toList(),
      ],
    ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2);
  }

  String _getBattleStatus(GameProvider gameProvider, String battleId, String team) {
    // This would check actual submission status
    // For now, returning a mock status
    return 'active';
  }
}

class BattleStatusCard extends StatelessWidget {
  final String battleName;
  final String alphaSubTeam;
  final String deltaSubTeam;
  final String alphaStatus;
  final String deltaStatus;

  const BattleStatusCard({
    super.key,
    required this.battleName,
    required this.alphaSubTeam,
    required this.deltaSubTeam,
    required this.alphaStatus,
    required this.deltaStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderGray.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            battleName,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildTeamStatus(
                  context,
                  'Alpha',
                  alphaSubTeam,
                  alphaStatus,
                  AppTheme.primaryCyan,
                  LucideIcons.shield,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTeamStatus(
                  context,
                  'Delta',
                  deltaSubTeam,
                  deltaStatus,
                  AppTheme.primaryOrange,
                  LucideIcons.target,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTeamStatus(
    BuildContext context,
    String team,
    String subTeam,
    String status,
    Color color,
    IconData icon,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Team $team ($subTeam)',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textGray,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    status == 'completed' ? LucideIcons.checkCircle : LucideIcons.clock,
                    color: status == 'completed' ? AppTheme.primaryGreen : AppTheme.primaryYellow,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    status == 'completed' ? 'Completed' : 'Active',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: status == 'completed' ? AppTheme.primaryGreen : AppTheme.primaryYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
