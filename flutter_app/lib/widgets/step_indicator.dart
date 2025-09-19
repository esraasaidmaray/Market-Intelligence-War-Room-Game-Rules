import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StepIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const StepIndicator({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        final stepNumber = index + 1;
        final isActive = stepNumber <= currentStep;
        final isCompleted = stepNumber < currentStep;
        
        return Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: isActive ? AppTheme.cyanBlueGradient : null,
                color: isActive ? null : AppTheme.backgroundGray,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isActive ? Colors.transparent : AppTheme.borderGray,
                  width: 1,
                ),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(
                        Icons.check,
                        color: Colors.black,
                        size: 16,
                      )
                    : Text(
                        stepNumber.toString(),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: isActive ? Colors.black : AppTheme.textGray,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            if (index < totalSteps - 1)
              Container(
                width: 48,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: isCompleted ? AppTheme.primaryCyan : AppTheme.borderGray,
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
          ],
        );
      }),
    );
  }
}
