import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Payroll card widget displaying individual employee payroll information
class PayrollCardWidget extends StatelessWidget {
  final Map<String, dynamic> payrollData;
  final bool isExpanded;
  final VoidCallback onTap;
  final Function(String) onAction;

  const PayrollCardWidget({
    super.key,
    required this.payrollData,
    required this.isExpanded,
    required this.onTap,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPaid = (payrollData['status'] as String) == 'Paid';

    return Slidable(
      key: ValueKey(payrollData['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onAction('mark_paid'),
            backgroundColor: const Color(0xFF10B981),
            foregroundColor: Colors.white,
            icon: Icons.check_circle,
            label: 'Mark Paid',
          ),
          SlidableAction(
            onPressed: (_) => onAction('generate_slip'),
            backgroundColor: const Color(0xFF0EA5E9),
            foregroundColor: Colors.white,
            icon: Icons.receipt_long,
            label: 'Generate',
          ),
          SlidableAction(
            onPressed: (_) => onAction('send_payment'),
            backgroundColor: const Color(0xFF6B46C1),
            foregroundColor: Colors.white,
            icon: Icons.send,
            label: 'Send',
          ),
          SlidableAction(
            onPressed: (_) => onAction('add_bonus'),
            backgroundColor: const Color(0xFFF59E0B),
            foregroundColor: Colors.white,
            icon: Icons.card_giftcard,
            label: 'Bonus',
          ),
        ],
      ),
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isPaid
                ? const Color(0xFF10B981).withValues(alpha: 0.3)
                : theme.colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Text(
                        (payrollData['name'] as String)
                            .substring(0, 1)
                            .toUpperCase(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            payrollData['name'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'badge',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                payrollData['role'] as String,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              CustomIconWidget(
                                iconName: 'business',
                                color: theme.colorScheme.onSurfaceVariant,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Expanded(
                                child: Text(
                                  payrollData['department'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 2.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFF10B981).withValues(alpha: 0.1)
                            : const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        payrollData['status'] as String,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isPaid
                              ? const Color(0xFF10B981)
                              : const Color(0xFFF59E0B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoItem(
                      theme,
                      'Base Pay',
                      '\$${(payrollData['basePay'] as double).toStringAsFixed(2)}',
                    ),
                    _buildInfoItem(
                      theme,
                      'Overtime',
                      '${payrollData['overtimeHours']} hrs',
                    ),
                    _buildInfoItem(
                      theme,
                      'Bonus',
                      '\$${(payrollData['bonus'] as double).toStringAsFixed(2)}',
                    ),
                  ],
                ),
                SizedBox(height: 1.5.h),
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Net Pay',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '\$${(payrollData['netPay'] as double).toStringAsFixed(2)}',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isExpanded) ...[
                  SizedBox(height: 2.h),
                  Divider(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2)),
                  SizedBox(height: 1.h),
                  _buildDetailedBreakdown(theme),
                ],
                SizedBox(height: 1.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => onAction('calculate'),
                        icon: CustomIconWidget(
                          iconName: 'calculate',
                          color: theme.colorScheme.primary,
                          size: 18,
                        ),
                        label: Text('Calculate'),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => onAction('export'),
                        icon: CustomIconWidget(
                          iconName: 'download',
                          color: Colors.white,
                          size: 18,
                        ),
                        label: Text('Export'),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem(ThemeData theme, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedBreakdown(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Detailed Breakdown',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        _buildBreakdownRow(
          theme,
          'Base Pay',
          '\$${(payrollData['basePay'] as double).toStringAsFixed(2)}',
        ),
        _buildBreakdownRow(
          theme,
          'Overtime (${payrollData['overtimeHours']} hrs × \$${(payrollData['overtimeRate'] as double).toStringAsFixed(2)})',
          '\$${(payrollData['overtimeAmount'] as double).toStringAsFixed(2)}',
        ),
        _buildBreakdownRow(
          theme,
          'Piece Rate (${payrollData['pieceRateUnits']} units)',
          '\$${(payrollData['pieceRateAmount'] as double).toStringAsFixed(2)}',
        ),
        _buildBreakdownRow(
          theme,
          'Bonus',
          '\$${(payrollData['bonus'] as double).toStringAsFixed(2)}',
          isPositive: true,
        ),
        _buildBreakdownRow(
          theme,
          'Late Fines',
          '-\$${(payrollData['lateFines'] as double).toStringAsFixed(2)}',
          isNegative: true,
        ),
        _buildBreakdownRow(
          theme,
          'Deductions',
          '-\$${(payrollData['deductions'] as double).toStringAsFixed(2)}',
          isNegative: true,
        ),
        SizedBox(height: 1.h),
        Divider(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        SizedBox(height: 1.h),
        _buildBreakdownRow(
          theme,
          'Net Pay',
          '\$${(payrollData['netPay'] as double).toStringAsFixed(2)}',
          isBold: true,
        ),
      ],
    );
  }

  Widget _buildBreakdownRow(
    ThemeData theme,
    String label,
    String value, {
    bool isPositive = false,
    bool isNegative = false,
    bool isBold = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 0.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isBold ? FontWeight.w600 : FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              color: isPositive
                  ? const Color(0xFF10B981)
                  : isNegative
                      ? const Color(0xFFEF4444)
                      : theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
