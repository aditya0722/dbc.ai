import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header widget with search bar and category segmented control
class InventoryHeaderWidget extends StatelessWidget {
  final TextEditingController searchController;
  final String selectedCategory;
  final Function(String) onCategoryChanged;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const InventoryHeaderWidget({
    super.key,
    required this.searchController,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.onSearchTap,
    required this.onFilterTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      child: Column(
        children: [
          // Search bar with filter button
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.3),
                    ),
                  ),
                  child: TextField(
                    controller: searchController,
                    onTap: onSearchTap,
                    decoration: InputDecoration(
                      hintText: 'Search items, scan barcode...',
                      hintStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      prefixIcon: CustomIconWidget(
                        iconName: 'search',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: CustomIconWidget(
                              iconName: 'qr_code_scanner',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            onPressed: onSearchTap,
                          ),
                          IconButton(
                            icon: CustomIconWidget(
                              iconName: 'mic',
                              color: theme.colorScheme.primary,
                              size: 20,
                            ),
                            onPressed: onSearchTap,
                          ),
                        ],
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.5.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Container(
                height: 6.h,
                width: 6.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: IconButton(
                  icon: CustomIconWidget(
                    iconName: 'filter_list',
                    color: theme.colorScheme.primary,
                    size: 20,
                  ),
                  onPressed: onFilterTap,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Category segmented control
          Container(
            height: 6.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                _buildCategoryButton(
                  context,
                  'Raw Materials',
                  selectedCategory == 'Raw Materials',
                  () => onCategoryChanged('Raw Materials'),
                ),
                _buildCategoryButton(
                  context,
                  'Store Items',
                  selectedCategory == 'Store Items',
                  () => onCategoryChanged('Store Items'),
                ),
                _buildCategoryButton(
                  context,
                  'Finished Goods',
                  selectedCategory == 'Finished Goods',
                  () => onCategoryChanged('Finished Goods'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryButton(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(6.0),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: isSelected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.onSurfaceVariant,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    );
  }
}
