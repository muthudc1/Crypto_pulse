import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/search_result.dart';
import '../repositories/crypto_repository.dart';
import '../services/api_exception.dart';

class SearchProvider extends ChangeNotifier {
  final CryptoRepository _repository;

  SearchProvider(this._repository);

  Timer? _debounceTimer;
  String _query = '';
  List<SearchCoinItem> _results = [];
  bool _isSearching = false;
  String? _errorMessage;

  String get query => _query;
  List<SearchCoinItem> get results => _results;
  bool get isSearching => _isSearching;
  String? get errorMessage => _errorMessage;

  void onQueryChanged(String newQuery) {
    _query = newQuery;
    _debounceTimer?.cancel();

    if (newQuery.trim().isEmpty) {
      _results = [];
      _isSearching = false;
      _errorMessage = null;
      notifyListeners();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performSearch(newQuery.trim());
    });
  }

  Future<void> _performSearch(String queryText) async {
    if (queryText.isEmpty) return;

    _isSearching = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final res = await _repository.searchCoins(queryText);
      // Sort by rank if available
      final list = List<SearchCoinItem>.from(res.coins);
      list.sort((a, b) {
        if (a.marketCapRank == null) return 1;
        if (b.marketCapRank == null) return -1;
        return a.marketCapRank!.compareTo(b.marketCapRank!);
      });
      _results = list;
      _errorMessage = null;
    } on ApiException catch (e) {
      _errorMessage = e.message;
    } catch (e) {
      _errorMessage = 'Search error: $e';
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void clear() {
    _query = '';
    _results = [];
    _isSearching = false;
    _errorMessage = null;
    _debounceTimer?.cancel();
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
