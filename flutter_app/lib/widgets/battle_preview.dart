import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BattlePreview extends StatelessWidget {
  static const List<Map<String, String>> battles = [
    {'name': 'Leadership Recon', 'subTeams': 'A1 vs D1'},
    {'name': 'Product Arsenal', 'subTeams': 'A2 vs D2'},
    {'name': 'Market Dominance', 'subTeams': 'A3 vs D3'},
    {'name': 'Financial Intel', 'subTeams': 'A4 vs D4'},
    {'name': 'Digital Footprint', 'subTeams': 'A5 vs D5'},
  ];

  const BattlePreview({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: battles.length,
      itemBuilder: (context, index) {
        final battle = battles[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.backgroundGray.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppTheme.borderGray.withOpacity(0.5),
              width: 0.5,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                battle['name']!,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                battle['subTeams']!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.primaryCyan,
                  fontFamily: 'monospace',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '3v3',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textGray,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }
}
