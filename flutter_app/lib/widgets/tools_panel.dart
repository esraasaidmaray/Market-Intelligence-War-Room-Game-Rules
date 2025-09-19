import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';

class ToolsPanel extends StatelessWidget {
  final String battleId;

  const ToolsPanel({
    super.key,
    required this.battleId,
  });

  static const Map<String, List<Map<String, String>>> battleTools = {
    'leadership_recon': [
      {'name': 'LinkedIn Sales Navigator', 'url': 'https://www.linkedin.com/sales/navigator'},
      {'name': 'Crunchbase', 'url': 'https://www.crunchbase.com'},
      {'name': 'PitchBook', 'url': 'https://pitchbook.com'},
      {'name': 'BoardEx', 'url': 'https://www.boardex.com'},
      {'name': 'ZoomInfo', 'url': 'https://www.zoominfo.com'},
      {'name': 'Statista', 'url': 'https://www.statista.com'},
    ],
    'product_arsenal': [
      {'name': 'Company Website', 'url': '#'},
      {'name': 'Trustpilot', 'url': 'https://www.trustpilot.com'},
      {'name': 'G2', 'url': 'https://www.g2.com'},
      {'name': 'USPTO Patent Database', 'url': 'https://www.uspto.gov'},
      {'name': 'SEMrush', 'url': 'https://www.semrush.com'},
      {'name': 'Social Blade', 'url': 'https://socialblade.com'},
    ],
    'funding_fortification': [
      {'name': 'Crunchbase', 'url': 'https://www.crunchbase.com'},
      {'name': 'PitchBook', 'url': 'https://pitchbook.com'},
      {'name': 'SEC Filings', 'url': 'https://www.sec.gov/edgar'},
      {'name': 'Tracxn', 'url': 'https://tracxn.com'},
      {'name': 'Reuters', 'url': 'https://www.reuters.com'},
      {'name': 'Bloomberg', 'url': 'https://www.bloomberg.com'},
    ],
    'customer_frontlines': [
      {'name': 'Customer Surveys', 'url': '#'},
      {'name': 'Trustpilot', 'url': 'https://www.trustpilot.com'},
      {'name': 'G2', 'url': 'https://www.g2.com'},
      {'name': 'Google Reviews', 'url': 'https://www.google.com/business'},
      {'name': 'App Store Reviews', 'url': 'https://www.apple.com/app-store'},
      {'name': 'Google Play Reviews', 'url': 'https://play.google.com/console'},
    ],
    'alliance_forge': [
      {'name': 'Press Releases', 'url': '#'},
      {'name': 'BuiltWith', 'url': 'https://builtwith.com'},
      {'name': 'Company Annual Reports', 'url': '#'},
      {'name': 'Google News', 'https://news.google.com'},
      {'name': 'Crunchbase', 'url': 'https://www.crunchbase.com'},
      {'name': 'Industry Reports', 'url': '#'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    final tools = battleTools[battleId] ?? battleTools['leadership_recon']!;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                LucideIcons.bookOpen,
                color: AppTheme.primaryOrange,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Suggested Tools',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryOrange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          ...tools.map((tool) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => _launchUrl(tool['url']!),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundGray.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.borderGray.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.externalLink,
                        color: AppTheme.primaryBlue,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          tool['name']!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.primaryBlue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (url == '#') return;
    
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      // Handle error silently
    }
  }
}
