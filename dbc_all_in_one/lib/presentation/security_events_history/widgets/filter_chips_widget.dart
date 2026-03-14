import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class FilterChipsWidget extends StatelessWidget {
  final Set<String> activeFilters;
  final Function(String) onFilterToggled;

  const FilterChipsWidget({
    super.key,
    required this.activeFilters,
    required this.onFilterToggled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final filters = [
      {'label': 'Motion', 'icon': 'motion_photos_on'},
      {'label': 'Person', 'icon': 'person'},
      {'label': 'Vehicle', 'icon': 'directions_car'},
      {'label': 'High', 'icon': 'priority_high'},
      {'label': 'Medium', 'icon': 'remove'},
      {'label': 'Low', 'icon': 'arrow_downward'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (activeFilters.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${activeFilters.length}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              if (activeFilters.isNotEmpty)
                TextButton(
                  onPressed: () {
                    for (var filter in List.from(activeFilters)) {
                      onFilterToggled(filter);
                    }
                  },
                  child: const Text('Clear All'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: filters.map((filter) {
              final isActive = activeFilters.contains(filter['label']);
              return FilterChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: filter['icon']!,
                      color: isActive
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(filter['label']!),
                  ],
                ),
                selected: isActive,
                onSelected: (_) => onFilterToggled(filter['label']!),
                backgroundColor: colorScheme.surface,
                selectedColor: colorScheme.primary,
                checkmarkColor: colorScheme.onPrimary,
                labelStyle: theme.textTheme.labelMedium?.copyWith(
                  color:
                      isActive ? colorScheme.onPrimary : colorScheme.onSurface,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                ),
                side: BorderSide(
                  color: isActive ? colorScheme.primary : colorScheme.outline,
                  width: 1,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
