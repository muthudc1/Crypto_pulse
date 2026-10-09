import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../utils/formatters.dart';

class ExpandableDescription extends StatefulWidget {
  final String? text;
  final int trimLines;

  const ExpandableDescription({
    super.key,
    required this.text,
    this.trimLines = 4,
  });

  @override
  State<ExpandableDescription> createState() => _ExpandableDescriptionState();
}

class _ExpandableDescriptionState extends State<ExpandableDescription> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final cleanContent = Formatters.cleanHtmlDescription(widget.text);

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
            'About Asset',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            cleanContent,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 13,
              height: 1.5,
            ),
            maxLines: _isExpanded ? null : widget.trimLines,
            overflow: _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
          ),
          if (cleanContent.length > 200) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => setState(() => _isExpanded = !_isExpanded),
              child: Text(
                _isExpanded ? 'Show less' : 'Read more',
                style: const TextStyle(
                  color: AppTheme.primaryLight,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
