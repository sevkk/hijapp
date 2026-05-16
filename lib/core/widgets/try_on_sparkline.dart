import 'package:flutter/material.dart';
import '../utils/constants.dart';

/// Spec v2 Bolum 8 — urun kartinda inline mini bar chart.
/// fl_chart dependency'sini mobile'a getirmemek icin saf CustomPainter.
class TryOnSparkline extends StatelessWidget {
  final List<int> values;
  final double height;
  final Color barColor;

  const TryOnSparkline({
    super.key,
    required this.values,
    this.height = 28,
    this.barColor = AppColors.gold,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(values, barColor),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<int> values;
  final Color color;
  _SparklinePainter(this.values, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.reduce((a, b) => a > b ? a : b).toDouble();
    if (maxV <= 0) return;
    final barWidth = size.width / values.length;
    final gap = barWidth * 0.2;
    final actualWidth = barWidth - gap;
    final paint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final h = (values[i] / maxV) * size.height;
      final x = i * barWidth + gap / 2;
      final y = size.height - h;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y, actualWidth, h),
          const Radius.circular(2),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => old.values != values || old.color != color;
}
