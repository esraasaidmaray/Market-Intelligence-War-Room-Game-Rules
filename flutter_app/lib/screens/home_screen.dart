import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../widgets/cyber_background.dart';
import '../widgets/gradient_button.dart';
import '../widgets/feature_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GameProvider>().initializeGame();
    });
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
                
                // Hero Section
                _buildHeroSection(),
                
                const SizedBox(height: 48),
                
                // Features Grid
                _buildFeaturesGrid(),
                
                const SizedBox(height: 48),
                
                // Battle Types
                _buildBattleTypes(),
                
                const SizedBox(height: 48),
                
                // How It Works
                _buildHowItWorks(),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroSection() {
    return Column(
      children: [
        // Classified Mission Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.primaryCyan.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppTheme.primaryCyan.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                LucideIcons.shield,
                color: AppTheme.primaryCyan,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'CLASSIFIED MISSION',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppTheme.primaryCyan,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
        
        const SizedBox(height: 24),
        
        // Main Title
        Text(
          'Market Intelligence\nWar Room',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            height: 1.1,
            foreground: Paint()
              ..shader = AppTheme.cyanBlueGradient.createShader(
                const Rect.fromLTWH(0, 0, 200, 70),
              ),
          ),
        ).animate().fadeIn(delay: 200.ms, duration: 800.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 16),
        
        // Subtitle
        Text(
          'Compete in real-time market research battles. Gather intelligence, make strategic decisions, and outmaneuver the competition.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.textGray,
            height: 1.5,
          ),
        ).animate().fadeIn(delay: 400.ms, duration: 800.ms).slideY(begin: 0.2),
        
        const SizedBox(height: 32),
        
        // Action Buttons
        Row(
          children: [
            Expanded(
              child: GradientButton(
                onPressed: () => context.go('/setup'),
                gradient: AppTheme.cyanBlueGradient,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.play, color: Colors.black, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Start Mission',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: OutlinedButton(
                onPressed: () => context.go('/matches'),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryCyan),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(LucideIcons.trophy, color: AppTheme.primaryCyan, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'View Matches',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primaryCyan,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ).animate().fadeIn(delay: 600.ms, duration: 800.ms).slideY(begin: 0.2),
      ],
    );
  }

  Widget _buildFeaturesGrid() {
    final features = [
      {
        'icon': LucideIcons.users,
        'title': 'Team Battles',
        'description': '5 concurrent 3v3 battles between Alpha and Delta teams',
        'gradient': AppTheme.cyanBlueGradient,
      },
      {
        'icon': LucideIcons.clock,
        'title': '60-Minute Matches',
        'description': 'Race against time to gather market intelligence',
        'gradient': AppTheme.greenEmeraldGradient,
      },
      {
        'icon': LucideIcons.target,
        'title': 'Real Research',
        'description': 'Use actual tools like LinkedIn, Crunchbase, and Statista',
        'gradient': AppTheme.orangeRedGradient,
      },
      {
        'icon': LucideIcons.trophy,
        'title': 'Competitive Scoring',
        'description': 'Accuracy, speed, sources, and teamwork all matter',
        'gradient': AppTheme.purplePinkGradient,
      },
    ];

    return Column(
      children: [
        Text(
          'Core Features',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            final feature = features[index];
            return FeatureCard(
              icon: feature['icon'] as IconData,
              title: feature['title'] as String,
              description: feature['description'] as String,
              gradient: feature['gradient'] as LinearGradient,
            ).animate(delay: (index * 100).ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2);
          },
        ),
      ],
    );
  }

  Widget _buildBattleTypes() {
    final battleTypes = [
      {'name': 'Leadership Recon', 'description': 'Founder & executive intelligence'},
      {'name': 'Product Arsenal', 'description': 'Product portfolio analysis'},
      {'name': 'Market Dominance', 'description': 'Market share & positioning'},
      {'name': 'Financial Intel', 'description': 'Funding & revenue insights'},
      {'name': 'Digital Footprint', 'description': 'Social & digital presence'},
    ];

    return Column(
      children: [
        Text(
          'Battle Categories',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: battleTypes.length,
          itemBuilder: (context, index) {
            final battle = battleTypes[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.backgroundGray.withOpacity(0.4),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.borderGray.withOpacity(0.5),
                  width: 0.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    battle['name'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.primaryCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    battle['description'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textGray,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (index * 100).ms)
                .fadeIn(duration: 600.ms)
                .slideY(begin: 0.2);
          },
        ),
      ],
    );
  }

  Widget _buildHowItWorks() {
    final steps = [
      {
        'number': '1',
        'title': 'Form Teams',
        'description': 'Join Alpha or Delta team, assign roles and sub-teams',
        'gradient': AppTheme.cyanBlueGradient,
      },
      {
        'number': '2',
        'title': 'Execute Missions',
        'description': 'Research targets using real intelligence tools',
        'gradient': AppTheme.greenEmeraldGradient,
      },
      {
        'number': '3',
        'title': 'Victory',
        'description': 'Score based on accuracy, speed, and teamwork',
        'gradient': AppTheme.orangeRedGradient,
      },
    ];

    return Column(
      children: [
        Text(
          'Mission Protocol',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: AppTheme.textWhite,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: steps.map((step) {
            final index = steps.indexOf(step);
            return Expanded(
              child: Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      gradient: step['gradient'] as LinearGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        step['number'] as String,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    step['title'] as String,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textWhite,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    step['description'] as String,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textGray,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (index < steps.length - 1) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: 1,
                      height: 40,
                      color: AppTheme.borderGray,
                    ),
                  ],
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// Import the theme class
class AppTheme {
  static const Color primaryCyan = Color(0xFF06B6D4);
  static const Color primaryBlue = Color(0xFF3B82F6);
  static const Color primaryOrange = Color(0xFFF97316);
  static const Color primaryRed = Color(0xFFEF4444);
  static const Color primaryGreen = Color(0xFF10B981);
  static const Color primaryYellow = Color(0xFFF59E0B);
  static const Color primaryPurple = Color(0xFF8B5CF6);
  
  static const Color backgroundDark = Color(0xFF0F172A);
  static const Color backgroundDarker = Color(0xFF020617);
  static const Color backgroundGray = Color(0xFF1E293B);
  static const Color backgroundGrayLight = Color(0xFF334155);
  
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGray = Color(0xFF94A3B8);
  static const Color textGrayLight = Color(0xFFCBD5E1);
  
  static const Color borderGray = Color(0xFF475569);
  static const Color borderCyan = Color(0xFF06B6D4);
  static const Color borderOrange = Color(0xFFF97316);

  static const LinearGradient cyanBlueGradient = LinearGradient(
    colors: [primaryCyan, primaryBlue],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient orangeRedGradient = LinearGradient(
    colors: [primaryOrange, primaryRed],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient greenEmeraldGradient = LinearGradient(
    colors: [primaryGreen, Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient yellowOrangeGradient = LinearGradient(
    colors: [primaryYellow, primaryOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient purplePinkGradient = LinearGradient(
    colors: [primaryPurple, Color(0xFFEC4899)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
