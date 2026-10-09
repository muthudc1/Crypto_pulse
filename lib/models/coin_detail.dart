class CoinDetail {
  final String id;
  final String symbol;
  final String name;
  final String description;
  final String? imageLarge;
  final String? imageSmall;
  final int marketCapRank;
  final double currentPrice;
  final double marketCap;
  final double totalVolume;
  final double high24h;
  final double low24h;
  final double priceChange24h;
  final double priceChangePercentage24h;
  final double priceChangePercentage7d;
  final double priceChangePercentage14d;
  final double priceChangePercentage30d;
  final double priceChangePercentage1y;
  final double circulatingSupply;
  final double? totalSupply;
  final double? maxSupply;
  final double ath;
  final double athChangePercentage;
  final String? athDate;
  final double atl;
  final double atlChangePercentage;
  final String? atlDate;
  final String? genesisDate;
  final String? homepage;
  final String? blockchainSite;
  final int? sentimentVotesUpPercentage;
  final int? sentimentVotesDownPercentage;
  final int? watchlistPortfolioUsers;

  CoinDetail({
    required this.id,
    required this.symbol,
    required this.name,
    required this.description,
    this.imageLarge,
    this.imageSmall,
    required this.marketCapRank,
    required this.currentPrice,
    required this.marketCap,
    required this.totalVolume,
    required this.high24h,
    required this.low24h,
    required this.priceChange24h,
    required this.priceChangePercentage24h,
    required this.priceChangePercentage7d,
    required this.priceChangePercentage14d,
    required this.priceChangePercentage30d,
    required this.priceChangePercentage1y,
    required this.circulatingSupply,
    this.totalSupply,
    this.maxSupply,
    required this.ath,
    required this.athChangePercentage,
    this.athDate,
    required this.atl,
    required this.atlChangePercentage,
    this.atlDate,
    this.genesisDate,
    this.homepage,
    this.blockchainSite,
    this.sentimentVotesUpPercentage,
    this.sentimentVotesDownPercentage,
    this.watchlistPortfolioUsers,
  });

  factory CoinDetail.fromJson(Map<String, dynamic> json) {
    final marketData = json['market_data'] as Map<String, dynamic>? ?? {};
    final currentPriceMap = marketData['current_price'] as Map<String, dynamic>? ?? {};
    final marketCapMap = marketData['market_cap'] as Map<String, dynamic>? ?? {};
    final totalVolumeMap = marketData['total_volume'] as Map<String, dynamic>? ?? {};
    final high24hMap = marketData['high_24h'] as Map<String, dynamic>? ?? {};
    final low24hMap = marketData['low_24h'] as Map<String, dynamic>? ?? {};
    final athMap = marketData['ath'] as Map<String, dynamic>? ?? {};
    final athChangeMap = marketData['ath_change_percentage'] as Map<String, dynamic>? ?? {};
    final athDateMap = marketData['ath_date'] as Map<String, dynamic>? ?? {};
    final atlMap = marketData['atl'] as Map<String, dynamic>? ?? {};
    final atlChangeMap = marketData['atl_change_percentage'] as Map<String, dynamic>? ?? {};
    final atlDateMap = marketData['atl_date'] as Map<String, dynamic>? ?? {};

    final descriptionMap = json['description'] as Map<String, dynamic>? ?? {};
    final imageMap = json['image'] as Map<String, dynamic>? ?? {};
    final linksMap = json['links'] as Map<String, dynamic>? ?? {};

    String? homepageUrl;
    if (linksMap['homepage'] is List && (linksMap['homepage'] as List).isNotEmpty) {
      homepageUrl = linksMap['homepage'][0]?.toString();
    }

    String? explorerUrl;
    if (linksMap['blockchain_site'] is List && (linksMap['blockchain_site'] as List).isNotEmpty) {
      explorerUrl = (linksMap['blockchain_site'] as List).firstWhere(
        (element) => element != null && element.toString().isNotEmpty,
        orElse: () => null,
      )?.toString();
    }

    return CoinDetail(
      id: json['id'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      name: json['name'] ?? '',
      description: descriptionMap['en']?.toString() ?? '',
      imageLarge: imageMap['large']?.toString(),
      imageSmall: imageMap['small']?.toString(),
      marketCapRank: json['market_cap_rank'] != null
          ? (json['market_cap_rank'] as num).toInt()
          : (marketData['market_cap_rank'] != null
              ? (marketData['market_cap_rank'] as num).toInt()
              : 0),
      currentPrice: (currentPriceMap['usd'] as num?)?.toDouble() ?? 0.0,
      marketCap: (marketCapMap['usd'] as num?)?.toDouble() ?? 0.0,
      totalVolume: (totalVolumeMap['usd'] as num?)?.toDouble() ?? 0.0,
      high24h: (high24hMap['usd'] as num?)?.toDouble() ?? 0.0,
      low24h: (low24hMap['usd'] as num?)?.toDouble() ?? 0.0,
      priceChange24h: (marketData['price_change_24h_in_currency']?['usd'] as num?)?.toDouble() ??
          (marketData['price_change_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage24h: (marketData['price_change_percentage_24h_in_currency']?['usd'] as num?)?.toDouble() ??
          (marketData['price_change_percentage_24h'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage7d: (marketData['price_change_percentage_7d_in_currency']?['usd'] as num?)?.toDouble() ??
          (marketData['price_change_percentage_7d'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage14d: (marketData['price_change_percentage_14d_in_currency']?['usd'] as num?)?.toDouble() ??
          (marketData['price_change_percentage_14d'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage30d: (marketData['price_change_percentage_30d_in_currency']?['usd'] as num?)?.toDouble() ??
          (marketData['price_change_percentage_30d'] as num?)?.toDouble() ?? 0.0,
      priceChangePercentage1y: (marketData['price_change_percentage_1y_in_currency']?['usd'] as num?)?.toDouble() ??
          (marketData['price_change_percentage_1y'] as num?)?.toDouble() ?? 0.0,
      circulatingSupply: (marketData['circulating_supply'] as num?)?.toDouble() ?? 0.0,
      totalSupply: (marketData['total_supply'] as num?)?.toDouble(),
      maxSupply: (marketData['max_supply'] as num?)?.toDouble(),
      ath: (athMap['usd'] as num?)?.toDouble() ?? 0.0,
      athChangePercentage: (athChangeMap['usd'] as num?)?.toDouble() ?? 0.0,
      athDate: athDateMap['usd']?.toString(),
      atl: (atlMap['usd'] as num?)?.toDouble() ?? 0.0,
      atlChangePercentage: (atlChangeMap['usd'] as num?)?.toDouble() ?? 0.0,
      atlDate: atlDateMap['usd']?.toString(),
      genesisDate: json['genesis_date']?.toString(),
      homepage: homepageUrl,
      blockchainSite: explorerUrl,
      sentimentVotesUpPercentage: (json['sentiment_votes_up_percentage'] as num?)?.toInt(),
      sentimentVotesDownPercentage: (json['sentiment_votes_down_percentage'] as num?)?.toInt(),
      watchlistPortfolioUsers: (json['watchlist_portfolio_users'] as num?)?.toInt(),
    );
  }
}
