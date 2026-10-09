import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const String _currencyKey = 'app_currency_key';
  static const String _themeModeKey = 'app_theme_mode_key';
  static const String _apiKeyKey = 'app_custom_api_key';
  static const String _isProKey = 'app_is_pro_api_key';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  String getCurrency() => _prefs.getString(_currencyKey) ?? 'usd';
  String getCurrencySymbol() {
    switch (getCurrency().toLowerCase()) {
      case 'eur':
        return '€';
      case 'gbp':
        return '£';
      case 'jpy':
        return '¥';
      case 'inr':
        return '₹';
      case 'aud':
        return 'A\$';
      case 'cad':
        return 'C\$';
      case 'usd':
      default:
        return '\$';
    }
  }

  Future<void> setCurrency(String currency) async {
    await _prefs.setString(_currencyKey, currency.toLowerCase());
  }

  ThemeMode getThemeMode() {
    final mode = _prefs.getString(_themeModeKey);
    if (mode == 'light') return ThemeMode.light;
    return ThemeMode.dark; // Default dark
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _prefs.setString(
      _themeModeKey,
      mode == ThemeMode.light ? 'light' : 'dark',
    );
  }

  String? getApiKey() => _prefs.getString(_apiKeyKey);

  Future<void> setApiKey(String? key) async {
    if (key == null || key.isEmpty) {
      await _prefs.remove(_apiKeyKey);
    } else {
      await _prefs.setString(_apiKeyKey, key.trim());
    }
  }

  bool isProApiKey() => _prefs.getBool(_isProKey) ?? false;

  Future<void> setIsProApiKey(bool isPro) async {
    await _prefs.setBool(_isProKey, isPro);
  }
}
