import 'package:flutter/foundation.dart';
import '../models/coin_market.dart';
import '../repositories/crypto_repository.dart';
import '../services/api_exception.dart';

enum MarketFilter {
  all,
  gainers,
  losers,
  top10,
  top50,
}

enum MarketSort {
  marketCapDesc('Market Cap (High to Low)'),
  marketCapAsc('Market Cap (Low to High)'),
  priceDesc('Price (High to Low)'),
  priceAsc('Price (Low to High)'),
  change24hDesc('24h % (Highest First)'),
  change24hAsc('24h % (Lowest First)'),
  volumeDesc('24h Volume (Highest First)'),
  nameAsc('Name (A to Z)');

  final String label;
  const MarketSort(this.label);
}

class MarketProvider extends ChangeNotifier {
  final CryptoRepository _repository;

  MarketProvider(this._repository);

  List<CoinMarket> _coins = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  bool _hasMore = true;
  String _currentCurrency = 'usd';

  // Filters & Sorting
  MarketFilter _selectedFilter = MarketFilter.all;
  MarketSort _selectedSort = MarketSort.marketCapDesc;
  String _searchQuery = '';

  List<CoinMarket> get coins => _coins;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  String? get errorMessage => _errorMessage;
  bool get hasMore => _hasMore;
  MarketFilter get selectedFilter => _selectedFilter;
  MarketSort get selectedSort => _selectedSort;
  String get searchQuery => _searchQuery;

  /// Returns filtered and sorted coins for the UI
  List<CoinMarket> get displayedCoins {
    List<CoinMarket> list = List.from(_coins);

    // 1. Apply Search Query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((c) {
        return c.name.toLowerCase().contains(q) ||
            c.symbol.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q);
      }).toList();
    }

    // 2. Apply Filters
    switch (_selectedFilter) {
      case MarketFilter.gainers:
        list = list.where((c) => c.priceChangePercentage24h > 0).toList();
        break;
      case MarketFilter.losers:
        list = list.where((c) => c.priceChangePercentage24h < 0).toList();
        break;
      case MarketFilter.top10:
        list = list.where((c) => c.marketCapRank > 0 && c.marketCapRank <= 10).toList();
        break;
      case MarketFilter.top50:
        list = list.where((c) => c.marketCapRank > 0 && c.marketCapRank <= 50).toList();
        break;
      case MarketFilter.all:
        break;
    }

    // 3. Apply Sorting
    switch (_selectedSort) {
      case MarketSort.marketCapDesc:
        list.sort((a, b) => b.marketCap.compareTo(a.marketCap));
        break;
      case MarketSort.marketCapAsc:
        list.sort((a, b) => a.marketCap.compareTo(b.marketCap));
        break;
      case MarketSort.priceDesc:
        list.sort((a, b) => b.currentPrice.compareTo(a.currentPrice));
        break;
      case MarketSort.priceAsc:
        list.sort((a, b) => a.currentPrice.compareTo(b.currentPrice));
        break;
      case MarketSort.change24hDesc:
        list.sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
        break;
      case MarketSort.change24hAsc:
        list.sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
        break;
      case MarketSort.volumeDesc:
        list.sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
        break;
      case MarketSort.nameAsc:
        list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
        break;
    }

    return list;
  }

  Future<void> fetchMarkets({
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) async {
    _currentCurrency = vsCurrency;
    _isLoading = true;
    _errorMessage = null;
    _currentPage = 1;
    notifyListeners();

    try {
      final fetched = await _repository.getMarkets(
        vsCurrency: _currentCurrency,
        page: 1,
        perPage: 100,
        forceRefresh: forceRefresh,
      );
      _coins = fetched;
      _hasMore = fetched.length >= 100;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load cryptocurrency market data: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchMarkets(vsCurrency: _currentCurrency, forceRefresh: true);
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore || _isLoading) return;

    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _currentPage + 1;
      final moreCoins = await _repository.getMarkets(
        vsCurrency: _currentCurrency,
        page: nextPage,
        perPage: 100,
      );

      if (moreCoins.isEmpty) {
        _hasMore = false;
      } else {
        _currentPage = nextPage;
        // Avoid duplicate items if any overlap
        final existingIds = _coins.map((c) => c.id).toSet();
        for (final coin in moreCoins) {
          if (!existingIds.contains(coin.id)) {
            _coins.add(coin);
            existingIds.add(coin.id);
          }
        }
        _hasMore = moreCoins.length >= 100;
      }
    } catch (_) {
      // Keep existing list on pagination error
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void setFilter(MarketFilter filter) {
    if (_selectedFilter != filter) {
      _selectedFilter = filter;
      notifyListeners();
    }
  }

  void setSort(MarketSort sort) {
    if (_selectedSort != sort) {
      _selectedSort = sort;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    notifyListeners();
  }
}
