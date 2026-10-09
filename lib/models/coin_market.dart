class CoinMarket {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final int marketCapRank;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double? priceChangePercentage7dInCurrency;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double ath;
  final double athChangePercentage;
  final String? athDate;
  final double atl;
  final double atlChangePercentage;
  final String? atlDate;
  final List<double> sparklineIn7d;
  final DateTime? lastUpdated;

  CoinMarket({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.marketCapRank,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    this.priceChangePercentage7dInCurrency,
    required this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    this.atlDate,
    this.sparklineIn7d = const [],
    this.lastUpdated,
  });

  factory CoinMarket.fromJson(Map<String, dynamic> json) {
    List<double> sparkline = [];
    if (json['sparkline_in_7d'] != null &&
        json['sparkline_in_7d']['price'] != null) {
      final list = json['sparkline_in_7d']['price'] as List;
      sparkline = list.map((e) => (e as num).toDouble()).toList();
    }

    return CoinMarket(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      currentPrice: (json['current_price'] as num?)?.toDouble() ?? 0.0,
      marketCap: (json['market_cap'] as num?)?.toDouble() ?? 0.0,
      marketCapRank: json['market_cap_rank'] != null
          ? (json['market_cap_rank'] as num).toInt()
          : 0,
      totalVolume: (json['total_volume'] as num?)?.toDouble() ?? 0.0,
      high24h: (json['high_24h'] as num?)?.toDouble() ?? 0.0,
      low24h: (json['low_24h'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (json['price_change_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h:
          (json['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage7dInCurrency:
          (json['price_change_percentage_7d_in_currency'] as num?)?.toDouble(),
      circulatingSupply:
          (json['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      totalSupply: (json['total_supply'] as num?)?.toDouble(),
      maxSupply: (json['max_supply'] as num?)?.toDouble(),
      ath: (json['ath'] as num?)?.toDouble() ?? 0.0,
      athChangePercentage:
          (json['ath_change_percentage'] as num?)?.toDouble() ?? 0.0,
      athDate: json['ath_date']?.toString(),
      atl: (json['atl'] as num?)?.toDouble() ?? 0.0,
      atlChangePercentage:
          (json['atl_change_percentage'] as num?)?.toDouble() ?? 0.0,
      atlDate: json['atl_date']?.toString(),
      sparklineIn7d: sparkline,
      lastUpdated: json['last_updated'] != null
          ? DateTime.tryParse(json['last_updated'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'image': image,
      'current_price': currentPrice,
      'market_cap': marketCap,
      'market_cap_rank': marketCapRank,
      'total_volume': totalVolume,
      'high_24h': high24h,
      'low_24h': low24h,
      'price_change_24h': priceChange24h,
      'price_change_percentage_24h': priceChangePercentage24h,
      'price_change_percentage_7d_in_currency':
          priceChangePercentage7dInCurrency,
      'circulating_supply': circulatingSupply,
      'total_supply': totalSupply,
      'max_supply': maxSupply,
      'ath': ath,
      'ath_change_percentage': athChangePercentage,
      'ath_date': athDate,
      'atl': atl,
      'atl_change_percentage': atlChangePercentage,
      'atl_date': atlDate,
      'sparkline_in_7d': {'price': sparklineIn7d},
      'last_updated': lastUpdated?.toIso8601String(),
    };
  }
}
