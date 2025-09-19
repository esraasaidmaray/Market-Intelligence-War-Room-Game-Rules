import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/team_card.dart';
import '../widgets/battle_preview.dart';
import '../theme/app_theme.dart';

class LobbyScreen extends StatefulWidget {
  final String matchId;

  const LobbyScreen({
    super.key,
    required this.matchId,
  });

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMatchData();
    });
  }

  Future<void> _loadMatchData() async {
    try {
      await context.read<GameProvider>().loadMatchData(widget.matchId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load match data: $e'),
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
                        'Mission not found',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    
                    // Header
                    _buildHeader(gameProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Teams Layout
                    _buildTeamsLayout(gameProvider),
                    
                    const SizedBox(height: 32),
                    
                    // Battle Configuration Preview
                    _buildBattlePreview(),
                    
                    const SizedBox(height: 32),
                    
                    // Control Panel
                    _buildControlPanel(gameProvider),
                    
                    const SizedBox(height: 16),
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
          'Mission Briefing Room',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 16),
        
        // Match ID
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray.withOpacity(0.5),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: AppTheme.borderGray.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Match ID: ',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textGray,
                ),
              ),
              Text(
                widget.matchId,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryCyan,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () {
                  // Copy to clipboard
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Match ID copied to clipboard'),
                      backgroundColor: AppTheme.primaryGreen,
                    ),
                  );
                },
                child: const Icon(
                  LucideIcons.copy,
                  color: AppTheme.primaryCyan,
                  size: 16,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2),
        
        if (gameProvider.currentMatch?.company != null) ...[
          const SizedBox(height: 16),
          
          // Target Company
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryCyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryCyan.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  'Target Company',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppTheme.primaryCyan,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  gameProvider.currentMatch!.company!,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 400.ms, duration: 600.ms).slideY(begin: -0.2),
        ],
      ],
    );
  }

  Widget _buildTeamsLayout(GameProvider gameProvider) {
    return Row(
      children: [
        // Team Alpha
        Expanded(
          child: TeamCard(
            team: 'Alpha',
            players: gameProvider.alphaPlayers,
            leader: gameProvider.alphaLeader,
            isLeaderReady: gameProvider.currentMatch?.alphaLeaderReady ?? false,
            isCurrentPlayerLeader: gameProvider.currentPlayer?.role == 'Leader' &&
                gameProvider.currentPlayer?.team == 'Alpha',
            onAssignSubTeam: (player, subTeam) async {
              await gameProvider.assignSubTeam(player.id, subTeam);
            },
            onToggleReady: () async {
              await gameProvider.toggleLeaderReady();
            },
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Team Delta
        Expanded(
          child: TeamCard(
            team: 'Delta',
            players: gameProvider.deltaPlayers,
            leader: gameProvider.deltaLeader,
            isLeaderReady: gameProvider.currentMatch?.deltaLeaderReady ?? false,
            isCurrentPlayerLeader: gameProvider.currentPlayer?.role == 'Leader' &&
                gameProvider.currentPlayer?.team == 'Delta',
            onAssignSubTeam: (player, subTeam) async {
              await gameProvider.assignSubTeam(player.id, subTeam);
            },
            onToggleReady: () async {
              await gameProvider.toggleLeaderReady();
            },
          ),
        ),
      ],
    ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildBattlePreview() {
    return Column(
      children: [
        Text(
          'Battle Configuration',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        BattlePreview(),
      ],
    ).animate().fadeIn(delay: 800.ms, duration: 800.ms).slideY(begin: 0.2);
  }

  Widget _buildControlPanel(GameProvider gameProvider) {
    final isCurrentPlayerLeader = gameProvider.currentPlayer?.role == 'Leader';
    final allPlayersAssigned = gameProvider.players
        .where((p) => p.role == 'Player')
        .every((p) => p.subTeam != null && p.subTeam!.isNotEmpty);
    final canStart = gameProvider.canStartMatch;
    final alphaLeaderReady = gameProvider.alphaLeaderReady;
    final deltaLeaderReady = gameProvider.deltaLeaderReady;
    final selectedCompany = gameProvider.selectedCompany;
    
    return Container(
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
          // Company Selection (Leaders only)
          if (isCurrentPlayerLeader) ...[
            Text(
              'Company Selection',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            DropdownButtonFormField<String>(
              value: selectedCompany,
              decoration: InputDecoration(
                labelText: 'Select Company',
                labelStyle: TextStyle(color: AppTheme.textGray),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderGray),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.borderGray),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: AppTheme.primaryCyan),
                ),
              ),
              dropdownColor: AppTheme.backgroundDark,
              style: TextStyle(color: AppTheme.textWhite),
              items: [
                'Apple Inc.',
                'Microsoft Corporation',
                'Amazon.com Inc.',
                'Alphabet Inc. (Google)',
                'Tesla Inc.',
                'Meta Platforms Inc.',
                'Netflix Inc.',
                'Nike Inc.',
                'Coca-Cola Company',
                'McDonald\'s Corporation',
                'Spotify Technology',
                'Uber Technologies',
                'Airbnb Inc.',
                'Zoom Video Communications',
                'Slack Technologies',
              ].map((company) => DropdownMenuItem(
                value: company,
                child: Text(company),
              )).toList(),
              onChanged: (value) {
                if (value != null) {
                  gameProvider.selectCompany(value);
                }
              },
            ),
            
            const SizedBox(height: 24),
          ],
          
          // Leader Ready Status
          if (isCurrentPlayerLeader) ...[
            Text(
              'Leader Status',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildLeaderStatusCard(
                    'Alpha Team',
                    alphaLeaderReady,
                    gameProvider.alphaLeader?.name ?? 'No Leader',
                    AppTheme.primaryCyan,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildLeaderStatusCard(
                    'Delta Team',
                    deltaLeaderReady,
                    gameProvider.deltaLeader?.name ?? 'No Leader',
                    AppTheme.primaryOrange,
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Ready Button
            GradientButton(
              onPressed: () {
                gameProvider.setLeaderReady(true);
              },
              gradient: AppTheme.cyanBlueGradient,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(LucideIcons.check, color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'MARK READY',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
          ],
          
          if (isCurrentPlayerLeader) ...[
            // Leader Controls
            GradientButton(
              onPressed: gameProvider.toggleLeaderReady,
              gradient: (gameProvider.currentMatch?.alphaLeaderReady ?? false) &&
                      gameProvider.currentPlayer?.team == 'Alpha' ||
                  (gameProvider.currentMatch?.deltaLeaderReady ?? false) &&
                      gameProvider.currentPlayer?.team == 'Delta'
                  ? AppTheme.greenEmeraldGradient
                  : AppTheme.cyanBlueGradient,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    (gameProvider.currentMatch?.alphaLeaderReady ?? false) &&
                            gameProvider.currentPlayer?.team == 'Alpha' ||
                        (gameProvider.currentMatch?.deltaLeaderReady ?? false) &&
                            gameProvider.currentPlayer?.team == 'Delta'
                        ? LucideIcons.checkCircle
                        : LucideIcons.clock,
                    color: Colors.black,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    (gameProvider.currentMatch?.alphaLeaderReady ?? false) &&
                            gameProvider.currentPlayer?.team == 'Alpha' ||
                        (gameProvider.currentMatch?.deltaLeaderReady ?? false) &&
                            gameProvider.currentPlayer?.team == 'Delta'
                        ? 'Ready!'
                        : 'Mark Ready',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (canStart && allPlayersAssigned) ...[
              GradientButton(
                onPressed: () async {
                  await gameProvider.startMatch();
                  if (mounted) {
                    context.go('/battle?match=${widget.matchId}');
                  }
                },
                gradient: AppTheme.greenEmeraldGradient,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.play, color: Colors.white, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      'LAUNCH MISSION',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (canStart && !allPlayersAssigned) ...[
              Text(
                'All players must be assigned to sub-teams before starting',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textGray,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Text(
                'Waiting for team leaders to start the mission...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ] else ...[
            // Player Waiting
            Column(
              children: [
                Icon(
                  LucideIcons.clock,
                  size: 48,
                  color: AppTheme.primaryYellow,
                ),
                const SizedBox(height: 16),
                Text(
                  'Standby for Orders',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Waiting for team leaders to configure and start the mission',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ],
        ],
      ),
    ).animate().fadeIn(delay: 1000.ms, duration: 800.ms).slideY(begin: 0.2);
  }
  
  Widget _buildLeaderStatusCard(String teamName, bool isReady, String leaderName, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isReady ? color : color.withOpacity(0.3),
          width: isReady ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Icon(
            isReady ? LucideIcons.checkCircle : LucideIcons.clock,
            color: isReady ? color : AppTheme.textGray,
            size: 24,
          ),
          const SizedBox(height: 8),
          Text(
            leaderName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textWhite,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            isReady ? 'Ready' : 'Not Ready',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isReady ? color : AppTheme.textGray,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
