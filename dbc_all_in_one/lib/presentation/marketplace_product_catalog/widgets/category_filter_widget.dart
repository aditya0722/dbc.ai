import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class CategoryFilterWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryFilterWidget({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  String _formatLabel(String category) {
    if (category == 'all') return 'All';
    return category
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: FilterChip(
        label: Text(_formatLabel(label)),
        selected: isSelected,
        onSelected: (_) => onTap(),
        selectedColor: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.surface,
        labelStyle: theme.textTheme.labelMedium?.copyWith(
          color:
              isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurface,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide(
            color:
                isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
      ),
    );
  }
}
