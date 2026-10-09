class ApiConfig {
  ApiConfig._();

  /// Official CoinGecko Public / Demo API base URL
  static const String baseUrl = 'https://api.coingecko.com/api/v3';

  /// Optional Pro API Base URL if user configures a Pro key
  static const String proBaseUrl = 'https://pro-api.coingecko.com/api/v3';

  /// Endpoints
  static const String marketsEndpoint = '/coins/markets';
  static const String coinDetailEndpoint = '/coins';
  static const String marketChartEndpoint = '/coins/{id}/market_chart';
  static const String globalEndpoint = '/global';
  static const String searchEndpoint = '/search';
  static const String trendingEndpoint = '/search/trending';

  /// Request timeouts
  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  /// Default cache durations
  static const Duration marketListCacheTtl = Duration(seconds: 60);
  static const Duration coinDetailCacheTtl = Duration(minutes: 2);
  static const Duration chartDataCacheTtl = Duration(minutes: 2);
  static const Duration globalStatsCacheTtl = Duration(minutes: 3);
  static const Duration searchCacheTtl = Duration(minutes: 5);

  /// Environment variable key name for API Key
  static const String apiKeyEnvName = 'CG-aH9bnyrN9VafjYogb363jp8y';

  /// Header names
  static const String demoApiKeyHeader = 'x-cg-demo-api-key';
  static const String proApiKeyHeader = 'x-cg-pro-api-key';
}
