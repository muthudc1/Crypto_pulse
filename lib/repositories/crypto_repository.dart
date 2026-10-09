import '../models/coin_market.dart';
import '../models/coin_detail.dart';
import '../models/market_chart_data.dart';
import '../models/global_market_data.dart';
import '../models/search_result.dart';
import '../services/coingecko_api_service.dart';

class CryptoRepository {
  final CoinGeckoApiService _apiService;

  CryptoRepository(this._apiService);

  Future<List<CoinMarket>> getMarkets({
    String vsCurrency = 'usd',
    String order = 'market_cap_desc',
    int perPage = 100,
    int page = 1,
    bool sparkline = true,
    String priceChangePercentage = '24h,7d',
    bool forceRefresh = false,
  }) {
    return _apiService.getMarkets(
      vsCurrency: vsCurrency,
      order: order,
      perPage: perPage,
      page: page,
      sparkline: sparkline,
      priceChangePercentage: priceChangePercentage,
      forceRefresh: forceRefresh,
    );
  }

  Future<CoinDetail> getCoinDetail(String id, {bool forceRefresh = false}) {
    return _apiService.getCoinDetail(id, forceRefresh: forceRefresh);
  }

  Future<MarketChartData> getMarketChart(
    String id, {
    String vsCurrency = 'usd',
    String days = '1',
    bool forceRefresh = false,
  }) {
    return _apiService.getMarketChart(
      id,
      vsCurrency: vsCurrency,
      days: days,
      forceRefresh: forceRefresh,
    );
  }

  Future<GlobalMarketData> getGlobalMarketData({bool forceRefresh = false}) {
    return _apiService.getGlobalMarketData(forceRefresh: forceRefresh);
  }

  Future<SearchResult> searchCoins(String query) {
    return _apiService.searchCoins(query);
  }

  Future<List<CoinMarket>> getCoinsByIds(
    List<String> ids, {
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) {
    return _apiService.getCoinsByIds(
      ids,
      vsCurrency: vsCurrency,
      forceRefresh: forceRefresh,
    );
  }
}
