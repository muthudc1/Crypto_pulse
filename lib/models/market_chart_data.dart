class ChartPoint {
  final DateTime timestamp;
  final double price;

  ChartPoint({
    required this.timestamp,
    required this.price,
  });
}

class MarketChartData {
  final List<ChartPoint> prices;
  final List<ChartPoint> marketCaps;
  final List<ChartPoint> totalVolumes;
  final double minPrice;
  final double maxPrice;
  final double startPrice;
  final double endPrice;
  final double priceChange;
  final double priceChangePercent;

  MarketChartData({
    required this.prices,
    required this.marketCaps,
    required this.totalVolumes,
    required this.minPrice,
    required this.maxPrice,
    required this.startPrice,
    required this.endPrice,
    required this.priceChange,
    required this.priceChangePercent,
  });

  factory MarketChartData.fromJson(Map<String, dynamic> json) {
    final rawPrices = json['prices'] as List<dynamic>? ?? [];
    final rawMarketCaps = json['market_caps'] as List<dynamic>? ?? [];
    final rawVolumes = json['total_volumes'] as List<dynamic>? ?? [];

    List<ChartPoint> parsePoints(List<dynamic> raw) {
      final List<ChartPoint> list = [];
      for (final item in raw) {
        if (item is List && item.length >= 2) {
          final timeMs = (item[0] as num).toInt();
          final val = (item[1] as num).toDouble();
          list.add(
            ChartPoint(
              timestamp: DateTime.fromMillisecondsSinceEpoch(timeMs),
              price: val,
            ),
          );
        }
      }
      return list;
    }

    final pricePoints = parsePoints(rawPrices);
    final marketCapPoints = parsePoints(rawMarketCaps);
    final volumePoints = parsePoints(rawVolumes);

    double min = double.infinity;
    double max = double.negativeInfinity;
    for (final p in pricePoints) {
      if (p.price < min) min = p.price;
      if (p.price > max) max = p.price;
    }

    if (min == double.infinity) min = 0;
    if (max == double.negativeInfinity) max = 0;

    final start = pricePoints.isNotEmpty ? pricePoints.first.price : 0.0;
    final end = pricePoints.isNotEmpty ? pricePoints.last.price : 0.0;
    final change = end - start;
    final changePercent = start != 0 ? ((end - start) / start) * 100 : 0.0;

    return MarketChartData(
      prices: pricePoints,
      marketCaps: marketCapPoints,
      totalVolumes: volumePoints,
      minPrice: min,
      maxPrice: max,
      startPrice: start,
      endPrice: end,
      priceChange: change,
      priceChangePercent: changePercent,
    );
  }

  bool get isGain => priceChange >= 0;
}
