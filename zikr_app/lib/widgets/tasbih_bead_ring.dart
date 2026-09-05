import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Кольцо из 33 бусин (классическое число для тасбиха), расположенных
/// по кругу вокруг центральной кнопки. Бусины "зажигаются" по мере
/// прогресса к цели — стеклянный (liquid glass) стиль: полупрозрачные
/// шарики со свечением у "пройденных" бусин.
///
/// Прогресс считается от общего процента выполнения цели (_counter/goal),
/// поэтому кольцо одинаково хорошо работает и для целей 33/99, и для
/// произвольного числа — крупные цели просто заполняют кольцо
/// пропорционально проценту выполнения.
class TasbihBeadRing extends StatelessWidget {
  final double progress; // 0.0 - 1.0
  final double size;
  final Color color;

  const TasbihBeadRing({
    super.key,
    required this.progress,
    required this.size,
    required this.color,
  });

  static const int beadCount = 33;

  @override
  Widget build(BuildContext context) {
    final clamped = progress.clamp(0.0, 1.0);
    final filled = (clamped * beadCount).round();
    final radius = size / 2;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(beadCount, (i) {
          final angle = (2 * math.pi * i / beadCount) - math.pi / 2;
          final isImam = i == 0; // декоративная "разделительная" бусина
          final beadDiameter = isImam ? size * 0.075 : size * 0.055;
          final orbit = radius - beadDiameter;
          final dx = orbit * math.cos(angle);
          final dy = orbit * math.sin(angle);

          return Transform.translate(
            offset: Offset(dx, dy),
            child: _GlassBead(
              lit: i < filled,
              diameter: beadDiameter,
              big: isImam,
              color: color,
            ),
          );
        }),
      ),
    );
  }
}

class _GlassBead extends StatelessWidget {
  final bool lit;
  final bool big;
  final double diameter;
  final Color color;

  const _GlassBead({
    required this.lit,
    required this.big,
    required this.diameter,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: lit
              ? [
                  Colors.white.withValues(alpha: 0.95),
                  color.withValues(alpha: 0.9),
                  color,
                ]
              : [
                  Colors.white.withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.15),
                  Colors.white.withValues(alpha: 0.08),
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
        border: Border.all(
          color: Colors.white.withValues(alpha: lit ? 0.9 : 0.35),
          width: big ? 1.4 : 0.9,
        ),
        boxShadow: lit
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.65),
                  blurRadius: big ? 14 : 9,
                  spreadRadius: big ? 1.5 : 0.5,
                ),
              ]
            : [],
      ),
    );
  }
}
