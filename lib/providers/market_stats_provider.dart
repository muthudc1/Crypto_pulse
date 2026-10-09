import 'package:flutter/foundation.dart';
import '../models/global_market_data.dart';
import '../models/coin_market.dart';
import '../repositories/crypto_repository.dart';
import '../services/api_exception.dart';

class MarketStatsProvider extends ChangeNotifier {
  final CryptoRepository _repository;

  MarketStatsProvider(this._repository);

  GlobalMarketData? _globalData;
  List<CoinMarket> _topCoins = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentCurrency = 'usd';

  GlobalMarketData? get globalData => _globalData;
  List<CoinMarket> get topCoins => _topCoins;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CoinMarket> get topGainers {
    final list = List<CoinMarket>.from(_topCoins)
      ..sort((a, b) => b.priceChangePercentage24h.compareTo(a.priceChangePercentage24h));
    return list.where((c) => c.priceChangePercentage24h > 0).take(6).toList();
  }

  List<CoinMarket> get topLosers {
    final list = List<CoinMarket>.from(_topCoins)
      ..sort((a, b) => a.priceChangePercentage24h.compareTo(b.priceChangePercentage24h));
    return list.where((c) => c.priceChangePercentage24h < 0).take(6).toList();
  }

  List<CoinMarket> get highestVolume {
    final list = List<CoinMarket>.from(_topCoins)
      ..sort((a, b) => b.totalVolume.compareTo(a.totalVolume));
    return list.take(6).toList();
  }

  List<CoinMarket> get topByMarketCap {
    final list = List<CoinMarket>.from(_topCoins)
      ..sort((a, b) => b.marketCap.compareTo(a.marketCap));
    return list.take(10).toList();
  }

  Future<void> fetchStats({
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) async {
    _currentCurrency = vsCurrency;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _repository.getGlobalMarketData(forceRefresh: forceRefresh),
        _repository.getMarkets(
          vsCurrency: _currentCurrency,
          perPage: 100,
          page: 1,
          forceRefresh: forceRefresh,
        ),
      ]);

      _globalData = results[0] as GlobalMarketData;
      _topCoins = results[1] as List<CoinMarket>;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Failed to load market statistics: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await fetchStats(vsCurrency: _currentCurrency, forceRefresh: true);
  }
}
