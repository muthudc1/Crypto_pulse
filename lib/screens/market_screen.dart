import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/market_provider.dart';
import '../providers/market_stats_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/common/empty_state_view.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/skeleton_loaders.dart';
import '../widgets/market/coin_list_item.dart';
import '../widgets/market/filter_sort_bottom_sheet.dart';
import '../widgets/market/market_summary_carousel.dart';
import '../widgets/search/search_modal.dart';
import 'coin_detail_screen.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = context.read<SettingsProvider>().currency;
      context.read<MarketProvider>().fetchMarkets(vsCurrency: currency);
      context.read<MarketStatsProvider>().fetchStats(vsCurrency: currency);
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 300) {
      context.read<MarketProvider>().loadMore();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marketProv = context.watch<MarketProvider>();
    final statsProv = context.watch<MarketStatsProvider>();
    final watchlistProv = context.watch<WatchlistProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.currency_bitcoin_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CryptoPulse',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Real-time Market Intelligence',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.secondary.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Search Button
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            onPressed: () => SearchModal.show(context),
          ),
          // Filter & Sort Button
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.tune_rounded, size: 22),
                if (marketProv.selectedFilter != MarketFilter.all ||
                    marketProv.selectedSort != MarketSort.marketCapDesc)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentCyan,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () => FilterSortBottomSheet.show(
              context,
              selectedFilter: marketProv.selectedFilter,
              selectedSort: marketProv.selectedSort,
              onFilterSelected: (filter) => marketProv.setFilter(filter),
              onSortSelected: (sort) => marketProv.setSort(sort),
            ),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            marketProv.refresh(),
            statsProv.refresh(),
          ]);
        },
        color: AppTheme.primaryLight,
        backgroundColor: AppTheme.darkSurface,
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Global Market Overview Banner
            SliverToBoxAdapter(
              child: statsProv.globalData != null
                  ? MarketSummaryCarousel(
                      data: statsProv.globalData,
                      currencySymbol: settings.currencySymbol,
                    )
                  : (statsProv.isLoading
                      ? SkeletonLoaders.marketBannerSkeleton()
                      : const SizedBox.shrink()),
            ),

            // Active Filter & Sort Chips Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'All Cryptocurrencies',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const Spacer(),
                    if (marketProv.selectedFilter != MarketFilter.all)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.primary.withOpacity(0.5)),
                        ),
                        child: Text(
                          marketProv.selectedFilter.name.toUpperCase(),
                          style: const TextStyle(
                            color: AppTheme.primaryLight,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    InkWell(
                      onTap: () => FilterSortBottomSheet.show(
                        context,
                        selectedFilter: marketProv.selectedFilter,
                        selectedSort: marketProv.selectedSort,
                        onFilterSelected: (filter) => marketProv.setFilter(filter),
                        onSortSelected: (sort) => marketProv.setSort(sort),
                      ),
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppTheme.darkBorder),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.sort_rounded, size: 14, color: AppTheme.textSecondary),
                            const SizedBox(width: 4),
                            Text(
                              marketProv.selectedSort.label.split('(').first.trim(),
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Market List Content
            _buildMarketListSliver(marketProv, watchlistProv, settings),
          ],
        ),
      ),
    );
  }

  Widget _buildMarketListSliver(
    MarketProvider marketProv,
    WatchlistProvider watchlistProv,
    SettingsProvider settings,
  ) {
    if (marketProv.isLoading && marketProv.coins.isEmpty) {
      return SliverToBoxAdapter(
        child: SkeletonLoaders.coinListSkeleton(itemCount: 10),
      );
    }

    if (marketProv.errorMessage != null && marketProv.coins.isEmpty) {
      return SliverFillRemaining(
        child: ErrorView(
          message: marketProv.errorMessage,
          onRetry: () => marketProv.refresh(),
        ),
      );
    }

    final coins = marketProv.displayedCoins;

    if (coins.isEmpty) {
      return SliverFillRemaining(
        child: EmptyStateView(
          title: 'No Cryptocurrencies Found',
          description: 'Try adjusting your filters or search terms.',
          icon: Icons.filter_alt_off_rounded,
          buttonText: 'Reset Filters',
          onButtonPressed: () {
            marketProv.setFilter(MarketFilter.all);
            marketProv.clearSearch();
          },
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == coins.length) {
              if (marketProv.isLoadingMore) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.primaryLight,
                      ),
                    ),
                  ),
                );
              }
              return const SizedBox(height: 24);
            }

            final coin = coins[index];
            final isWatched = watchlistProv.isWatched(coin.id);

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: CoinListItem(
                coin: coin,
                currencySymbol: settings.currencySymbol,
                isWatchlisted: isWatched,
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
                onWatchlistToggle: () => watchlistProv.toggleWatchlist(coin),
              ),
            );
          },
          childCount: coins.length + (marketProv.hasMore ? 1 : 0),
        ),
      ),
    );
  }
}
