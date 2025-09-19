import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../theme/app_theme.dart';

class BattleTimer extends StatefulWidget {
  final DateTime startTime;
  final int duration;

  const BattleTimer({
    super.key,
    required this.startTime,
    required this.duration,
  });

  @override
  State<BattleTimer> createState() => _BattleTimerState();
}

class _BattleTimerState extends State<BattleTimer> {
  late Duration _remainingTime;
  late DateTime _endTime;

  @override
  void initState() {
    super.initState();
    _endTime = widget.startTime.add(Duration(minutes: widget.duration));
    _updateRemainingTime();
    
    // Update every second
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _updateRemainingTime();
        return _remainingTime.inSeconds > 0;
      }
      return false;
    });
  }

  void _updateRemainingTime() {
    final now = DateTime.now();
    if (now.isAfter(_endTime)) {
      _remainingTime = Duration.zero;
    } else {
      _remainingTime = _endTime.difference(now);
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _remainingTime.inMinutes;
    final seconds = _remainingTime.inSeconds % 60;
    final isUrgent = minutes < 5;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundGray.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUrgent ? AppTheme.primaryRed : AppTheme.borderGray,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.clock,
                color: isUrgent ? AppTheme.primaryRed : AppTheme.textWhite,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Time Remaining',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: isUrgent ? AppTheme.primaryRed : AppTheme.textWhite,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: isUrgent ? AppTheme.primaryRed : AppTheme.textWhite,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          if (isUrgent) ...[
            const SizedBox(height: 4),
            Text(
              'URGENT!',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
