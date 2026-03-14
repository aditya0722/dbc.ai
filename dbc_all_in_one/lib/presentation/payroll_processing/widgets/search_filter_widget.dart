import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Search and filter widget for payroll list
class SearchFilterWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedDepartment;
  final String selectedStatus;
  final String selectedWageType;
  final Function(String) onDepartmentChanged;
  final Function(String) onStatusChanged;
  final Function(String) onWageTypeChanged;
  final VoidCallback onClearFilters;

  const SearchFilterWidget({
    super.key,
    required this.searchController,
    required this.selectedDepartment,
    required this.selectedStatus,
    required this.selectedWageType,
    required this.onDepartmentChanged,
    required this.onStatusChanged,
    required this.onWageTypeChanged,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8.0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search by name or role...',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
              ),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: CustomIconWidget(
                        iconName: 'clear',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () => searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 2,
                ),
              ),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            ),
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Text(
                'Filters',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: onClearFilters,
                icon: CustomIconWidget(
                  iconName: 'clear_all',
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
                label: Text('Clear All'),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: [
              _buildFilterChip(
                theme,
                'Department',
                selectedDepartment,
                [
                  'All',
                  'Front',
                  'Kitchen',
                  'Rooms',
                  'Floor',
                  'Production',
                  'Gym'
                ],
                onDepartmentChanged,
              ),
              _buildFilterChip(
                theme,
                'Status',
                selectedStatus,
                ['All', 'Pending', 'Paid'],
                onStatusChanged,
              ),
              _buildFilterChip(
                theme,
                'Wage Type',
                selectedWageType,
                ['All', 'Hourly', 'Daily', 'Piece Rate'],
                onWageTypeChanged,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    ThemeData theme,
    String label,
    String selectedValue,
    List<String> options,
    Function(String) onChanged,
  ) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      itemBuilder: (context) => options
          .map(
            (option) => PopupMenuItem<String>(
              value: option,
              child: Row(
                children: [
                  if (option == selectedValue)
                    Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: CustomIconWidget(
                        iconName: 'check',
                        color: theme.colorScheme.primary,
                        size: 18,
                      ),
                    ),
                  Text(option),
                ],
              ),
            ),
          )
          .toList(),
      child: Chip(
        label: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$label: $selectedValue',
              style: theme.textTheme.labelMedium,
            ),
            SizedBox(width: 1.w),
            CustomIconWidget(
              iconName: 'arrow_drop_down',
              color: theme.colorScheme.onSurfaceVariant,
              size: 18,
            ),
          ],
        ),
        backgroundColor: selectedValue != 'All'
            ? theme.colorScheme.primary.withValues(alpha: 0.1)
            : theme.colorScheme.surface,
        side: BorderSide(
          color: selectedValue != 'All'
              ? theme.colorScheme.primary.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
    );
  }
}
