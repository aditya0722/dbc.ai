import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class RoleFilterChipWidget extends StatelessWidget {
  final String role;
  final bool isSelected;
  final VoidCallback onTap;

  const RoleFilterChipWidget({
    super.key,
    required this.role,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: _getRoleIcon(role),
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
            SizedBox(width: 2.w),
            Text(
              role,
              style: theme.textTheme.labelLarge?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'all':
        return 'grid_view';
      case 'cashier':
        return 'point_of_sale';
      case 'waiter':
        return 'restaurant';
      case 'cook':
        return 'restaurant_menu';
      case 'cleaner':
        return 'cleaning_services';
      case 'trainer':
        return 'fitness_center';
      case 'worker':
        return 'construction';
      case 'guard':
        return 'security';
      default:
        return 'work';
    }
  }
}
