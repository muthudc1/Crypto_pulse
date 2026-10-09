import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';

class StatBadge extends StatelessWidget {
  final double? percentage;
  final bool compact;
  final double fontSize;

  const StatBadge({
    super.key,
    required this.percentage,
    this.compact = false,
    this.fontSize = 12,
  });

  @override
  Widget build(BuildContext context) {
    final val = percentage ?? 0.0;
    final isPositive = val >= 0;
    final color = isPositive ? AppTheme.gainGreen : AppTheme.lossRed;
    final bgColor = isPositive ? AppTheme.gainGreenSoft : AppTheme.lossRedSoft;
    final icon = isPositive ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: fontSize + 4,
            color: color,
          ),
          Text(
            Formatters.formatPercentage(val, includeSign: false),
            style: TextStyle(
              color: color,
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }
}
