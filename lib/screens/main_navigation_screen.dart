import 'package:flutter/material.dart';
import '../config/theme.dart';
import 'market_screen.dart';
import 'market_statistics_screen.dart';
import 'watchlist_screen.dart';
import 'settings_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      const MarketScreen(),
      const MarketStatisticsScreen(),
      WatchlistScreen(
        onExploreTap: () => _onTabTapped(0),
      ),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          border: Border(
            top: BorderSide(color: AppTheme.darkBorder.withOpacity(0.8), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          backgroundColor: AppTheme.darkSurface,
          selectedItemColor: AppTheme.primaryLight,
          unselectedItemColor: AppTheme.textMuted,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.candlestick_chart_rounded),
              activeIcon: Icon(Icons.candlestick_chart_rounded, color: AppTheme.primaryLight),
              label: 'Markets',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.pie_chart_outline_rounded),
              activeIcon: Icon(Icons.pie_chart_rounded, color: AppTheme.primaryLight),
              label: 'Research',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.star_outline_rounded),
              activeIcon: Icon(Icons.star_rounded, color: AppTheme.primaryLight),
              label: 'Watchlist',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_outlined),
              activeIcon: Icon(Icons.settings_rounded, color: AppTheme.primaryLight),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
