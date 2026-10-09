import 'package:flutter/material.dart';
import '../../config/theme.dart';

class ErrorView extends StatelessWidget {
  final String? message;
  final VoidCallback? onRetry;
  final bool isCompact;

  const ErrorView({
    super.key,
    this.message,
    this.onRetry,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isRateLimit = message?.toLowerCase().contains('429') == true ||
        message?.toLowerCase().contains('rate limit') == true;

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.darkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.lossRed.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              isRateLimit ? Icons.timer_outlined : Icons.error_outline_rounded,
              color: isRateLimit ? Colors.amber : AppTheme.lossRed,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message ?? 'Failed to load data',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onRetry != null)
              TextButton(
                onPressed: onRetry,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Retry', style: TextStyle(color: AppTheme.primaryLight, fontSize: 12)),
              ),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: (isRateLimit ? Colors.amber : AppTheme.lossRed).withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isRateLimit ? Icons.hourglass_empty_rounded : Icons.cloud_off_rounded,
                size: 48,
                color: isRateLimit ? Colors.amber : AppTheme.lossRed,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              isRateLimit ? 'API Rate Limit Exceeded' : 'Data Request Failed',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              message ??
                  'Unable to connect to market servers. Please check your internet connection or try again.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    height: 1.4,
                  ),
              textAlign: TextAlign.center,
            ),
            if (isRateLimit) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.info_outline, size: 16, color: AppTheme.textMuted),
                    SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        'Market data rate limit is ~10-30 req/min',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
