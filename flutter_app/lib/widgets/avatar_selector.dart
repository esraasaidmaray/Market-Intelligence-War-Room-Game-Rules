import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AvatarSelector extends StatelessWidget {
  final String selectedAvatar;
  final Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    required this.selectedAvatar,
    required this.onAvatarSelected,
  });

  static const List<Map<String, dynamic>> avatars = [
    {
      'id': 'agent1',
      'name': 'Agent Alpha',
      'gradient': AppTheme.cyanBlueGradient,
    },
    {
      'id': 'agent2',
      'name': 'Agent Beta',
      'gradient': AppTheme.greenEmeraldGradient,
    },
    {
      'id': 'agent3',
      'name': 'Agent Gamma',
      'gradient': AppTheme.orangeRedGradient,
    },
    {
      'id': 'agent4',
      'name': 'Agent Delta',
      'gradient': AppTheme.purplePinkGradient,
    },
    {
      'id': 'agent5',
      'name': 'Agent Omega',
      'gradient': AppTheme.yellowOrangeGradient,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        childAspectRatio: 1,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: avatars.length,
      itemBuilder: (context, index) {
        final avatar = avatars[index];
        final isSelected = selectedAvatar == avatar['id'];
        
        return GestureDetector(
          onTap: () => onAvatarSelected(avatar['id']),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: isSelected ? avatar['gradient'] : null,
              color: isSelected ? null : AppTheme.backgroundGray.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected 
                    ? Colors.transparent 
                    : AppTheme.borderGray.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: avatar['gradient'],
                shape: BoxShape.circle,
              ),
            ),
          ),
        );
      },
    );
  }
}
