import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Bottom sheet for filtering inventory items
class FilterBottomSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  late Map<String, dynamic> _filters;

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 1.h),
              width: 10.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.0),
              ),
            ),
            // Header
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Inventory',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filters = {
                          'stockStatus': null,
                          'category': null,
                          'supplier': null,
                          'location': null,
                          'lastUpdated': null,
                        };
                      });
                    },
                    child: Text(
                      'Clear All',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),
            // Filter options
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      context,
                      'Stock Status',
                      ['All', 'Adequate', 'Low Stock', 'Critical'],
                      _filters['stockStatus'],
                      (value) =>
                          setState(() => _filters['stockStatus'] = value),
                    ),
                    SizedBox(height: 2.h),
                    _buildFilterSection(
                      context,
                      'Category',
                      ['All', 'Raw Materials', 'Store Items', 'Finished Goods'],
                      _filters['category'],
                      (value) => setState(() => _filters['category'] = value),
                    ),
                    SizedBox(height: 2.h),
                    _buildFilterSection(
                      context,
                      'Supplier',
                      ['All', 'Supplier A', 'Supplier B', 'Supplier C'],
                      _filters['supplier'],
                      (value) => setState(() => _filters['supplier'] = value),
                    ),
                    SizedBox(height: 2.h),
                    _buildFilterSection(
                      context,
                      'Location',
                      ['All', 'Main Store', 'Kitchen', 'Counter', 'Warehouse'],
                      _filters['location'],
                      (value) => setState(() => _filters['location'] = value),
                    ),
                    SizedBox(height: 2.h),
                    _buildFilterSection(
                      context,
                      'Last Updated',
                      ['All', 'Today', 'This Week', 'This Month'],
                      _filters['lastUpdated'],
                      (value) =>
                          setState(() => _filters['lastUpdated'] = value),
                    ),
                  ],
                ),
              ),
            ),
            // Apply button
            Padding(
              padding: EdgeInsets.all(4.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters(_filters);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context,
    String title,
    List<String> options,
    String? selectedValue,
    Function(String?) onChanged,
  ) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedValue == option ||
                (selectedValue == null && option == 'All');
            return GestureDetector(
              onTap: () => onChanged(option == 'All' ? null : option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withValues(alpha: 0.1)
                      : theme.colorScheme.surface,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  option,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.onSurfaceVariant,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
