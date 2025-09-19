import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

class RedeploymentPanel extends StatefulWidget {
  final String matchId;
  final Player currentPlayer;

  const RedeploymentPanel({
    super.key,
    required this.matchId,
    required this.currentPlayer,
  });

  @override
  State<RedeploymentPanel> createState() => _RedeploymentPanelState();
}

class _RedeploymentPanelState extends State<RedeploymentPanel> {
  Player? _selectedPlayer;

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, gameProvider, child) {
        final completedPlayers = gameProvider.players
            .where((p) => 
                p.team == widget.currentPlayer.team && 
                p.role == 'Player' && 
                p.status == 'completed')
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Redeployment Zone',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        LucideIcons.userCheck,
                        color: AppTheme.primaryGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Available Operatives',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textWhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  if (completedPlayers.isEmpty) ...[
                    Text(
                      'No operatives available for redeployment.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textGray,
                      ),
                    ),
                  ] else ...[
                    ...completedPlayers.map((player) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundGray.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppTheme.textWhite,
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () => setState(() => _selectedPlayer = player),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryCyan,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(LucideIcons.zap, size: 14),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Redeploy',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
            
            if (_selectedPlayer != null) ...[
              const SizedBox(height: 16),
              _buildRedeploymentOptions(),
            ],
          ],
        ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2);
      },
    );
  }

  Widget _buildRedeploymentOptions() {
    const battles = [
      {'id': 'leadership_recon', 'name': 'Leadership Recon'},
      {'id': 'product_arsenal', 'name': 'Product Arsenal'},
      {'id': 'funding_fortification', 'name': 'Funding Fortification'},
      {'id': 'customer_frontlines', 'name': 'Customer Frontlines'},
      {'id': 'alliance_forge', 'name': 'Alliance Forge'},
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryCyan.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.primaryCyan.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Redeploy: ${_selectedPlayer!.name}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.primaryCyan,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Select a battle to assist:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textGray,
            ),
          ),
          const SizedBox(height: 12),
          
          ...battles.map((battle) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _redeployPlayer(battle['id']!),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.primaryCyan),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    'Assist in ${battle['name']}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryCyan,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
          
          const SizedBox(height: 8),
          
          TextButton(
            onPressed: () => setState(() => _selectedPlayer = null),
            child: Text(
              'Cancel',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _redeployPlayer(String battleId) async {
    if (_selectedPlayer == null) return;

    try {
      final gameProvider = context.read<GameProvider>();
      
      // Get the sub-team for the battle
      final subTeam = _getSubTeamForBattle(battleId, _selectedPlayer!.team);
      
      // Redeploy the player
      await gameProvider.assignSubTeam(_selectedPlayer!.id, subTeam);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_selectedPlayer!.name} redeployed to $subTeam'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
        
        setState(() => _selectedPlayer = null);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to redeploy player: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    }
  }

  String _getSubTeamForBattle(String battleId, String team) {
    const battleSubTeams = {
      'leadership_recon': {'Alpha': 'A1', 'Delta': 'D1'},
      'product_arsenal': {'Alpha': 'A2', 'Delta': 'D2'},
      'funding_fortification': {'Alpha': 'A3', 'Delta': 'D3'},
      'customer_frontlines': {'Alpha': 'A4', 'Delta': 'D4'},
      'alliance_forge': {'Alpha': 'A5', 'Delta': 'D5'},
    };
    
    return battleSubTeams[battleId]?[team] ?? '';
  }
}
