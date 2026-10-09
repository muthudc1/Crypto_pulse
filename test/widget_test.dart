import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto_pulse/main.dart';
import 'package:crypto_pulse/models/coin_market.dart';
import 'package:crypto_pulse/models/coin_detail.dart';
import 'package:crypto_pulse/utils/formatters.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Formatter Tests', () {
    test('Currency formatting works correctly for high and low values', () {
      expect(Formatters.formatCurrency(67420.50), '\$67,420.50');
      expect(Formatters.formatCurrency(0.000452), '\$0.000452');
      expect(Formatters.formatCurrency(0), '\$0.00');
      expect(Formatters.formatCurrency(null), '\$--');
    });

    test('Compact currency formatting works correctly', () {
      expect(Formatters.formatCompactCurrency(1350000000000), '\$1.35 T');
      expect(Formatters.formatCompactCurrency(2450000000), '\$2.45 B');
      expect(Formatters.formatCompactCurrency(15000000), '\$15.00 M');
    });

    test('Percentage formatting works correctly with signs', () {
      expect(Formatters.formatPercentage(5.234), '+5.23%');
      expect(Formatters.formatPercentage(-3.141), '-3.14%');
      expect(Formatters.formatPercentage(0.0), '0.00%');
    });
  });

  group('Model Serialization Tests', () {
    test('CoinMarket parses from sample CoinGecko JSON', () {
      final sampleJson = {
        'id': 'bitcoin',
        'symbol': 'btc',
        'name': 'Bitcoin',
        'image': 'https://assets.coingecko.com/coins/images/1/large/bitcoin.png',
        'current_price': 65000.0,
        'market_cap': 1280000000000.0,
        'market_cap_rank': 1,
        'total_volume': 35000000000.0,
        'high_24h': 66000.0,
        'low_24h': 64000.0,
        'price_change_24h': 1000.0,
        'price_change_percentage_24h': 1.56,
        'circulating_supply': 19700000.0,
        'ath': 73750.0,
        'ath_change_percentage': -11.8,
        'atl': 67.81,
        'atl_change_percentage': 95800.0,
        'sparkline_in_7d': {
          'price': [64000.0, 64500.0, 65000.0]
        }
      };

      final coin = CoinMarket.fromJson(sampleJson);
      expect(coin.id, 'bitcoin');
      expect(coin.symbol, 'BTC');
      expect(coin.name, 'Bitcoin');
      expect(coin.currentPrice, 65000.0);
      expect(coin.marketCapRank, 1);
      expect(coin.sparklineIn7d.length, 3);
    });

    test('CoinDetail parses nested CoinGecko JSON', () {
      final sampleDetailJson = {
        'id': 'ethereum',
        'symbol': 'eth',
        'name': 'Ethereum',
        'description': {'en': 'Ethereum is a decentralized platform.'},
        'market_cap_rank': 2,
        'image': {'large': 'https://example.com/eth.png', 'small': 'https://example.com/eth_s.png'},
        'market_data': {
          'current_price': {'usd': 3500.0},
          'market_cap': {'usd': 420000000000.0},
          'total_volume': {'usd': 15000000000.0},
          'high_24h': {'usd': 3550.0},
          'low_24h': {'usd': 3400.0},
          'price_change_24h': 50.0,
          'price_change_percentage_24h': 1.45,
          'circulating_supply': 120000000.0,
          'ath': {'usd': 4878.26},
          'ath_change_percentage': {'usd': -28.2},
          'atl': {'usd': 0.43},
          'atl_change_percentage': {'usd': 812000.0},
        }
      };

      final detail = CoinDetail.fromJson(sampleDetailJson);
      expect(detail.id, 'ethereum');
      expect(detail.symbol, 'ETH');
      expect(detail.currentPrice, 3500.0);
      expect(detail.marketCapRank, 2);
    });
  });

  testWidgets('CryptoPulseApp loads without crashing', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({
      'user_crypto_watchlist_ids': ['bitcoin', 'ethereum'],
    });

    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(CryptoPulseApp(sharedPreferences: prefs));
    await tester.pumpAndSettle();

    expect(find.text('CryptoPulse'), findsOneWidget);
    expect(find.text('Markets'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
  });
}
