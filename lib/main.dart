import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'config/theme.dart';
import 'providers/coin_detail_provider.dart';
import 'providers/market_provider.dart';
import 'providers/market_stats_provider.dart';
import 'providers/search_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/watchlist_provider.dart';
import 'repositories/crypto_repository.dart';
import 'repositories/settings_repository.dart';
import 'repositories/watchlist_repository.dart';
import 'screens/main_navigation_screen.dart';
import 'services/cache_manager.dart';
import 'services/coingecko_api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set immersive dark status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.darkSurface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    CryptoPulseApp(sharedPreferences: sharedPreferences),
  );
}

class CryptoPulseApp extends StatelessWidget {
  final SharedPreferences sharedPreferences;

  const CryptoPulseApp({super.key, required this.sharedPreferences});

  @override
  Widget build(BuildContext context) {
    // 1. Services & Cache
    final cacheManager = CacheManager();
    final apiService = CoinGeckoApiService(cache: cacheManager);

    // 2. Repositories
    final cryptoRepo = CryptoRepository(apiService);
    final watchlistRepo = WatchlistRepository(sharedPreferences);
    final settingsRepo = SettingsRepository(sharedPreferences);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SettingsProvider(settingsRepo, apiService),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketProvider(cryptoRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => CoinDetailProvider(cryptoRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => MarketStatsProvider(cryptoRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => WatchlistProvider(watchlistRepo, cryptoRepo),
        ),
        ChangeNotifierProvider(
          create: (_) => SearchProvider(cryptoRepo),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'CryptoPulse - Crypto Market Research',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.darkTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.dark,
            home: const MainNavigationScreen(),
          );
        },
      ),
    );
  }
}
