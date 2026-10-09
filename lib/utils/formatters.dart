import 'package:intl/intl.dart';

class Formatters {
  Formatters._();

  static final NumberFormat _integerNumber = NumberFormat('#,###');

  /// Formats cryptocurrency price dynamically based on magnitude
  static String formatCurrency(num? value, {String symbol = '\$'}) {
    if (value == null) return '$symbol--';
    if (value == 0) return '$symbol' '0.00';

    final double absVal = value.abs().toDouble();

    if (absVal >= 1.0) {
      return '$symbol${NumberFormat('#,##0.00').format(value)}';
    } else if (absVal >= 0.01) {
      return '$symbol${NumberFormat('0.0000').format(value)}';
    } else if (absVal >= 0.00001) {
      return '$symbol${NumberFormat('0.000000').format(value)}';
    } else {
      return '$symbol${NumberFormat('0.00000000').format(value)}';
    }
  }

  /// Compact currency format like $1.45T, $23.4B, $500M
  static String formatCompactCurrency(num? value, {String symbol = '\$'}) {
    if (value == null) return '$symbol--';
    if (value == 0) return '$symbol' '0';

    final double absVal = value.abs().toDouble();
    if (absVal >= 1e12) {
      return '$symbol${(value / 1e12).toStringAsFixed(2)} T';
    } else if (absVal >= 1e9) {
      return '$symbol${(value / 1e9).toStringAsFixed(2)} B';
    } else if (absVal >= 1e6) {
      return '$symbol${(value / 1e6).toStringAsFixed(2)} M';
    } else if (absVal >= 1e3) {
      return '$symbol${(value / 1e3).toStringAsFixed(2)} K';
    }
    return formatCurrency(value, symbol: symbol);
  }

  /// Formats supply or coin quantity (e.g. 19.7M BTC)
  static String formatSupply(num? value, {String? symbol}) {
    if (value == null) return 'Unlimited / Unknown';
    final sym = symbol != null ? ' ${symbol.toUpperCase()}' : '';
    final double absVal = value.abs().toDouble();

    if (absVal >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(2)} T$sym';
    } else if (absVal >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(2)} B$sym';
    } else if (absVal >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(2)} M$sym';
    } else if (absVal >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(2)} K$sym';
    }
    return '${_integerNumber.format(value)}$sym';
  }

  /// Formats percentage change with sign, e.g. +4.25% or -1.18%
  static String formatPercentage(num? value, {bool includeSign = true}) {
    if (value == null) return '0.00%';
    final double val = value.toDouble();
    final String sign = (includeSign && val > 0) ? '+' : '';
    return '$sign${val.toStringAsFixed(2)}%';
  }

  /// Formats chart date based on timeframe
  static String formatChartDate(DateTime date, String timeframeDays) {
    if (timeframeDays == '1') {
      return DateFormat('HH:mm').format(date);
    } else if (timeframeDays == '7' || timeframeDays == '30') {
      return DateFormat('MMM dd, HH:mm').format(date);
    } else {
      return DateFormat('MMM dd, yyyy').format(date);
    }
  }

  /// Strips HTML tags and excessive whitespace from API descriptions
  static String cleanHtmlDescription(String? htmlText) {
    if (htmlText == null || htmlText.isEmpty) {
      return 'No description available for this asset.';
    }
    // Remove HTML tags
    final exp = RegExp(r'<[^>]*>|&[^;]+;');
    final cleaned = htmlText.replaceAll(exp, '').replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleaned.isEmpty ? 'No description available for this asset.' : cleaned;
  }
}
