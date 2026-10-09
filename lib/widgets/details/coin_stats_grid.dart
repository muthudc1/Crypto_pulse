import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../models/coin_detail.dart';
import '../../utils/formatters.dart';

class CoinStatsGrid extends StatelessWidget {
  final CoinDetail detail;
  final String currencySymbol;

  const CoinStatsGrid({
    super.key,
    required this.detail,
    this.currencySymbol = '\$',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.darkCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.darkBorder, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Market Statistics',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildRow('Market Cap', Formatters.formatCurrency(detail.marketCap, symbol: currencySymbol)),
          _buildDivider(),
          _buildRow('24h Trading Volume', Formatters.formatCurrency(detail.totalVolume, symbol: currencySymbol)),
          _buildDivider(),
          _buildRow(
            '24h High / Low',
            '${Formatters.formatCurrency(detail.high24h, symbol: currencySymbol)} / ${Formatters.formatCurrency(detail.low24h, symbol: currencySymbol)}',
          ),
          _buildDivider(),
          _buildRow(
            'Circulating Supply',
            Formatters.formatSupply(detail.circulatingSupply, symbol: detail.symbol),
          ),
          _buildDivider(),
          _buildRow(
            'Total Supply',
            detail.totalSupply != null
                ? Formatters.formatSupply(detail.totalSupply, symbol: detail.symbol)
                : 'Unlimited / Unknown',
          ),
          _buildDivider(),
          _buildRow(
            'Max Supply',
            detail.maxSupply != null
                ? Formatters.formatSupply(detail.maxSupply, symbol: detail.symbol)
                : 'Unlimited',
          ),
          _buildDivider(),
          _buildAthAtlRow(
            title: 'All-Time High',
            price: detail.ath,
            changePercent: detail.athChangePercentage,
            dateStr: detail.athDate,
            isAth: true,
          ),
          _buildDivider(),
          _buildAthAtlRow(
            title: 'All-Time Low',
            price: detail.atl,
            changePercent: detail.atlChangePercentage,
            dateStr: detail.atlDate,
            isAth: false,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthAtlRow({
    required String title,
    required double price,
    required double changePercent,
    required String? dateStr,
    required bool isAth,
  }) {
    String formattedDate = '';
    if (dateStr != null) {
      final parsed = DateTime.tryParse(dateStr);
      if (parsed != null) {
        formattedDate = '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
      }
    }

    final changeColor = changePercent >= 0 ? AppTheme.gainGreen : AppTheme.lossRed;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
              if (formattedDate.isNotEmpty)
                Text(
                  formattedDate,
                  style: const TextStyle(
                    color: AppTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                Formatters.formatCurrency(price, symbol: currencySymbol),
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                Formatters.formatPercentage(changePercent),
                style: TextStyle(
                  color: changeColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      color: AppTheme.darkBorder,
      height: 1,
      thickness: 0.8,
    );
  }
}
