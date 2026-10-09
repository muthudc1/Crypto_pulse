class SearchCoinItem {
  final String id;
  final String name;
  final String symbol;
  final int? marketCapRank;
  final String? thumb;
  final String? large;

  SearchCoinItem({
    required this.id,
    required this.name,
    required this.symbol,
    this.marketCapRank,
    this.thumb,
    this.large,
  });

  factory SearchCoinItem.fromJson(Map<String, dynamic> json) {
    return SearchCoinItem(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      symbol: (json['symbol'] ?? '').toString().toUpperCase(),
      marketCapRank: (json['market_cap_rank'] as num?)?.toInt(),
      thumb: json['thumb']?.toString(),
      large: json['large']?.toString(),
    );
  }
}

class SearchResult {
  final List<SearchCoinItem> coins;

  SearchResult({required this.coins});

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    final coinsList = json['coins'] as List<dynamic>? ?? [];
    return SearchResult(
      coins: coinsList
          .map((c) => SearchCoinItem.fromJson(c as Map<String, dynamic>))
          .toList(),
    );
  }
}
