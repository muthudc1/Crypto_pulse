import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/market_chart_data.dart';
import '../../providers/coin_detail_provider.dart';
import '../../utils/formatters.dart';

class InteractivePriceChart extends StatefulWidget {
  final MarketChartData? chartData;
  final ChartTimeRange selectedRange;
  final Function(ChartTimeRange) onRangeChanged;
  final Function(ChartPoint?) onTouchPointChanged;
  final String currencySymbol;
  final bool isLoading;

  const InteractivePriceChart({
    super.key,
    required this.chartData,
    required this.selectedRange,
    required this.onRangeChanged,
    required this.onTouchPointChanged,
    this.currencySymbol = '\$',
    this.isLoading = false,
  });

  @override
  State<InteractivePriceChart> createState() => _InteractivePriceChartState();
}

class _InteractivePriceChartState extends State<InteractivePriceChart> {
  @override
  Widget build(BuildContext context) {
    final data = widget.chartData;
    final hasData = data != null && data.prices.isNotEmpty;
    final isGain = hasData ? data.isGain : true;
    final lineColor = isGain ? AppTheme.gainGreen : AppTheme.lossRed;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Time range selector chips
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: ChartTimeRange.values.map((range) {
                final isSelected = widget.selectedRange == range;
                return InkWell(
                  onTap: () {
                    if (!isSelected && !widget.isLoading) {
                      widget.onTouchPointChanged(null);
                      widget.onRangeChanged(range);
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.darkSurfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      range.label,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Chart Display
          SizedBox(
            height: 240,
            child: Stack(
              children: [
                if (hasData) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 16, left: 16, top: 10, bottom: 8),
                    child: LineChart(
                      _buildLineChartData(data, lineColor),
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                    ),
                  ),
                ] else if (!widget.isLoading) ...[
                  const Center(
                    child: Text(
                      'No historical chart data available',
                      style: TextStyle(color: AppTheme.textMuted),
                    ),
                  ),
                ],

                // Loading overlay indicator
                if (widget.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: AppTheme.darkCard.withOpacity(0.7),
                      child: const Center(
                        child: SizedBox(
                          width: 28,
                          height: 28,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppTheme.primaryLight,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  LineChartData _buildLineChartData(MarketChartData data, Color lineColor) {
    // Sample points if too many (e.g. 365 days) for ultra-smooth 60fps rendering
    final rawList = data.prices;
    final int step = (rawList.length / 100).ceil().clamp(1, 10);

    final List<FlSpot> spots = [];
    final List<ChartPoint> sampledPoints = [];

    for (int i = 0; i < rawList.length; i += step) {
      spots.add(FlSpot(i.toDouble(), rawList[i].price));
      sampledPoints.add(rawList[i]);
    }
    // Always include the very last spot
    if (rawList.isNotEmpty && spots.last.x != (rawList.length - 1).toDouble()) {
      spots.add(FlSpot((rawList.length - 1).toDouble(), rawList.last.price));
      sampledPoints.add(rawList.last);
    }

    final double minY = data.minPrice * 0.995;
    final double maxY = data.maxPrice * 1.005;

    return LineChartData(
      minY: minY,
      maxY: maxY,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) > 0 ? (maxY - minY) / 4 : 1,
        getDrawingHorizontalLine: (value) => FlLine(
          color: AppTheme.darkBorder.withOpacity(0.4),
          strokeWidth: 0.8,
          dashArray: [4, 4],
        ),
      ),
      titlesData: const FlTitlesData(show: false),
      borderData: FlBorderData(show: false),
      lineTouchData: LineTouchData(
        enabled: true,
        handleBuiltInTouches: true,
        touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
          if (response == null ||
              response.lineBarSpots == null ||
              response.lineBarSpots!.isEmpty) {
            if (event is FlTapUpEvent || event is FlPanEndEvent) {
              widget.onTouchPointChanged(null);
            }
            return;
          }

          final touchedSpot = response.lineBarSpots!.first;
          final idx = touchedSpot.spotIndex;
          if (idx >= 0 && idx < sampledPoints.length) {
            widget.onTouchPointChanged(sampledPoints[idx]);
          }
        },
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppTheme.darkSurfaceVariant,
          tooltipPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          getTooltipItems: (touchedSpots) {
            return touchedSpots.map((spot) {
              final idx = spot.spotIndex;
              if (idx >= 0 && idx < sampledPoints.length) {
                final pt = sampledPoints[idx];
                final dateStr = Formatters.formatChartDate(
                  pt.timestamp,
                  widget.selectedRange.days,
                );
                return LineTooltipItem(
                  '${Formatters.formatCurrency(pt.price, symbol: widget.currencySymbol)}\n$dateStr',
                  const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          curveSmoothness: 0.15,
          preventCurveOverShooting: true,
          color: lineColor,
          barWidth: 2.2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                lineColor.withOpacity(0.28),
                lineColor.withOpacity(0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }
}
