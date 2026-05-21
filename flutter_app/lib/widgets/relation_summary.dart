import 'package:flutter/material.dart';

class RelationSummaryItem {
  final String label;
  final String value;

  const RelationSummaryItem({required this.label, required this.value});
}

class RelationSummary extends StatelessWidget {
  final List<RelationSummaryItem> items;

  const RelationSummary({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = theme.colorScheme.surfaceVariant;
    final textColor = theme.colorScheme.onSurfaceVariant;

    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: items
          .map(
            (item) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${item.label}: ${item.value}',
                style: theme.textTheme.labelSmall?.copyWith(color: textColor),
              ),
            ),
          )
          .toList(),
    );
  }
}
