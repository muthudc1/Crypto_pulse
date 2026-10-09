import 'package:flutter/material.dart';
import '../repositories/settings_repository.dart';
import '../services/coingecko_api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository _repository;
  final CoinGeckoApiService _apiService;

  SettingsProvider(this._repository, this._apiService) {
    _loadSettings();
  }

  String _currency = 'usd';
  ThemeMode _themeMode = ThemeMode.dark;
  String? _apiKey;
  bool _isProKey = false;

  String get currency => _currency;
  String get currencySymbol => _repository.getCurrencySymbol();
  ThemeMode get themeMode => _themeMode;
  String? get apiKey => _apiKey;
  bool get isProKey => _isProKey;

  void _loadSettings() {
    _currency = _repository.getCurrency();
    _themeMode = _repository.getThemeMode();
    _apiKey = _repository.getApiKey();
    _isProKey = _repository.isProApiKey();

    if (_apiKey != null && _apiKey!.isNotEmpty) {
      _apiService.updateApiKey(_apiKey, isPro: _isProKey);
    }
  }

  Future<void> setCurrency(String newCurrency) async {
    if (_currency == newCurrency.toLowerCase()) return;
    _currency = newCurrency.toLowerCase();
    await _repository.setCurrency(_currency);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    await _repository.setThemeMode(mode);
    notifyListeners();
  }

  Future<void> updateApiKey(String? key, {bool isPro = false}) async {
    _apiKey = key;
    _isProKey = isPro;
    await _repository.setApiKey(key);
    await _repository.setIsProApiKey(isPro);
    _apiService.updateApiKey(key, isPro: isPro);
    notifyListeners();
  }
}
