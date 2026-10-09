import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/coin_market.dart';
import '../../utils/formatters.dart';
import '../common/stat_badge.dart';
import 'mini_sparkline_chart.dart';

class CoinListItem extends StatelessWidget {
  final CoinMarket coin;
  final String currencySymbol;
  final VoidCallback onTap;
  final bool isWatchlisted;
  final VoidCallback? onWatchlistToggle;

  const CoinListItem({
    super.key,
    required this.coin,
    this.currencySymbol = '\$',
    required this.onTap,
    this.isWatchlisted = false,
    this.onWatchlistToggle,
  });

  @override
  Widget build(BuildContext context) {
    final isGain = coin.priceChangePercentage24h >= 0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: AppTheme.primary.withOpacity(0.1),
        highlightColor: AppTheme.darkSurfaceVariant,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard.withOpacity(0.7),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppTheme.darkBorder.withOpacity(0.6),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Rank indicator
              SizedBox(
                width: 22,
                child: Text(
                  coin.marketCapRank > 0 ? '${coin.marketCapRank}' : '-',
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 8),

              // Coin Logo
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: coin.image,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 36,
                    height: 36,
                    color: AppTheme.darkSurfaceVariant,
                    child: const Center(
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppTheme.darkSurfaceVariant,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        coin.symbol.isNotEmpty ? coin.symbol.substring(0, 1) : '?',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Coin Name & Symbol + Market Cap
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Text(
                          coin.symbol,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          width: 3,
                          height: 3,
                          decoration: const BoxDecoration(
                            color: AppTheme.textMuted,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'MCap ${Formatters.formatCompactCurrency(coin.marketCap, symbol: currencySymbol)}',
                            style: const TextStyle(
                              color: AppTheme.textMuted,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Sparkline Preview
              if (coin.sparklineIn7d.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: MiniSparklineChart(
                    data: coin.sparklineIn7d,
                    isPositive: isGain,
                    width: 58,
                    height: 26,
                  ),
                ),
              ],

              // Price & 24h Percentage
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCurrency(coin.currentPrice, symbol: currencySymbol),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  StatBadge(
                    percentage: coin.priceChangePercentage24h,
                    compact: true,
                    fontSize: 11,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
