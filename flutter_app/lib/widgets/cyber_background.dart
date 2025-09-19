import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CyberBackground extends StatelessWidget {
  final Widget child;
  final bool showGrid;

  const CyberBackground({
    super.key,
    required this.child,
    this.showGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.backgroundGradient,
      ),
      child: Stack(
        children: [
          if (showGrid) _buildCyberGrid(),
          _buildAmbientLights(),
          child,
        ],
      ),
    );
  }

  Widget _buildCyberGrid() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CyberGridPainter(),
      ),
    );
  }

  Widget _buildAmbientLights() {
    return Stack(
      children: [
        // Top left cyan light
        Positioned(
          top: -200,
          left: -200,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryCyan.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
        // Bottom right blue light
        Positioned(
          bottom: -200,
          right: -200,
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppTheme.primaryBlue.withOpacity(0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CyberGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.textWhite.withOpacity(0.02)
      ..strokeWidth = 0.5;

    const gridSize = 60.0;
    
    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }
    
    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
    
    // Draw diagonal pattern
    final diagonalPaint = Paint()
      ..color = AppTheme.primaryCyan.withOpacity(0.03)
      ..strokeWidth = 1.0;
    
    for (int i = 0; i < 20; i++) {
      final startX = i * gridSize;
      final startY = 0.0;
      final endX = 0.0;
      final endY = i * gridSize;
      
      if (startX < size.width && endY < size.height) {
        canvas.drawLine(
          Offset(startX, startY),
          Offset(endX, endY),
          diagonalPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
