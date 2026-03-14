import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Transaction card widget with expandable details and swipe actions
class TransactionCardWidget extends StatelessWidget {
  final Map<String, dynamic> transaction;
  final bool isSelected;
  final bool isMultiSelectMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onSwipeRight;

  const TransactionCardWidget({
    super.key,
    required this.transaction,
    required this.isSelected,
    required this.isMultiSelectMode,
    required this.onTap,
    required this.onLongPress,
    required this.onSwipeRight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dismissible(
      key: Key(transaction['id'] as String),
      direction: DismissDirection.startToEnd,
      confirmDismiss: (direction) async {
        onSwipeRight();
        return false; // Prevent actual dismissal
      },
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.only(left: 4.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(16),
        ),
        child: CustomIconWidget(
          iconName: 'more_horiz',
          color: theme.colorScheme.primary,
          size: 32,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color:
                isSelected
                    ? theme.colorScheme.primaryContainer.withValues(alpha: 0.5)
                    : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color:
                  isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isMultiSelectMode)
                    Padding(
                      padding: EdgeInsets.only(right: 3.w),
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (value) => onTap(),
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),

                  // Payment method icon
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getMethodColor(
                        transaction['method'] as String,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: CustomIconWidget(
                      iconName: _getMethodIcon(transaction['method'] as String),
                      color: _getMethodColor(transaction['method'] as String),
                      size: 24,
                    ),
                  ),
                  SizedBox(width: 3.w),

                  // Transaction details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction['recipient'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '\$${transaction['amount'].toStringAsFixed(2)}',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Row(
                          children: [
                            Text(
                              transaction['id'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              ' • ',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              transaction['time'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 1.5.h),

              // Status and progress
              Row(
                children: [
                  _buildStatusChip(transaction['status'] as String, theme),
                  const Spacer(),
                  if (transaction['status'] == 'processing')
                    SizedBox(
                      width: 20.w,
                      child: LinearProgressIndicator(
                        value: 0.6,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),

              // Security badges
              if ((transaction['securityBadges'] as List).isNotEmpty) ...[
                SizedBox(height: 1.h),
                Wrap(
                  spacing: 1.w,
                  children:
                      (transaction['securityBadges'] as List)
                          .take(2)
                          .map(
                            (badge) => Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 2.w,
                                vertical: 0.3.h,
                              ),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.tertiaryContainer
                                    .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIconWidget(
                                    iconName: 'verified_user',
                                    color: theme.colorScheme.tertiary,
                                    size: 12,
                                  ),
                                  SizedBox(width: 1.w),
                                  Text(
                                    badge as String,
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    IconData iconData;
    String label;

    switch (status) {
      case 'pending':
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        iconData = Icons.schedule;
        label = 'Pending';
        break;
      case 'processing':
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        iconData = Icons.sync;
        label = 'Processing';
        break;
      case 'completed':
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        iconData = Icons.check_circle;
        label = 'Completed';
        break;
      case 'failed':
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        iconData = Icons.error;
        label = 'Failed';
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurface;
        iconData = Icons.info;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(iconData, size: 14, color: textColor),
          SizedBox(width: 1.w),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getMethodIcon(String method) {
    switch (method) {
      case 'credit_card':
        return 'credit_card';
      case 'bank_transfer':
        return 'account_balance';
      case 'digital_wallet':
        return 'account_balance_wallet';
      case 'cash':
        return 'attach_money';
      default:
        return 'payments';
    }
  }

  Color _getMethodColor(String method) {
    switch (method) {
      case 'credit_card':
        return const Color(0xFF6B46C1);
      case 'bank_transfer':
        return const Color(0xFF0EA5E9);
      case 'digital_wallet':
        return const Color(0xFFF59E0B);
      case 'cash':
        return const Color(0xFF10B981);
      default:
        return const Color(0xFF64748B);
    }
  }
}
