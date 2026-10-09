# CryptoPulse - CoinGecko Cryptocurrency Research App

A modern, production-grade Flutter cryptocurrency research and market tracking application powered by the official **CoinGecko REST API (v3)**.

---

## 📱 App Highlights & Features

### 1. Market Dashboard (`MarketScreen`)
- **Real-Time Market Data**: Top cryptocurrencies by market cap with logo, ticker, price, 24h % change, market cap, and 7-day sparkline charts.
- **Global Overview Banner**: Real-time Global Crypto Market Cap, 24-Hour Trading Volume, Bitcoin (BTC) & Ethereum (ETH) dominance progress indicators.
- **Interactive Search Modal**: Instant debounced search querying the CoinGecko `/search` API for coins, symbols, and rankings.
- **Filter & Multi-Criteria Sort**:
  - **Filters**: All Coins, 🚀 Top Gainers (24h > 0), 📉 Top Losers (24h < 0), ⭐ Top 10 MCap, 🏆 Top 50 MCap.
  - **Sorting**: Market Cap (High to Low / Low to High), Price (High to Low / Low to High), 24h % Change (Highest / Lowest), 24h Volume, Alphabetical (A-Z).
- **Infinite Pagination & Pull-to-Refresh**: Seamless infinite scrolling with duplicate-preventing pagination.

### 2. Coin Details & Research (`CoinDetailScreen`)
- **Interactive Historical Price Charts**: Powered by `fl_chart` with gradient area fills, dynamic bullish green / bearish red coloring, and interactive scrubbing tooltip for precise price and date inspection.
- **Dynamic Time-Range Selectors**: `1D` (24H), `7D`, `30D`, `90D`, and `1Y` (365 days).
- **Comprehensive Fundamentals Grid**:
  - Market Cap Rank & Total Market Capitalization
  - 24h Trading Volume & 24h High / Low
  - Circulating Supply, Total Supply, and Maximum Supply
  - All-Time High (ATH) + ATH % drop + Date
  - All-Time Low (ATL) + ATL % gain + Date
- **Expandable Asset Overview**: Clean HTML-stripped coin biography with Read More / Read Less toggles.
- **Persistent Watchlist Star**: One-tap instant addition/removal from watchlist.

### 3. Market Research & Statistics (`MarketStatisticsScreen`)
- **Global Macro Metrics**: Total Crypto Market Capitalization, 24h Total Trading Volume, Active Cryptocurrencies count, and Active Markets count.
- **Market Dominance Breakdown**: Visual progress indicators for Bitcoin (BTC), Ethereum (ETH), and Tether (USDT).
- **Top 24h Gainers & Losers**: Dynamically computed and ranked top performers.
- **Highest Turnover**: Most actively traded cryptocurrencies by 24-hour volume.

### 4. Persistent Watchlist (`WatchlistScreen`)
- **Local Storage Persistence**: Saved coin IDs are stored across app restarts using `SharedPreferences`.
- **Live Price Refreshing**: Fetches live quotes for user-selected assets via CoinGecko `/coins/markets?ids=...`.
- **Swipe-to-Delete**: Dismissible swipe-to-remove gesture with snackbar feedback.
- **Empty State**: Intuitive empty state with quick navigation to explore top cryptocurrencies.

### 5. Settings & API Configuration (`SettingsScreen`)
- **Multi-Currency Support**: Switch between **USD ($)**, **EUR (€)**, **GBP (£)**, **JPY (¥)**, **AUD (A$)**, **CAD (C$)**, and **INR (₹)**.
- **Custom Demo / Pro API Key Configuration**: Allows configuring CoinGecko API keys (e.g. `x-cg-demo-api-key` or `x-cg-pro-api-key`) with rate-limit boosts.
- **Cache Management**: Instant in-memory cache purge action.

---

## 🏗️ Clean Architecture Structure

```
lib/
├── config/
│   ├── api_config.dart            # Base URLs, endpoints, timeouts, and cache TTL constants
│   └── theme.dart                 # Dark theme palette, financial colors, gradients, typography
├── models/
│   ├── coin_market.dart           # CoinGecko /coins/markets model (sparkline, rank, 24h & 7d changes)
│   ├── coin_detail.dart           # CoinGecko /coins/{id} model (fundamentals, ATH/ATL, description)
│   ├── market_chart_data.dart     # CoinGecko /coins/{id}/market_chart historical price data points
│   ├── global_market_data.dart    # CoinGecko /global model (market cap, volume, dominance)
│   └── search_result.dart         # CoinGecko /search model (coins, symbols, rank)
├── services/
│   ├── api_exception.dart         # Typed exceptions (RateLimitException 429, NetworkException, etc.)
│   ├── cache_manager.dart         # Time-to-Live (TTL) in-memory cache manager
│   └── coingecko_api_service.dart # Dio HTTP client with interceptors, caching, and rate-limit handling
├── repositories/
│   ├── crypto_repository.dart     # Domain data access interface
│   ├── watchlist_repository.dart  # SharedPreferences watchlist persistence
│   └── settings_repository.dart   # SharedPreferences currency and API preferences
├── providers/
│   ├── market_provider.dart       # Market list state, filtering, sorting, pagination
│   ├── coin_detail_provider.dart  # Coin details, historical charts, touch inspection state
│   ├── market_stats_provider.dart # Global metrics, dominance, top movers calculation
│   ├── watchlist_provider.dart    # Saved coins state and live price synchronizer
│   ├── search_provider.dart       # Debounced coin search provider
│   └── settings_provider.dart     # Currency, theme, and API key provider
├── widgets/
│   ├── common/                    # StatBadge, ErrorView, EmptyStateView, SkeletonLoaders
│   ├── market/                    # CoinListItem, MiniSparklineChart, MarketSummaryCarousel, FilterSortBottomSheet
│   ├── details/                   # InteractivePriceChart, CoinStatsGrid, ExpandableDescription
│   └── search/                    # SearchModal bottom sheet
├── screens/
│   ├── main_navigation_screen.dart# IndexedStack Bottom Navigation
│   ├── market_screen.dart         # Home market list
│   ├── coin_detail_screen.dart    # Deep coin research screen
│   ├── market_statistics_screen.dart # Research & global stats
│   ├── watchlist_screen.dart      # Watchlist screen
│   └── settings_screen.dart       # Preferences & API key config
├── utils/
│   └── formatters.dart            # Dynamic currency, compact numbers, percentage, date formatters
└── main.dart                      # MultiProvider bootstrap & MaterialApp
```

---

## 🌐 CoinGecko API Endpoints Implemented

| Endpoint | Method | Purpose |
| :--- | :--- | :--- |
| `/coins/markets` | `GET` | Fetches top cryptocurrency market data, prices, sparklines, and 24h/7d changes. |
| `/coins/{id}` | `GET` | Fetches detailed asset fundamentals, supply metrics, ATH/ATL, and description. |
| `/coins/{id}/market_chart` | `GET` | Fetches historical price and volume points for 1D, 7D, 30D, 90D, and 1Y charts. |
| `/global` | `GET` | Fetches global crypto market cap, 24h trading volume, and BTC/ETH/USDT dominance. |
| `/search` | `GET` | Real-time debounced search by name or symbol. |

---

## 🚀 Setup & Run Instructions

### 1. Prerequisites
- Flutter SDK `3.x` or higher
- Dart SDK `3.x` or higher

### 2. Install Dependencies
```bash
flutter pub get
```

### 3. Run Tests
```bash
flutter test
```

### 4. Run the Application
```bash
# Run on connected device or emulator
flutter run

# Optional: Run with pre-configured CoinGecko Demo or Pro API Key from environment
flutter run --dart-define=COINGECKO_API_KEY=your_api_key_here
```

---

## 🧪 Testing & Validation Checklist

- [x] **Real Market Data**: Fetches and renders live market data from CoinGecko API.
- [x] **Coin Details & Historical Charts**: Switches time ranges (1D, 7D, 30D, 90D, 1Y) and renders dynamic Bézier price charts with scrubbing tooltips.
- [x] **Debounced Search**: Queries `/search` with debouncing, preventing unnecessary network spam.
- [x] **Filter & Sort**: Filters top gainers/losers and sorts by market cap, price, % change, volume, and name.
- [x] **Watchlist Persistence**: Coins added to watchlist persist in `SharedPreferences` across restarts.
- [x] **Multi-Currency**: Supports USD, EUR, GBP, JPY, AUD, CAD, and INR with automatic formatting.
- [x] **Rate Limit & Error Handling**: Gracefully catches HTTP 429 rate limits, network timeouts, and server errors with retry buttons and cached fallbacks.
