import 'package:flutter/foundation.dart';
import '../models/coin_detail.dart';
import '../models/market_chart_data.dart';
import '../repositories/crypto_repository.dart';
import '../services/api_exception.dart';

enum ChartTimeRange {
  day1('1', '24H'),
  day7('7', '7D'),
  day30('30', '30D'),
  day90('90', '90D'),
  year1('365', '1Y');

  final String days;
  final String label;
  const ChartTimeRange(this.days, this.label);
}

class CoinDetailProvider extends ChangeNotifier {
  final CryptoRepository _repository;

  CoinDetailProvider(this._repository);

  CoinDetail? _coinDetail;
  MarketChartData? _chartData;
  ChartTimeRange _selectedTimeRange = ChartTimeRange.day1;
  bool _isLoadingDetail = false;
  bool _isLoadingChart = false;
  String? _detailError;
  String? _chartError;
  String _currentCurrency = 'usd';

  // Interactive touch inspection state
  ChartPoint? _touchedPoint;

  CoinDetail? get coinDetail => _coinDetail;
  MarketChartData? get chartData => _chartData;
  ChartTimeRange get selectedTimeRange => _selectedTimeRange;
  bool get isLoadingDetail => _isLoadingDetail;
  bool get isLoadingChart => _isLoadingChart;
  bool get isLoading => _isLoadingDetail || _isLoadingChart;
  String? get detailError => _detailError;
  String? get chartError => _chartError;
  ChartPoint? get touchedPoint => _touchedPoint;

  Future<void> loadCoinData(
    String coinId, {
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) async {
    _currentCurrency = vsCurrency;
    _touchedPoint = null;
    
    // Fetch both detail and chart concurrently
    await Future.wait([
      fetchDetail(coinId, forceRefresh: forceRefresh),
      fetchChart(coinId, _selectedTimeRange, vsCurrency: vsCurrency, forceRefresh: forceRefresh),
    ]);
  }

  Future<void> fetchDetail(String coinId, {bool forceRefresh = false}) async {
    _isLoadingDetail = true;
    _detailError = null;
    notifyListeners();

    try {
      _coinDetail = await _repository.getCoinDetail(coinId, forceRefresh: forceRefresh);
      _detailError = null;
    } on ApiException catch (e) {
      _detailError = e.message;
    } catch (e) {
      _detailError = 'Failed to load coin details: $e';
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<void> fetchChart(
    String coinId,
    ChartTimeRange range, {
    String vsCurrency = 'usd',
    bool forceRefresh = false,
  }) async {
    _selectedTimeRange = range;
    _currentCurrency = vsCurrency;
    _isLoadingChart = true;
    _chartError = null;
    _touchedPoint = null;
    notifyListeners();

    try {
      _chartData = await _repository.getMarketChart(
        coinId,
        days: range.days,
        vsCurrency: _currentCurrency,
        forceRefresh: forceRefresh,
      );
      _chartError = null;
    } on ApiException catch (e) {
      _chartError = e.message;
    } catch (e) {
      _chartError = 'Failed to load chart data: $e';
    } finally {
      _isLoadingChart = false;
      notifyListeners();
    }
  }

  void setTouchedPoint(ChartPoint? point) {
    if (_touchedPoint != point) {
      _touchedPoint = point;
      notifyListeners();
    }
  }

  void clearTouchedPoint() {
    if (_touchedPoint != null) {
      _touchedPoint = null;
      notifyListeners();
    }
  }
}
