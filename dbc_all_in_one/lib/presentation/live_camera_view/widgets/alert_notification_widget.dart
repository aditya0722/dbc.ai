import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Alert notification overlay for motion detection events
class AlertNotificationWidget extends StatelessWidget {
  final String message;
  final String timestamp;
  final VoidCallback onDismiss;

  const AlertNotificationWidget({
    super.key,
    required this.message,
    required this.timestamp,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Positioned(
      top: 12.h,
      left: 4.w,
      right: 4.w,
      child: Dismissible(
        key: ValueKey(message),
        direction: DismissDirection.horizontal,
        onDismissed: (_) {
          onDismiss();
        },
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.error.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onError.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'warning',
                    color: theme.colorScheme.onError,
                    size: 24,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Motion Detected',
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: theme.colorScheme.onError,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        message,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color:
                              theme.colorScheme.onError.withValues(alpha: 0.9),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        timestamp,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color:
                              theme.colorScheme.onError.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onError,
                    size: 20,
                  ),
                  onPressed: onDismiss,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
