import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

class TeamCard extends StatelessWidget {
  final String team;
  final List<Player> players;
  final Player? leader;
  final bool isLeaderReady;
  final bool isCurrentPlayerLeader;
  final Function(Player, String) onAssignSubTeam;
  final VoidCallback onToggleReady;

  const TeamCard({
    super.key,
    required this.team,
    required this.players,
    this.leader,
    required this.isLeaderReady,
    required this.isCurrentPlayerLeader,
    required this.onAssignSubTeam,
    required this.onToggleReady,
  });

  @override
  Widget build(BuildContext context) {
    final isAlpha = team == 'Alpha';
    final gradient = isAlpha ? AppTheme.cyanBlueGradient : AppTheme.orangeRedGradient;
    final color = isAlpha ? AppTheme.primaryCyan : AppTheme.primaryOrange;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          // Team Header
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.users,
                color: color,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Team $team',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isLeaderReady) ...[
                const SizedBox(width: 8),
                Icon(
                  LucideIcons.checkCircle,
                  color: AppTheme.primaryGreen,
                  size: 20,
                ),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Leader Section
          if (leader != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryYellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppTheme.primaryYellow.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    LucideIcons.crown,
                    color: AppTheme.primaryYellow,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      leader!.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Leader',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Operatives Section
          Text(
            'Operatives (${players.where((p) => p.role == 'Player').length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textWhite,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          
          // Operatives List
          ...players.where((p) => p.role == 'Player').map((player) {
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray.withOpacity(0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      gradient: gradient,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      player.name,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textWhite,
                      ),
                    ),
                  ),
                  if (player.subTeam != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: color.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        player.subTeam!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ] else if (isCurrentPlayerLeader) ...[
                    // Sub-team assignment dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundGray,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: AppTheme.borderGray,
                          width: 1,
                        ),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: null,
                          hint: Text(
                            'Assign...',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textGray,
                            ),
                          ),
                          items: _getAvailableSubTeams().map((subTeam) {
                            return DropdownMenuItem<String>(
                              value: subTeam,
                              child: Text(
                                subTeam,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textWhite,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value != null) {
                              onAssignSubTeam(player, value);
                            }
                          },
                          dropdownColor: AppTheme.backgroundGray,
                          icon: Icon(
                            LucideIcons.chevronDown,
                            color: AppTheme.textGray,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  List<String> _getAvailableSubTeams() {
    const subTeams = {
      'Alpha': ['A1', 'A2', 'A3', 'A4', 'A5'],
      'Delta': ['D1', 'D2', 'D3', 'D4', 'D5'],
    };
    
    final usedSubTeams = players
        .where((p) => p.subTeam != null)
        .map((p) => p.subTeam!)
        .toList();
    
    return subTeams[team]!
        .where((subTeam) => !usedSubTeams.contains(subTeam))
        .toList();
  }
}
