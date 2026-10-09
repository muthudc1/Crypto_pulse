import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/settings_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/common/empty_state_view.dart';
import '../widgets/common/error_view.dart';
import '../widgets/common/skeleton_loaders.dart';
import '../widgets/market/coin_list_item.dart';
import '../widgets/search/search_modal.dart';
import 'coin_detail_screen.dart';

class WatchlistScreen extends StatefulWidget {
  final VoidCallback? onExploreTap;

  const WatchlistScreen({
    super.key,
    this.onExploreTap,
  });

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currency = context.read<SettingsProvider>().currency;
      context.read<WatchlistProvider>().fetchWatchlistCoins(vsCurrency: currency);
    });
  }

  @override
  Widget build(BuildContext context) {
    final watchlistProv = context.watch<WatchlistProvider>();
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Watchlist'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded, size: 22),
            onPressed: () => SearchModal.show(context),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => watchlistProv.refresh(),
        color: AppTheme.primaryLight,
        backgroundColor: AppTheme.darkSurface,
        child: Builder(
          builder: (context) {
            if (watchlistProv.isEmpty) {
              return EmptyStateView(
                title: 'Your Watchlist is Empty',
                description: 'Star coins from the market list or search to track your favorite cryptocurrencies in real-time.',
                icon: Icons.star_outline_rounded,
                buttonText: 'Explore Cryptocurrencies',
                onButtonPressed: widget.onExploreTap ?? () => SearchModal.show(context),
              );
            }

            if (watchlistProv.isLoading && watchlistProv.watchlistCoins.isEmpty) {
              return SkeletonLoaders.coinListSkeleton(itemCount: 6);
            }

            if (watchlistProv.errorMessage != null && watchlistProv.watchlistCoins.isEmpty) {
              return ErrorView(
                message: watchlistProv.errorMessage,
                onRetry: () => watchlistProv.refresh(),
              );
            }

            final coins = watchlistProv.watchlistCoins;

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: coins.length,
              itemBuilder: (context, index) {
                final coin = coins[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: Key(coin.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      decoration: BoxDecoration(
                        color: AppTheme.lossRed.withOpacity(0.8),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      watchlistProv.removeFromWatchlist(coin.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${coin.name} removed from watchlist'),
                          duration: const Duration(seconds: 2),
                          backgroundColor: AppTheme.darkSurfaceVariant,
                        ),
                      );
                    },
                    child: CoinListItem(
                      coin: coin,
                      currencySymbol: settings.currencySymbol,
                      isWatchlisted: true,
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
                      onWatchlistToggle: () => watchlistProv.removeFromWatchlist(coin.id),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
