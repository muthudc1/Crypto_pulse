import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/theme.dart';
import '../../models/search_result.dart';
import '../../providers/search_provider.dart';
import '../../screens/coin_detail_screen.dart';
import '../common/empty_state_view.dart';

class SearchModal extends StatefulWidget {
  const SearchModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.darkBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SearchModal(),
    );
  }

  @override
  State<SearchModal> createState() => _SearchModalState();
}

class _SearchModalState extends State<SearchModal> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Auto focus search field
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchProv = context.watch<SearchProvider>();

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
          // Drag handle
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.darkBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Search input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: AppTheme.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.darkBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search_rounded, color: AppTheme.textMuted, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            focusNode: _focusNode,
                            style: const TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 14,
                            ),
                            decoration: const InputDecoration(
                              hintText: 'Search Bitcoin, ETH, SOL...',
                              hintStyle: TextStyle(
                                color: AppTheme.textMuted,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            onChanged: (val) => searchProv.onQueryChanged(val),
                          ),
                        ),
                        if (_controller.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18, color: AppTheme.textSecondary),
                            onPressed: () {
                              _controller.clear();
                              searchProv.clear();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    searchProv.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),

          // Results / States
          Expanded(
            child: Builder(
              builder: (context) {
                if (searchProv.isSearching) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryLight,
                    ),
                  );
                }

                if (searchProv.errorMessage != null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        searchProv.errorMessage!,
                        style: const TextStyle(color: AppTheme.lossRed),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                if (_controller.text.trim().isEmpty) {
                  return const EmptyStateView(
                    title: 'Search Cryptocurrencies',
                    description: 'Type coin name or symbol (e.g. Bitcoin, BTC, Ethereum, Solana)',
                    icon: Icons.manage_search_rounded,
                  );
                }

                if (searchProv.results.isEmpty) {
                  return EmptyStateView(
                    title: 'No results found',
                    description: 'No cryptocurrency matches "${_controller.text}"',
                    icon: Icons.search_off_rounded,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: searchProv.results.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: AppTheme.darkBorder),
                  itemBuilder: (context, index) {
                    final coin = searchProv.results[index];
                    return _buildCoinResultTile(context, coin);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinResultTile(BuildContext context, SearchCoinItem coin) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: coin.thumb != null && coin.thumb!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coin.thumb!,
                width: 32,
                height: 32,
                placeholder: (context, url) => Container(
                  width: 32,
                  height: 32,
                  color: AppTheme.darkSurfaceVariant,
                ),
                errorWidget: (context, url, error) => _buildFallbackAvatar(coin),
              )
            : _buildFallbackAvatar(coin),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              coin.name,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (coin.marketCapRank != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '#${coin.marketCapRank}',
                style: const TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        coin.symbol,
        style: const TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted, size: 20),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CoinDetailScreen(
              coinId: coin.id,
              initialName: coin.name,
              initialSymbol: coin.symbol,
              initialImage: coin.large ?? coin.thumb,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFallbackAvatar(SearchCoinItem coin) {
    return Container(
      width: 32,
      height: 32,
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
    );
  }
}
