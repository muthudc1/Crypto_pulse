import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../providers/market_provider.dart';

class FilterSortBottomSheet extends StatelessWidget {
  final MarketFilter selectedFilter;
  final MarketSort selectedSort;
  final Function(MarketFilter) onFilterSelected;
  final Function(MarketSort) onSortSelected;

  const FilterSortBottomSheet({
    super.key,
    required this.selectedFilter,
    required this.selectedSort,
    required this.onFilterSelected,
    required this.onSortSelected,
  });

  static void show(
    BuildContext context, {
    required MarketFilter selectedFilter,
    required MarketSort selectedSort,
    required Function(MarketFilter) onFilterSelected,
    required Function(MarketSort) onSortSelected,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => FilterSortBottomSheet(
        selectedFilter: selectedFilter,
        selectedSort: selectedSort,
        onFilterSelected: onFilterSelected,
        onSortSelected: onSortSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.darkBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort Markets',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, size: 20),
                    color: AppTheme.textSecondary,
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Filter Section
              const Text(
                'FILTER BY CATEGORY',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildFilterChip(context, 'All Coins', MarketFilter.all),
                  _buildFilterChip(context, '🚀 Top Gainers (24h > 0)', MarketFilter.gainers),
                  _buildFilterChip(context, '📉 Top Losers (24h < 0)', MarketFilter.losers),
                  _buildFilterChip(context, '⭐ Top 10 MCap', MarketFilter.top10),
                  _buildFilterChip(context, '🏆 Top 50 MCap', MarketFilter.top50),
                ],
              ),
              const SizedBox(height: 24),

              // Sort Section
              const Text(
                'SORT ORDER',
                style: TextStyle(
                  color: AppTheme.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              ...MarketSort.values.map(
                (sort) => _buildSortRadioTile(context, sort),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, MarketFilter filter) {
    final isSelected = selectedFilter == filter;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          onFilterSelected(filter);
          Navigator.pop(context);
        }
      },
      selectedColor: AppTheme.primary,
      backgroundColor: AppTheme.darkCard,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        fontSize: 12,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? AppTheme.primary : AppTheme.darkBorder,
        ),
      ),
    );
  }

  Widget _buildSortRadioTile(BuildContext context, MarketSort sort) {
    final isSelected = selectedSort == sort;
    return InkWell(
      onTap: () {
        onSortSelected(sort);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? AppTheme.primaryLight : AppTheme.textMuted,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                sort.label,
                style: TextStyle(
                  color: isSelected ? AppTheme.textPrimary : AppTheme.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
