import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../models/coin_market.dart';
import '../providers/market_stats_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/formatters.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/skeleton_loaders.dart';
import '../widgets/common/stat_badge.dart';
import 'coin_detail_screen.dart';

class MarketStatisticsScreen extends StatefulWidget {
  const MarketStatisticsScreen({super.key});

  @override
  State<MarketStatisticsScreen> createState() => _MarketStatisticsScreenState();
}

class _MarketStatisticsScreenState extends State<MarketStatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = context.read<SettingsProvider>().currency;
      context.read<MarketStatsProvider>().fetchStats(vsCurrency: currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsProv = context.watch<MarketStatsProvider>();
    final settings = context.watch<SettingsProvider>();
    final global = statsProv.globalData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Research & Stats'),
      ),
      body: RefreshIndicator(
        onRefresh: () => statsProv.refresh(),
        color: AppTheme.primaryLight,
        backgroundColor: AppTheme.darkSurface,
        child: Builder(
          builder: (context) {
            if (statsProv.isLoading && global == null) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    SkeletonLoaders.marketBannerSkeleton(),
                    const SizedBox(height: 16),
                    SkeletonLoaders.statsGridSkeleton(),
                  ],
                ),
              );
            }

            if (statsProv.errorMessage != null && global == null) {
              return ErrorView(
                message: statsProv.errorMessage,
                onRetry: () => statsProv.refresh(),
              );
            }

            if (global == null) {
              return const Center(child: Text('Market data unavailable'));
            }

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Global Overview Card
                  _buildGlobalMetricsCard(global, settings.currencySymbol),
                  const SizedBox(height: 20),

                  // Dominance Breakdown Card
                  _buildDominanceCard(global),
                  const SizedBox(height: 24),

                  // Top Gainers Section
                  _buildSectionHeader('🚀 Top 24h Gainers', 'Highest % increase in last 24h'),
                  const SizedBox(height: 12),
                  _buildMiniCoinGrid(statsProv.topGainers, settings.currencySymbol),
                  const SizedBox(height: 24),

                  // Top Losers Section
                  _buildSectionHeader('📉 Top 24h Losers', 'Largest % decrease in last 24h'),
                  const SizedBox(height: 12),
                  _buildMiniCoinGrid(statsProv.topLosers, settings.currencySymbol),
                  const SizedBox(height: 24),

                  // Top Volume Section
                  _buildSectionHeader('🔥 Most Traded (24h Volume)', 'Highest capital turnover'),
                  const SizedBox(height: 12),
                  _buildVolumeList(statsProv.highestVolume, settings.currencySymbol),
                  const SizedBox(height: 24),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textMuted,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGlobalMetricsCard(dynamic global, String symbol) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Market Capitalization',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              StatBadge(percentage: global.marketCapChangePercentage24hUsd),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            Formatters.formatCurrency(global.totalMarketCapUsd, symbol: symbol),
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(
                  '24h Volume',
                  Formatters.formatCompactCurrency(global.totalVolume24hUsd, symbol: symbol),
                  Icons.bar_chart_rounded,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Active Cryptos',
                  Formatters.formatSupply(global.activeCryptocurrencies),
                  Icons.token_rounded,
                ),
              ),
              Expanded(
                child: _buildMetricTile(
                  'Markets',
                  Formatters.formatSupply(global.markets),
                  Icons.storefront_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: AppTheme.textMuted),
            const SizedBox(width: 4),
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
          ],
        ),
        const SizedBox(height: 4),
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

  Widget _buildDominanceCard(dynamic global) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Share Dominance',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 14),
          _buildDominanceRow('Bitcoin (BTC)', global.btcDominance, const Color(0xFFF7931A)),
          const SizedBox(height: 10),
          _buildDominanceRow('Ethereum (ETH)', global.ethDominance, const Color(0xFF627EEA)),
          const SizedBox(height: 10),
          _buildDominanceRow('Tether (USDT)', global.usdtDominance, const Color(0xFF26A17B)),
        ],
      ),
    );
  }

  Widget _buildDominanceRow(String name, double percentage, Color color) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
            ),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(3),
          child: LinearProgressIndicator(
            value: (percentage / 100).clamp(0.0, 1.0),
            backgroundColor: AppTheme.darkSurfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 5,
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCoinGrid(List<CoinMarket> coins, String symbol) {
    if (coins.isEmpty) {
      return const Text(
        'No data available',
        style: TextStyle(color: AppTheme.textMuted, fontSize: 12),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.65,
      ),
      itemCount: coins.length,
      itemBuilder: (context, index) {
        final coin = coins[index];
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CoinDetailScreen(
                  coinId: coin.id,
                  initialName: coin.name,
                  initialSymbol: coin.symbol,
                  initialImage: coin.image,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: CachedNetworkImage(
                    imageUrl: coin.image,
                    width: 28,
                    height: 28,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => const SizedBox(width: 28),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          coin.symbol,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          Formatters.formatCurrency(coin.currentPrice, symbol: symbol),
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 4),
                StatBadge(
                  percentage: coin.priceChangePercentage24h,
                  compact: true,
                  fontSize: 9.5,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildVolumeList(List<CoinMarket> coins, String symbol) {
    return Column(
      children: coins.map((coin) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.darkCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.darkBorder),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: CachedNetworkImage(
                  imageUrl: coin.image,
                  width: 28,
                  height: 28,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  coin.name,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Formatters.formatCompactCurrency(coin.totalVolume, symbol: symbol),
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    'Vol: ${Formatters.formatCurrency(coin.currentPrice, symbol: symbol)}',
                    style: const TextStyle(
                      color: AppTheme.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
