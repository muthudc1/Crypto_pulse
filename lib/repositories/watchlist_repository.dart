import 'package:shared_preferences/shared_preferences.dart';

class WatchlistRepository {
  static const String _watchlistKey = 'user_crypto_watchlist_ids';
  final SharedPreferences _prefs;

  WatchlistRepository(this._prefs);

  List<String> getWatchlistCoinIds() {
    return _prefs.getStringList(_watchlistKey) ?? [];
  }

  Future<bool> addToWatchlist(String coinId) async {
    final list = getWatchlistCoinIds();
    if (!list.contains(coinId)) {
      list.add(coinId);
      return await _prefs.setStringList(_watchlistKey, list);
    }
    return true;
  }

  Future<bool> removeFromWatchlist(String coinId) async {
    final list = getWatchlistCoinIds();
    if (list.contains(coinId)) {
      list.remove(coinId);
      return await _prefs.setStringList(_watchlistKey, list);
    }
    return true;
  }

  bool isCoinInWatchlist(String coinId) {
    final list = getWatchlistCoinIds();
    return list.contains(coinId);
  }

  Future<bool> toggleWatchlist(String coinId) async {
    if (isCoinInWatchlist(coinId)) {
      return await removeFromWatchlist(coinId);
    } else {
      return await addToWatchlist(coinId);
    }
  }

  Future<bool> clearWatchlist() async {
    return await _prefs.remove(_watchlistKey);
  }
}
