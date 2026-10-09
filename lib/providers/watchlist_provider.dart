import 'package:flutter/foundation.dart';
import '../models/coin_market.dart';
import '../repositories/crypto_repository.dart';
import '../repositories/watchlist_repository.dart';
import '../services/api_exception.dart';

class WatchlistProvider extends ChangeNotifier {
  final WatchlistRepository _watchlistRepo;
  final CryptoRepository _cryptoRepo;

  WatchlistProvider(this._watchlistRepo, this._cryptoRepo) {
    _loadWatchlistIds();
  }

  List<String> _watchlistIds = [];
  List<CoinMarket> _watchlistCoins = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCurrency = 'usd';

  List<String> get watchlistIds => _watchlistIds;
  List<CoinMarket> get watchlistCoins => _watchlistCoins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _watchlistIds.isEmpty;

  void _loadWatchlistIds() {
    _watchlistIds = _watchlistRepo.getWatchlistCoinIds();
    notifyListeners();
  }

  bool isWatched(String coinId) {
    return _watchlistIds.contains(coinId.toLowerCase());
  }

  Future<void> toggleWatchlist(CoinMarket coin) async {
    final id = coin.id.toLowerCase();
    if (_watchlistIds.contains(id)) {
      await removeFromWatchlist(id);
    } else {
      await addToWatchlist(coin);
    }
  }

  Future<void> addToWatchlist(CoinMarket coin) async {
    final id = coin.id.toLowerCase();
    if (!_watchlistIds.contains(id)) {
      _watchlistIds.add(id);
      await _watchlistRepo.addToWatchlist(id);

      // Add to loaded list immediately for instant UI response
      if (!_watchlistCoins.any((c) => c.id.toLowerCase() == id)) {
        _watchlistCoins.add(coin);
      }
      notifyListeners();
    }
  }

  Future<void> removeFromWatchlist(String coinId) async {
    final id = coinId.toLowerCase();
    if (_watchlistIds.contains(id)) {
      _watchlistIds.remove(id);
      _watchlistCoins.removeWhere((c) => c.id.toLowerCase() == id);
      await _watchlistRepo.removeFromWatchlist(id);
      notifyListeners();
    }
  }

  Future<void> fetchWatchlistCoins({
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) async {
    _currentCurrency = vsCurrency;
    _watchlistIds = _watchlistRepo.getWatchlistCoinIds();

    if (_watchlistIds.isEmpty) {
      _watchlistCoins = [];
      _isLoading = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final coins = await _cryptoRepo.getCoinsByIds(
        _watchlistIds,
        vsCurrency: _currentCurrency,
        forceRefresh: forceRefresh,
      );

      // Preserve order of user watchlist or market cap
      _watchlistCoins = coins;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load watchlist quotes: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchWatchlistCoins(vsCurrency: _currentCurrency, forceRefresh: true);
  }
}
