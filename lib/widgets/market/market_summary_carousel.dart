import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/global_market_data.dart';
import '../../utils/formatters.dart';
import '../common/stat_badge.dart';

class MarketSummaryCarousel extends StatelessWidget {
  final GlobalMarketData? data;
  final String currencySymbol;

  const MarketSummaryCarousel({
    super.key,
    required this.data,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    if (data == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.darkCard,
            AppTheme.darkSurfaceVariant.withOpacity(0.6),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.darkBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppTheme.gainGreen,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Global Crypto Market',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              StatBadge(
                percentage: data!.marketCapChangePercentage24hUsd,
                compact: true,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                Formatters.formatCompactCurrency(data!.totalMarketCapUsd, symbol: currencySymbol),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Market Cap',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          // Sub-stats in 3 columns
          Row(
            children: [
              Expanded(
                child: _buildMetricItem(
                  '24h Volume',
                  Formatters.formatCompactCurrency(data!.totalVolume24hUsd, symbol: currencySymbol),
                ),
              ),
              Container(width: 1, height: 28, color: AppTheme.darkBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: _buildDominanceItem(
                    'BTC Dom',
                    '${data!.btcDominance.toStringAsFixed(1)}%',
                    data!.btcDominance / 100,
                    const Color(0xFFF7931A), // Bitcoin orange
                  ),
                ),
              ),
              Container(width: 1, height: 28, color: AppTheme.darkBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: _buildDominanceItem(
                    'ETH Dom',
                    '${data!.ethDominance.toStringAsFixed(1)}%',
                    data!.ethDominance / 100,
                    const Color(0xFF627EEA), // Ethereum blue
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 11,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDominanceItem(String label, String value, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(2),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: AppTheme.darkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 3.5,
          ),
        ),
      ],
    );
  }
}
