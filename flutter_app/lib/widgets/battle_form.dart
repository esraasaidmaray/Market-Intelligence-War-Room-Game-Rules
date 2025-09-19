import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../providers/game_provider.dart';
import '../models/player.dart';
import '../models/match.dart';
import '../widgets/gradient_button.dart';
import '../theme/app_theme.dart';

class BattleForm extends StatefulWidget {
  final String matchId;
  final Player player;
  final Match match;

  const BattleForm({
    super.key,
    required this.matchId,
    required this.player,
    required this.match,
  });

  @override
  State<BattleForm> createState() => _BattleFormState();
}

class _BattleFormState extends State<BattleForm> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _initializeFormData();
  }

  void _initializeFormData() {
    // Initialize form data based on battle type
    final battleId = _getBattleIdForPlayer();
    final fields = _getFieldsForBattle(battleId);
    
    for (final field in fields) {
      _formData[field['id']] = '';
    }
  }

  String _getBattleIdForPlayer() {
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
    
    return battleMap[widget.player.subTeam] ?? 'leadership_recon';
  }

  List<Map<String, dynamic>> _getFieldsForBattle(String battleId) {
    // This would contain the actual field definitions for each battle
    // For now, returning a simplified version
    return [
      {
        'id': 'field1',
        'label': 'Primary Information',
        'type': 'text',
        'required': true,
        'placeholder': 'Enter primary information',
      },
      {
        'id': 'field2',
        'label': 'Secondary Details',
        'type': 'textarea',
        'required': false,
        'placeholder': 'Enter secondary details',
      },
      {
        'id': 'field3',
        'label': 'Source Link',
        'type': 'url',
        'required': true,
        'placeholder': 'https://example.com',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    final battleId = _getBattleIdForPlayer();
    final battleName = _getBattleName(battleId);
    final progress = _calculateProgress();

    return Container(
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
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: AppTheme.borderGray.withOpacity(0.5),
                  width: 1,
                ),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            battleName,
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: AppTheme.primaryCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Intelligence gathering on company data',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Sub-Team: ${widget.player.subTeam}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textGray,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Progress: $progress%',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textWhite,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: AppTheme.borderGray,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryCyan),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Intelligence Capture Form',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppTheme.textWhite,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Form Fields
                    ..._getFieldsForBattle(battleId).map((field) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _buildFormField(field),
                      );
                    }).toList(),

                    const SizedBox(height: 20),

                    // Submit Button
                    GradientButton(
                      onPressed: _isSubmitting ? null : _submitForm,
                      gradient: AppTheme.cyanBlueGradient,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_isSubmitting) ...[
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.black,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else ...[
                            const Icon(LucideIcons.send, color: Colors.black, size: 20),
                            const SizedBox(width: 8),
                          ],
                          Text(
                            _isSubmitting ? 'Submitting...' : 'Submit Intelligence ($progress%)',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField(Map<String, dynamic> field) {
    final fieldType = field['type'] as String;
    final isRequired = field['required'] as bool;
    final fieldId = field['id'] as String;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              field['label'] as String,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTheme.textWhite,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isRequired) ...[
              const SizedBox(width: 4),
              Text(
                '*',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryRed,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        
        if (fieldType == 'textarea')
          TextFormField(
            maxLines: 3,
            decoration: InputDecoration(
              hintText: field['placeholder'] as String,
            ),
            onChanged: (value) => _formData[fieldId] = value,
            validator: isRequired ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              return null;
            } : null,
          )
        else
          TextFormField(
            keyboardType: fieldType == 'url' ? TextInputType.url : TextInputType.text,
            decoration: InputDecoration(
              hintText: field['placeholder'] as String,
            ),
            onChanged: (value) => _formData[fieldId] = value,
            validator: isRequired ? (value) {
              if (value == null || value.trim().isEmpty) {
                return 'This field is required';
              }
              if (fieldType == 'url' && !_isValidUrl(value)) {
                return 'Please enter a valid URL';
              }
              return null;
            } : null,
          ),
      ],
    );
  }

  bool _isValidUrl(String url) {
    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  int _calculateProgress() {
    final requiredFields = _getFieldsForBattle(_getBattleIdForPlayer())
        .where((field) => field['required'] as bool)
        .length;
    
    if (requiredFields == 0) return 100;
    
    final filledFields = _getFieldsForBattle(_getBattleIdForPlayer())
        .where((field) {
          final fieldId = field['id'] as String;
          final value = _formData[fieldId];
          return field['required'] as bool && 
                 value != null && 
                 value.toString().trim().isNotEmpty;
        })
        .length;
    
    return ((filledFields / requiredFields) * 100).round();
  }

  String _getBattleName(String battleId) {
    const battleNames = {
      'leadership_recon': 'Leadership Recon & Market Dominance',
      'product_arsenal': 'Product Arsenal & Social Signals Strike',
      'funding_fortification': 'Funding Fortification',
      'customer_frontlines': 'Customer Frontlines',
      'alliance_forge': 'Alliance Forge & Growth Offensive',
    };
    
    return battleNames[battleId] ?? 'Battle';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final gameProvider = context.read<GameProvider>();
      final battleId = _getBattleIdForPlayer();
      
      // Extract source links
      final sources = <Map<String, dynamic>>[];
      for (final field in _getFieldsForBattle(battleId)) {
        if (field['type'] == 'url') {
          final fieldId = field['id'] as String;
          final url = _formData[fieldId];
          if (url != null && url.toString().trim().isNotEmpty) {
            sources.add({
              'url': url,
              'description': 'Source for ${field['label']}',
              'quality_score': 0.0,
            });
          }
        }
      }

      await gameProvider.submitBattleData(
        battleId: battleId,
        submissionData: _formData,
        sources: sources.map((s) => Source(
          url: s['url'],
          description: s['description'],
          qualityScore: s['quality_score'],
        )).toList(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Intelligence submitted successfully!'),
            backgroundColor: AppTheme.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to submit: $e'),
            backgroundColor: AppTheme.primaryRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }
}

// Import the Source class
class Source {
  final String url;
  final String description;
  final double qualityScore;

  Source({
    required this.url,
    required this.description,
    required this.qualityScore,
  });
}
