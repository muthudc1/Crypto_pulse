import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/theme.dart';
import '../providers/market_provider.dart';
import '../providers/market_stats_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/watchlist_provider.dart';
import '../services/cache_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isPro = false;

  final List<Map<String, String>> _currencies = [
    {'code': 'usd', 'name': 'US Dollar', 'symbol': '\$'},
    {'code': 'eur', 'name': 'Euro', 'symbol': '€'},
    {'code': 'gbp', 'name': 'British Pound', 'symbol': '£'},
    {'code': 'jpy', 'name': 'Japanese Yen', 'symbol': '¥'},
    {'code': 'aud', 'name': 'Australian Dollar', 'symbol': 'A\$'},
    {'code': 'cad', 'name': 'Canadian Dollar', 'symbol': 'C\$'},
    {'code': 'inr', 'name': 'Indian Rupee', 'symbol': '₹'},
  ];

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _apiKeyController.text = settings.apiKey ?? '';
    _isPro = settings.isProKey;
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings '),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // Currency Section
          _buildSectionHeader('DISPLAY CURRENCY'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: Column(
              children: _currencies.map((curr) {
                final isSelected = settings.currency == curr['code'];
                return RadioListTile<String>(
                  value: curr['code']!,
                  groupValue: settings.currency,
                  activeColor: AppTheme.primaryLight,
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${curr['name']} (${curr['code']!.toUpperCase()})',
                          style: TextStyle(
                            color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 14,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        curr['symbol']!,
                        style: const TextStyle(
                          color: AppTheme.textMuted,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  onChanged: (val) {
                    if (val != null) {
                      settings.setCurrency(val);
                      // Trigger data reload in current currency
                      context.read<MarketProvider>().fetchMarkets(vsCurrency: val, forceRefresh: true);
                      context.read<MarketStatsProvider>().fetchStats(vsCurrency: val, forceRefresh: true);
                      context.read<WatchlistProvider>().fetchWatchlistCoins(vsCurrency: val, forceRefresh: true);
                    }
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 24),



          // Cache Management
          _buildSectionHeader('STORAGE & CACHE'),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.darkBorder),
            ),
            child: ListTile(
              leading: const Icon(Icons.cleaning_services_rounded, color: AppTheme.primaryLight),
              title: const Text('Purge In-Memory Cache', style: TextStyle(color: AppTheme.textPrimary, fontSize: 14)),
              subtitle: const Text('Clears cached market and chart data immediately', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.textMuted),
              onTap: () {
                CacheManager().clear();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Market Cache Purged'),
                    backgroundColor: AppTheme.darkSurfaceVariant,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // App Info
          Center(
            child: Column(
              children: [
                Text(
                  'CryptoPulse v1.0.0',
                  style: TextStyle(color: AppTheme.textMuted.withOpacity(0.8), fontSize: 12),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Real-time Financial Market Research',
                  style: TextStyle(color: AppTheme.textMuted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}
