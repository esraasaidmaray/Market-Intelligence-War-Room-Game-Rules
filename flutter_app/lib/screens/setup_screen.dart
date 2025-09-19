import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/step_indicator.dart';
import '../widgets/avatar_selector.dart';
import '../theme/app_theme.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  int _currentStep = 1;
  final _formKey = GlobalKey<FormState>();
  
  // Form data
  String _name = '';
  String _team = '';
  String _role = '';
  String _avatar = 'agent1';
  String _company = '';
  String _matchId = '';

  final List<String> _companies = [
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
  ];

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
                
                // Progress Indicator
                StepIndicator(
                  currentStep: _currentStep,
                  totalSteps: 3,
                ),
                
                const SizedBox(height: 32),
                
                // Form Content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: _buildStepContent(),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Navigation Buttons
                _buildNavigationButtons(),
                
                const SizedBox(height: 16),
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
          'Agent Registration',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 8),
        
        Text(
          'Configure your operative profile for the mission',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideY(begin: -0.2),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Agent Name
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Agent Name',
            hintText: 'Enter your codename',
            prefixIcon: Icon(LucideIcons.user, color: AppTheme.primaryCyan),
          ),
          onChanged: (value) => _name = value,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Agent name is required';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 24),
        
        // Team Selection
        Text(
          'Team Assignment',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildTeamButton(
                'Alpha',
                AppTheme.cyanBlueGradient,
                LucideIcons.shield,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTeamButton(
                'Delta',
                AppTheme.orangeRedGradient,
                LucideIcons.target,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Role Selection
        Text(
          'Operational Role',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                'Leader',
                AppTheme.yellowOrangeGradient,
                LucideIcons.crown,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRoleButton(
                'Player',
                AppTheme.greenEmeraldGradient,
                LucideIcons.users,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Avatar Selection
        Text(
          'Avatar Selection',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        
        AvatarSelector(
          selectedAvatar: _avatar,
          onAvatarSelected: (avatar) => setState(() => _avatar = avatar),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2);
  }

  Widget _buildStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mission Parameters',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        if (_role == 'Leader') ...[
          // Company Selection for Leaders
          TextFormField(
            decoration: const InputDecoration(
              labelText: 'Target Company (Leaders Only)',
              hintText: 'Select target company',
              prefixIcon: Icon(LucideIcons.building, color: AppTheme.primaryCyan),
            ),
            readOnly: true,
            onTap: () => _showCompanySelector(),
            controller: TextEditingController(text: _company.isEmpty ? null : _company),
            validator: (value) {
              if (_role == 'Leader' && (value == null || value.trim().isEmpty)) {
                return 'Company selection is required for team leaders';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Both team leaders must select the same company to proceed',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textGray,
            ),
          ),
        ] else ...[
          // Player waiting message
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: AppTheme.backgroundGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.primaryCyan.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  LucideIcons.user,
                  size: 64,
                  color: AppTheme.primaryCyan,
                ),
                const SizedBox(height: 16),
                Text(
                  'Ready for Deployment',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.textWhite,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your team leader will select the target company and assign you to a sub-team.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textGray,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2);
  }

  Widget _buildStep3() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Deploy to Battle',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Create Match Button
        GradientButton(
          onPressed: _createMatch,
          gradient: AppTheme.cyanBlueGradient,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.plus, color: Colors.black, size: 20),
              const SizedBox(width: 8),
              Text(
                'Create New Match',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Divider
        Row(
          children: [
            Expanded(child: Divider(color: AppTheme.borderGray)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textGray,
                ),
              ),
            ),
            Expanded(child: Divider(color: AppTheme.borderGray)),
          ],
        ),
        
        const SizedBox(height: 24),
        
        // Join Match Section
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Enter Match ID',
            hintText: 'Match ID',
            prefixIcon: Icon(LucideIcons.hash, color: AppTheme.primaryCyan),
          ),
          onChanged: (value) => _matchId = value,
        ),
        
        const SizedBox(height: 16),
        
        OutlinedButton(
          onPressed: _joinMatch,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppTheme.primaryCyan),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(LucideIcons.logIn, color: AppTheme.primaryCyan, size: 20),
              const SizedBox(width: 8),
              Text(
                'Join Existing Match',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.2);
  }

  Widget _buildTeamButton(String team, LinearGradient gradient, IconData icon) {
    final isSelected = _team == team;
    
    return GestureDetector(
      onTap: () => setState(() => _team = team),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppTheme.backgroundGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : AppTheme.borderGray.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : AppTheme.textGray,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              'Team $team',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.black : AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton(String role, LinearGradient gradient, IconData icon) {
    final isSelected = _role == role;
    
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : AppTheme.backgroundGray.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? Colors.transparent 
                : AppTheme.borderGray.withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.black : AppTheme.textGray,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              role == 'Leader' ? 'Team Leader' : 'Operative',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: isSelected ? Colors.black : AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 1)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.borderGray),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Back',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textGray,
                ),
              ),
            ),
          ),
        
        if (_currentStep > 1) const SizedBox(width: 16),
        
        Expanded(
          child: GradientButton(
            onPressed: _nextStep,
            gradient: AppTheme.cyanBlueGradient,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _currentStep < 3 ? 'Next' : 'Complete',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_currentStep < 3) ...[
                  const SizedBox(width: 8),
                  const Icon(LucideIcons.arrowRight, color: Colors.black, size: 20),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (_validateStep1()) {
        setState(() => _currentStep = 2);
      }
    } else if (_currentStep == 2) {
      if (_validateStep2()) {
        setState(() => _currentStep = 3);
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 1) {
      setState(() => _currentStep--);
    }
  }

  bool _validateStep1() {
    if (_name.trim().isEmpty) {
      _showError('Agent name is required');
      return false;
    }
    if (_team.isEmpty) {
      _showError('Team selection is required');
      return false;
    }
    if (_role.isEmpty) {
      _showError('Role selection is required');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_role == 'Leader' && _company.isEmpty) {
      _showError('Company selection is required for team leaders');
      return false;
    }
    return true;
  }

  void _showCompanySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.backgroundGray,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Target Company',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._companies.map((company) => ListTile(
              title: Text(
                company,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textWhite,
                ),
              ),
              onTap: () {
                setState(() => _company = company);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _createMatch() async {
    if (!_validateStep1() || !_validateStep2()) return;
    
    try {
      final gameProvider = context.read<GameProvider>();
      final playerProvider = context.read<PlayerProvider>();
      
      // Create player
      await gameProvider.createPlayer(
        name: _name,
        team: _team,
        role: _role,
        avatar: _avatar,
      );
      
      // Create match
      await gameProvider.createMatch(company: _company);
      
      // Set current player
      playerProvider.setCurrentPlayer(gameProvider.currentPlayer!);
      
      // Navigate to lobby
      if (mounted) {
        context.go('/lobby?match=${gameProvider.currentMatch!.matchId}');
      }
    } catch (e) {
      _showError('Failed to create match: $e');
    }
  }

  Future<void> _joinMatch() async {
    if (_matchId.trim().isEmpty) {
      _showError('Match ID is required');
      return;
    }
    
    try {
      final gameProvider = context.read<GameProvider>();
      final playerProvider = context.read<PlayerProvider>();
      
      // Create player
      await gameProvider.createPlayer(
        name: _name,
        team: _team,
        role: _role,
        avatar: _avatar,
      );
      
      // Join match
      await gameProvider.joinMatch(_matchId);
      
      // Set current player
      playerProvider.setCurrentPlayer(gameProvider.currentPlayer!);
      
      // Navigate to lobby
      if (mounted) {
        context.go('/lobby?match=$_matchId');
      }
    } catch (e) {
      _showError('Failed to join match: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.primaryRed,
      ),
    );
  }
}
