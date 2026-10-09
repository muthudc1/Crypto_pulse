import 'dart:async';
import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/coin_market.dart';
import '../models/coin_detail.dart';
import '../models/market_chart_data.dart';
import '../models/global_market_data.dart';
import '../models/search_result.dart';
import 'api_exception.dart';
import 'cache_manager.dart';

class CoinGeckoApiService {
  final Dio _dio;
  final CacheManager _cache;
  String? _customApiKey;
  bool _isProKey;

  CoinGeckoApiService({
    Dio? dio,
    CacheManager? cache,
    String? apiKey,
    bool isPro = false,
  })  : _dio = dio ?? Dio(),
        _cache = cache ?? CacheManager(),
        _customApiKey = apiKey,
        _isProKey = isPro {
    _initDio();
  }

  void _initDio() {
    // Read from environment if available
    const envKey = String.fromEnvironment(ApiConfig.apiKeyEnvName, defaultValue: '');
    if (envKey.isNotEmpty && _customApiKey == null) {
      _customApiKey = envKey;
    }

    _dio.options = BaseOptions(
      baseUrl: _isProKey ? ApiConfig.proBaseUrl : ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Accept': 'application/json',
      },
    );

    _dio.interceptors.clear();
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_customApiKey != null && _customApiKey!.isNotEmpty) {
            final headerName =
                _isProKey ? ApiConfig.proApiKeyHeader : ApiConfig.demoApiKeyHeader;
            options.headers[headerName] = _customApiKey;
          }
          return handler.next(options);
        },
      ),
    );
  }

  void updateApiKey(String? apiKey, {bool isPro = false}) {
    _customApiKey = apiKey;
    _isProKey = isPro;
    _initDio();
    _cache.clear();
  }

  /// Handles and converts DioExceptions to domain-specific ApiExceptions
  ApiException _handleDioError(dynamic error) {
    if (error is ApiException) return error;

    if (error is DioException) {
      if (error.response?.statusCode == 429) {
        return RateLimitException();
      }
      if (error.response?.statusCode == 404) {
        return NotFoundException();
      }
      if (error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.connectionError) {
        return NetworkException();
      }
      if ((error.response?.statusCode ?? 0) >= 500) {
        return ServerException(
          message: 'Market server error: ${error.response?.statusCode}',
          statusCode: error.response?.statusCode,
        );
      }
      return ApiException(
        message: error.response?.data?['error'] ??
            error.message ??
            'An unexpected error occurred.',
        statusCode: error.response?.statusCode,
      );
    }
    return ApiException(message: error.toString());
  }

  /// A. Cryptocurrency Market List
  Future<List<CoinMarket>> getMarkets({
    String vsCurrency = 'usd',
    String order = 'market_cap_desc',
    int perPage = 100,
    int page = 1,
    bool sparkline = true,
    String priceChangePercentage = '24h,7d',
    bool forceRefresh = false,
  }) async {
    final cacheKey =
        'markets_${vsCurrency}_${order}_${perPage}_${page}_${sparkline}_$priceChangePercentage';

    if (!forceRefresh) {
      final cached = _cache.get<List<CoinMarket>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get(
        ApiConfig.marketsEndpoint,
        queryParameters: {
          'vs_currency': vsCurrency,
          'order': order,
          'per_page': perPage,
          'page': page,
          'sparkline': sparkline,
          'price_change_percentage': priceChangePercentage,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((item) => CoinMarket.fromJson(item as Map<String, dynamic>))
            .toList();
        _cache.set(cacheKey, list, ApiConfig.marketListCacheTtl);
        return list;
      }
      throw ApiException(message: 'Invalid market list response');
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  /// B. Coin Details
  Future<CoinDetail> getCoinDetail(
    String id, {
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'coin_detail_$id';

    if (!forceRefresh) {
      final cached = _cache.get<CoinDetail>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get(
        '${ApiConfig.coinDetailEndpoint}/$id',
        queryParameters: {
          'localization': false,
          'tickers': false,
          'market_data': true,
          'community_data': true,
          'developer_data': false,
          'sparkline': false,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final detail = CoinDetail.fromJson(response.data as Map<String, dynamic>);
        _cache.set(cacheKey, detail, ApiConfig.coinDetailCacheTtl);
        return detail;
      }
      throw ApiException(message: 'Invalid coin details response');
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  /// C. Historical Price Chart
  Future<MarketChartData> getMarketChart(
    String id, {
    String vsCurrency = 'usd',
    String days = '1',
    bool forceRefresh = false,
  }) async {
    final cacheKey = 'chart_${id}_${vsCurrency}_$days';

    if (!forceRefresh) {
      final cached = _cache.get<MarketChartData>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final endpoint = ApiConfig.marketChartEndpoint.replaceAll('{id}', id);
      final response = await _dio.get(
        endpoint,
        queryParameters: {
          'vs_currency': vsCurrency,
          'days': days,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final chartData = MarketChartData.fromJson(response.data as Map<String, dynamic>);
        _cache.set(cacheKey, chartData, ApiConfig.chartDataCacheTtl);
        return chartData;
      }
      throw ApiException(message: 'Invalid chart data response');
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  /// D. Global Market Statistics
  Future<GlobalMarketData> getGlobalMarketData({
    bool forceRefresh = false,
  }) async {
    const cacheKey = 'global_market_stats';

    if (!forceRefresh) {
      final cached = _cache.get<GlobalMarketData>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get(ApiConfig.globalEndpoint);

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final stats = GlobalMarketData.fromJson(response.data as Map<String, dynamic>);
        _cache.set(cacheKey, stats, ApiConfig.globalStatsCacheTtl);
        return stats;
      }
      throw ApiException(message: 'Invalid global market statistics response');
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  /// E. Search Coins
  Future<SearchResult> searchCoins(String query) async {
    final cleanQuery = query.trim().toLowerCase();
    if (cleanQuery.isEmpty) {
      return SearchResult(coins: []);
    }

    final cacheKey = 'search_$cleanQuery';
    final cached = _cache.get<SearchResult>(cacheKey);
    if (cached != null) return cached;

    try {
      final response = await _dio.get(
        ApiConfig.searchEndpoint,
        queryParameters: {
          'query': cleanQuery,
        },
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final result = SearchResult.fromJson(response.data as Map<String, dynamic>);
        _cache.set(cacheKey, result, ApiConfig.searchCacheTtl);
        return result;
      }
      throw ApiException(message: 'Invalid search response');
    } catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Fetch list of coins by specific IDs (used for Watchlist live price updates)
  Future<List<CoinMarket>> getCoinsByIds(
    List<String> ids, {
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) async {
    if (ids.isEmpty) return [];

    final idsString = ids.join(',');
    final cacheKey = 'coins_by_ids_${idsString}_$vsCurrency';

    if (!forceRefresh) {
      final cached = _cache.get<List<CoinMarket>>(cacheKey);
      if (cached != null) return cached;
    }

    try {
      final response = await _dio.get(
        ApiConfig.marketsEndpoint,
        queryParameters: {
          'vs_currency': vsCurrency,
          'ids': idsString,
          'order': 'market_cap_desc',
          'sparkline': true,
          'price_change_percentage': '24h,7d',
        },
      );

      if (response.statusCode == 200 && response.data is List) {
        final list = (response.data as List)
            .map((item) => CoinMarket.fromJson(item as Map<String, dynamic>))
            .toList();
        _cache.set(cacheKey, list, ApiConfig.marketListCacheTtl);
        return list;
      }
      throw ApiException(message: 'Invalid watchlist market data response');
    } catch (e) {
      throw _handleDioError(e);
    }
  }
}
