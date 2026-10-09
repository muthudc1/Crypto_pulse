import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../config/theme.dart';

class SkeletonLoaders {
  SkeletonLoaders._();

  static Widget coinListSkeleton({int itemCount = 8}) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: AppTheme.darkSurfaceVariant,
          highlightColor: AppTheme.darkBorder.withOpacity(0.5),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                // Rank
                Container(
                  width: 20,
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                // Coin Icon
                Container(
                  width: 36,
                  height: 36,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                // Name and Symbol
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 90,
                        height: 14,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 40,
                        height: 11,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
                // Mini Sparkline placeholder
                Container(
                  width: 60,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 16),
                // Price & 24h change
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      width: 70,
                      height: 14,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 50,
                      height: 18,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget chartSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkSurfaceVariant,
      highlightColor: AppTheme.darkBorder.withOpacity(0.5),
      child: Container(
        height: 260,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  static Widget statsGridSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkSurfaceVariant,
      highlightColor: AppTheme.darkBorder.withOpacity(0.5),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 2.2,
        ),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.darkCard,
              borderRadius: BorderRadius.circular(12),
            ),
          );
        },
      ),
    );
  }

  static Widget marketBannerSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppTheme.darkSurfaceVariant,
      highlightColor: AppTheme.darkBorder.withOpacity(0.5),
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
