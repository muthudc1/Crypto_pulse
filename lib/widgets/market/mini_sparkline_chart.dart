import 'package:flutter/material.dart';
import '../../config/theme.dart';

class MiniSparklineChart extends StatelessWidget {
  final List<double> data;
  final bool isPositive;
  final double width;
  final double height;

  const MiniSparklineChart({
    super.key,
    required this.data,
    required this.isPositive,
    this.width = 65,
    this.height = 28,
  });

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) {
      return SizedBox(width: width, height: height);
    }

    final lineColor = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(
          points: data,
          lineColor: lineColor,
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color lineColor;

  _SparklinePainter({
    required this.points,
    required this.lineColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    double minVal = points.first;
    double maxVal = points.first;

    for (final p in points) {
      if (p < minVal) minVal = p;
      if (p > maxVal) maxVal = p;
    }

    final range = (maxVal - minVal) == 0 ? 1.0 : (maxVal - minVal);
    final double stepX = size.width / (points.length - 1);

    final path = Path();
    final fillPath = Path();

    final firstY = size.height - ((points.first - minVal) / range) * (size.height - 4) - 2;
    path.moveTo(0, firstY);
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, firstY);

    for (int i = 1; i < points.length; i++) {
      final x = i * stepX;
      final y = size.height - ((points[i] - minVal) / range) * (size.height - 4) - 2;
      path.lineTo(x, y);
      fillPath.lineTo(x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    // Fill area gradient
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: [
          lineColor.withOpacity(0.25),
          lineColor.withOpacity(0.0),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);

    // Stroke line
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.lineColor != lineColor;
  }
}
