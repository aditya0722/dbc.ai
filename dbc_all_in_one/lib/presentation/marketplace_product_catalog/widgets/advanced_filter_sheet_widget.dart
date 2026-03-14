import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class AdvancedFilterSheetWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onApplyFilters;

  const AdvancedFilterSheetWidget({
    super.key,
    required this.currentFilters,
    required this.onApplyFilters,
  });

  @override
  State<AdvancedFilterSheetWidget> createState() =>
      _AdvancedFilterSheetWidgetState();
}

class _AdvancedFilterSheetWidgetState extends State<AdvancedFilterSheetWidget> {
  late Map<String, dynamic> _filters;
  final TextEditingController _maxPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filters = Map.from(widget.currentFilters);
    if (_filters['maxPrice'] != null) {
      _maxPriceController.text = _filters['maxPrice'].toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Advanced Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _filters = {
                            'maxPrice': null,
                            'minRating': null,
                            'deliveryTime': null,
                            'availability': null,
                            'certifications': <String>[],
                          };
                          _maxPriceController.clear();
                        });
                      },
                      child: const Text('Clear All'),
                    ),
                    IconButton(
                      icon: CustomIconWidget(
                        iconName: 'close',
                        color: theme.colorScheme.onSurface,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price range
                  Text(
                    'Maximum Price',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                      hintText: 'Enter maximum price',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _filters['maxPrice'] =
                            value.isNotEmpty ? double.tryParse(value) : null;
                      });
                    },
                  ),
                  SizedBox(height: 3.h),

                  // Minimum rating
                  Text(
                    'Minimum Vendor Rating',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children:
                        [3.0, 4.0, 4.5].map((rating) {
                          final isSelected = _filters['minRating'] == rating;
                          return ChoiceChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CustomIconWidget(
                                  iconName: 'star',
                                  color: const Color(0xFFFBBF24),
                                  size: 16,
                                ),
                                SizedBox(width: 1.w),
                                Text('$rating+'),
                              ],
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _filters['minRating'] =
                                    selected ? rating : null;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 3.h),

                  // Delivery time
                  Text(
                    'Maximum Delivery Time',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children:
                        [1, 3, 5, 7].map((days) {
                          final isSelected = _filters['deliveryTime'] == days;
                          return ChoiceChip(
                            label: Text('$days days'),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _filters['deliveryTime'] =
                                    selected ? days : null;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 3.h),

                  // Availability status
                  Text(
                    'Availability',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children:
                        ['in_stock', 'low_stock', 'pre_order'].map((status) {
                          final isSelected = _filters['availability'] == status;
                          final label =
                              status == 'in_stock'
                                  ? 'In Stock'
                                  : status == 'low_stock'
                                  ? 'Low Stock'
                                  : 'Pre-Order';
                          return ChoiceChip(
                            label: Text(label),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                _filters['availability'] =
                                    selected ? status : null;
                              });
                            },
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 3.h),

                  // Certifications
                  Text(
                    'Certifications',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children:
                        ['Organic', 'Non-GMO', 'Grade A', 'Food Safe'].map((
                          cert,
                        ) {
                          final certList =
                              _filters['certifications'] as List<String>;
                          final isSelected = certList.contains(cert);
                          return FilterChip(
                            label: Text(cert),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  certList.add(cert);
                                } else {
                                  certList.remove(cert);
                                }
                              });
                            },
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ),
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
    );
  }

  @override
  void dispose() {
    _maxPriceController.dispose();
    super.dispose();
  }
}
