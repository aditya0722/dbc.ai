import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../widgets/custom_icon_widget.dart';

/// Payment method selector widget with horizontal scrolling
class PaymentMethodSelectorWidget extends StatelessWidget {
  final String selectedMethod;
  final Function(String) onMethodSelected;

  const PaymentMethodSelectorWidget({
    super.key,
    required this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final methods = [
      {'id': 'all', 'icon': 'payments', 'label': 'All'},
      {'id': 'credit_card', 'icon': 'credit_card', 'label': 'Card'},
      {'id': 'bank_transfer', 'icon': 'account_balance', 'label': 'Bank'},
      {
        'id': 'digital_wallet',
        'icon': 'account_balance_wallet',
        'label': 'Wallet',
      },
      {'id': 'cash', 'icon': 'attach_money', 'label': 'Cash'},
    ];

    return Container(
      height: 10.h,
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        itemCount: methods.length,
        separatorBuilder: (context, index) => SizedBox(width: 3.w),
        itemBuilder: (context, index) {
          final method = methods[index];
          final isSelected = selectedMethod == method['id'];

          return InkWell(
            onTap: () => onMethodSelected(method['id'] as String),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              decoration: BoxDecoration(
                color:
                    isSelected
                        ? theme.colorScheme.primaryContainer
                        : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color:
                      isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.outline,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomIconWidget(
                    iconName: method['icon'] as String,
                    color:
                        isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  SizedBox(height: 0.5.h),
                  Text(
                    method['label'] as String,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color:
                          isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
