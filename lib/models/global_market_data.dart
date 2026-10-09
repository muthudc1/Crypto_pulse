class GlobalMarketData {
  final int activeCryptocurrencies;
  final int upcomingIcos;
  final int ongoingIcos;
  final int endedIcos;
  final int markets;
  final double totalMarketCapUsd;
  final double totalVolume24hUsd;
  final double marketCapChangePercentage24hUsd;
  final Map<String, double> marketCapPercentage;
  final DateTime? updatedAt;

  GlobalMarketData({
    required this.activeCryptocurrencies,
    required this.upcomingIcos,
    required this.ongoingIcos,
    required this.endedIcos,
    required this.markets,
    required this.totalMarketCapUsd,
    required this.totalVolume24hUsd,
    required this.marketCapChangePercentage24hUsd,
    required this.marketCapPercentage,
    this.updatedAt,
  });

  factory GlobalMarketData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final totalMarketCap = data['total_market_cap'] as Map<String, dynamic>? ?? {};
    final totalVolume = data['total_volume'] as Map<String, dynamic>? ?? {};
    final marketCapPercentageMap =
        data['market_cap_percentage'] as Map<String, dynamic>? ?? {};

    final Map<String, double> dominance = {};
    marketCapPercentageMap.forEach((key, value) {
      if (value is num) {
        dominance[key.toUpperCase()] = value.toDouble();
      }
    });

    return GlobalMarketData(
      activeCryptocurrencies: (data['active_cryptocurrencies'] as num?)?.toInt() ?? 0,
      upcomingIcos: (data['upcoming_icos'] as num?)?.toInt() ?? 0,
      ongoingIcos: (data['ongoing_icos'] as num?)?.toInt() ?? 0,
      endedIcos: (data['ended_icos'] as num?)?.toInt() ?? 0,
      markets: (data['markets'] as num?)?.toInt() ?? 0,
      totalMarketCapUsd: (totalMarketCap['usd'] as num?)?.toDouble() ?? 0.0,
      totalVolume24hUsd: (totalVolume['usd'] as num?)?.toDouble() ?? 0.0,
      marketCapChangePercentage24hUsd:
          (data['market_cap_change_percentage_24h_usd'] as num?)?.toDouble() ?? 0.0,
      marketCapPercentage: dominance,
      updatedAt: data['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch((data['updated_at'] as num).toInt() * 1000)
          : null,
    );
  }

  double get btcDominance => marketCapPercentage['BTC'] ?? 0.0;
  double get ethDominance => marketCapPercentage['ETH'] ?? 0.0;
  double get usdtDominance => marketCapPercentage['USDT'] ?? 0.0;
}
