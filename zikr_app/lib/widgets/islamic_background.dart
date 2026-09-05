import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Мягкий фоновый узор в исламском геометрическом стиле —
/// повторяющиеся 8-лучевые звёзды (мотив "хатам"), очень низкая
/// непрозрачность, чтобы не мешать читаемости текста поверх.
class IslamicPatternPainter extends CustomPainter {
  final Color color;
  final double spacing;

  IslamicPatternPainter({required this.color, this.spacing = 72});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (double y = -spacing; y < size.height + spacing; y += spacing) {
      for (double x = -spacing; x < size.width + spacing; x += spacing) {
        _drawStar(canvas, Offset(x, y), spacing * 0.4, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    const points = 8;
    final path = Path();
    for (int i = 0; i <= points * 2; i++) {
      final angle = (math.pi / points) * i - math.pi / 2;
      final radius = i.isEven ? r : r * 0.5;
      final dx = center.dx + radius * math.cos(angle);
      final dy = center.dy + radius * math.sin(angle);
      if (i == 0) {
        path.moveTo(dx, dy);
      } else {
        path.lineTo(dx, dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant IslamicPatternPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.spacing != spacing;
}

/// Готовый декоративный фон экрана: мягкий вертикальный градиент
/// цвета темы + узор поверх. Оборачивает body в Scaffold.
class IslamicBackground extends StatelessWidget {
  final Widget child;
  const IslamicBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
                    ? [
                        scheme.primary.withValues(alpha: 0.16),
                        scheme.surface,
                      ]
                    : [
                        scheme.primary.withValues(alpha: 0.10),
                        scheme.surface,
                      ],
              ),
            ),
          ),
        ),
        Positioned.fill(
          child: CustomPaint(
            painter: IslamicPatternPainter(
              color: scheme.primary.withValues(alpha: isDark ? 0.10 : 0.06),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
