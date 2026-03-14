import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VendorListingCardWidget extends StatelessWidget {
  final Map<String, dynamic> listing;
  final VoidCallback onUpdateStock;
  final VoidCallback onToggleVisibility;

  const VendorListingCardWidget({
    super.key,
    required this.listing,
    required this.onUpdateStock,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = listing['marketplace_products'] as Map<String, dynamic>;
    final currentStock = listing['current_stock'] as int? ?? 0;
    final listingStatus = listing['listing_status'] as String;
    final availabilityStatus = listing['availability_status'] as String;

    Color getStatusColor() {
      if (availabilityStatus == 'in_stock') return const Color(0xFF10B981);
      if (availabilityStatus == 'low_stock') return const Color(0xFFFBBF24);
      return const Color(0xFFEF4444);
    }

    String getStatusLabel() {
      if (availabilityStatus == 'in_stock') return 'In Stock';
      if (availabilityStatus == 'low_stock') return 'Low Stock';
      return 'Out of Stock';
    }

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Product image
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12.0),
              bottomLeft: Radius.circular(12.0),
            ),
            child: CustomImageWidget(
              imageUrl:
                  product['image_url'] as String? ??
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c',
              width: 25.w,
              height: 15.h,
              fit: BoxFit.cover,
              semanticLabel: product['product_name'] as String,
            ),
          ),
          // Product details
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          product['product_name'] as String,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: getStatusColor().withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                        child: Text(
                          getStatusLabel(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: getStatusColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'inventory_2',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$currentStock ${product['base_unit']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      CustomIconWidget(
                        iconName: 'attach_money',
                        color: theme.colorScheme.primary,
                        size: 16,
                      ),
                      Text(
                        '\$${listing['price_per_unit']}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'visibility',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${listing['views_count'] ?? 0} views',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'shopping_cart',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${listing['orders_count'] ?? 0} orders',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onUpdateStock,
                          icon: CustomIconWidget(
                            iconName: 'edit',
                            color: theme.colorScheme.primary,
                            size: 16,
                          ),
                          label: const Text('Update Stock'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 1.h),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      IconButton(
                        onPressed: onToggleVisibility,
                        icon: CustomIconWidget(
                          iconName:
                              listingStatus == 'active'
                                  ? 'visibility_off'
                                  : 'visibility',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: theme.colorScheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
