import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class GSTOverviewCard extends StatelessWidget {
  final double totalSales;
  final double totalPurchases;
  final double inputTaxCredit;
  final double gstPayable;

  const GSTOverviewCard({
    super.key,
    required this.totalSales,
    required this.totalPurchases,
    required this.inputTaxCredit,
    required this.gstPayable,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormat = NumberFormat('#,##,###.##');

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance,
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'GST Overview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Current Period Summary',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 2.h),
            _buildMetricRow(
              theme,
              'Total Sales',
              '₹${currencyFormat.format(totalSales)}',
              Icons.trending_up,
              const Color(0xFF10B981),
            ),
            SizedBox(height: 1.h),
            _buildMetricRow(
              theme,
              'Total Purchases',
              '₹${currencyFormat.format(totalPurchases)}',
              Icons.shopping_cart,
              const Color(0xFF6366F1),
            ),
            SizedBox(height: 1.h),
            _buildMetricRow(
              theme,
              'Input Tax Credit',
              '₹${currencyFormat.format(inputTaxCredit)}',
              Icons.discount,
              const Color(0xFF8B5CF6),
            ),
            SizedBox(height: 1.h),
            Divider(color: theme.colorScheme.outlineVariant),
            SizedBox(height: 1.h),
            _buildMetricRow(
              theme,
              'GST Payable',
              '₹${currencyFormat.format(gstPayable)}',
              Icons.payment,
              const Color(0xFFEF4444),
              isHighlight: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricRow(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color, {
    bool isHighlight = false,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color:
                  isHighlight
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurfaceVariant,
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: isHighlight ? color : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
