import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/coin_detail.dart';
import '../models/coin_market.dart';
import '../models/market_chart_data.dart';
import '../providers/coin_detail_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/watchlist_provider.dart';
import '../utils/formatters.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/skeleton_loaders.dart';
import '../widgets/common/stat_badge.dart';
import '../widgets/details/coin_stats_grid.dart';
import '../widgets/details/expandable_text.dart';
import '../widgets/details/interactive_price_chart.dart';

class CoinDetailScreen extends StatefulWidget {
  final String coinId;
  final String? initialName;
  final String? initialSymbol;
  final String? initialImage;

  const CoinDetailScreen({
    super.key,
    required this.coinId,
    this.initialName,
    this.initialSymbol,
    this.initialImage,
  });

  @override
  State<CoinDetailScreen> createState() => _CoinDetailScreenState();
}

class _CoinDetailScreenState extends State<CoinDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = context.read<SettingsProvider>().currency;
      context.read<CoinDetailProvider>().loadCoinData(
            widget.coinId,
            vsCurrency: currency,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final detailProv = context.watch<CoinDetailProvider>();
    final watchlistProv = context.watch<WatchlistProvider>();
    final settings = context.watch<SettingsProvider>();
    final detail = detailProv.coinDetail;
    final isWatched = watchlistProv.isWatched(widget.coinId);

    final title = detail?.name ?? widget.initialName ?? 'Coin Details';
    final symbol = detail?.symbol ?? widget.initialSymbol ?? '';
    final imageUrl = detail?.imageLarge ?? widget.initialImage;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  width: 28,
                  height: 28,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) => const SizedBox(width: 28),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (symbol.isNotEmpty)
                    Text(
                      symbol,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          if (detail != null && detail.marketCapRank > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.darkBorder),
              ),
              child: Text(
                '#${detail.marketCapRank}',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isWatched ? Icons.star_rounded : Icons.star_border_rounded,
              color: isWatched ? Colors.amber : AppTheme.textSecondary,
              size: 26,
            ),
            onPressed: () {
              if (detail != null) {
                // Construct CoinMarket representation for watchlist
                final coinMarket = CoinMarket(
                  id: detail.id,
                  symbol: detail.symbol,
                  name: detail.name,
                  image: detail.imageLarge ?? detail.imageSmall ?? '',
                  currentPrice: detail.currentPrice,
                  marketCap: detail.marketCap,
                  marketCapRank: detail.marketCapRank,
                  totalVolume: detail.totalVolume,
                  high24h: detail.high24h,
                  low24h: detail.low24h,
                  priceChange24h: detail.priceChange24h,
                  priceChangePercentage24h: detail.priceChangePercentage24h,
                  circulatingSupply: detail.circulatingSupply,
                  ath: detail.ath,
                  athChangePercentage: detail.athChangePercentage,
                  atl: detail.atl,
                  atlChangePercentage: detail.atlChangePercentage,
                );
                watchlistProv.toggleWatchlist(coinMarket);
              } else {
                if (isWatched) {
                  watchlistProv.removeFromWatchlist(widget.coinId);
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isWatched ? 'Removed from Watchlist' : 'Added to Watchlist',
                  ),
                  duration: const Duration(seconds: 1),
                  backgroundColor: AppTheme.darkSurfaceVariant,
                ),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await detailProv.loadCoinData(
            widget.coinId,
            vsCurrency: settings.currency,
            forceRefresh: true,
          );
        },
        color: AppTheme.primaryLight,
        backgroundColor: AppTheme.darkSurface,
        child: Builder(
          builder: (context) {
            if (detailProv.isLoadingDetail && detail == null) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    SkeletonLoaders.chartSkeleton(),
                    const SizedBox(height: 16),
                    SkeletonLoaders.statsGridSkeleton(),
                  ],
                ),
              );
            }

            if (detailProv.detailError != null && detail == null) {
              return ErrorView(
                message: detailProv.detailError,
                onRetry: () {
                  detailProv.loadCoinData(
                    widget.coinId,
                    vsCurrency: settings.currency,
                    forceRefresh: true,
                  );
                },
              );
            }

            if (detail == null) {
              return const Center(child: Text('Coin data unavailable'));
            }

            // Price scrubbing interaction calculations
            final touchedPoint = detailProv.touchedPoint;
            final currentDisplayPrice =
                touchedPoint != null ? touchedPoint.price : detail.currentPrice;

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price Header Card
                  _buildPriceHeader(detail, currentDisplayPrice, touchedPoint, settings.currencySymbol),
                  const SizedBox(height: 16),

                  // Interactive Chart
                  InteractivePriceChart(
                    chartData: detailProv.chartData,
                    selectedRange: detailProv.selectedTimeRange,
                    isLoading: detailProv.isLoadingChart,
                    currencySymbol: settings.currencySymbol,
                    onRangeChanged: (range) {
                      detailProv.fetchChart(
                        widget.coinId,
                        range,
                        vsCurrency: settings.currency,
                      );
                    },
                    onTouchPointChanged: (point) {
                      detailProv.setTouchedPoint(point);
                    },
                  ),
                  const SizedBox(height: 16),

                  // Fundamental Market Statistics Grid
                  CoinStatsGrid(
                    detail: detail,
                    currencySymbol: settings.currencySymbol,
                  ),
                  const SizedBox(height: 16),

                  // Asset Description
                  ExpandableDescription(text: detail.description),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPriceHeader(
    CoinDetail detail,
    double displayPrice,
    ChartPoint? touchedPoint,
    String currencySymbol,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Formatters.formatCurrency(displayPrice, symbol: currencySymbol),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              if (touchedPoint != null)
                Text(
                  'Scrubbed: ${Formatters.formatChartDate(touchedPoint.timestamp, "7")}',
                  style: const TextStyle(
                    color: AppTheme.accentCyan,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                Row(
                  children: [
                    Text(
                      '24h Change: ',
                      style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                    ),
                    Text(
                      Formatters.formatCurrency(detail.priceChange24h, symbol: currencySymbol),
                      style: TextStyle(
                        color: detail.priceChange24h >= 0 ? AppTheme.gainGreen : AppTheme.lossRed,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          StatBadge(
            percentage: detail.priceChangePercentage24h,
            fontSize: 13,
          ),
        ],
      ),
    );
  }
}
