import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Metrics card widget displaying business KPIs with trend indicators
class MetricsCardWidget extends StatelessWidget {
  final String title;
  final String value;
  final String icon;
  final Color color;
  final String trend;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const MetricsCardWidget({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.trend,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon container
            Container(
              width: 14.w,
              height: 14.w,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: icon,
                  color: color,
                  size: 24,
                ),
              ),
            ),

            SizedBox(width: 3.w),

            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title
                  Text(
                    title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 0.5.h),

                  // Value
                  Text(
                    value,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                      fontSize: MediaQuery.of(context).size.width > 600 ? 18 : 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  SizedBox(height: 0.5.h),

                  // Trend indicator
                  Row(
                    children: [
                      CustomIconWidget(
                        iconName: trend.contains('+')
                            ? 'trending_up'
                            : trend.contains('-')
                                ? 'trending_down'
                                : 'info',
                        color: trend.contains('+')
                            ? const Color(0xFF10B981)
                            : trend.contains('-')
                                ? const Color(0xFFEF4444)
                                : theme.colorScheme.onSurfaceVariant,
                        size: 16,
                      ),

                      SizedBox(width: 1.w),

                      Expanded(
                        child: Text(
                          trend,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: trend.contains('+')
                                ? const Color(0xFF10B981)
                                : trend.contains('-')
                                    ? const Color(0xFFEF4444)
                                    : theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
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

            // Chevron icon
            CustomIconWidget(
              iconName: 'chevron_right',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
