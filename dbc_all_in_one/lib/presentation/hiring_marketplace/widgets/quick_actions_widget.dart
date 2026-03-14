import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

class QuickActionsWidget extends StatelessWidget {
  final VoidCallback onViewProfile;
  final VoidCallback onSendMessage;
  final VoidCallback onScheduleInterview;
  final VoidCallback onAddToFavorites;

  const QuickActionsWidget({
    super.key,
    required this.onViewProfile,
    required this.onSendMessage,
    required this.onScheduleInterview,
    required this.onAddToFavorites,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            context,
            theme,
            icon: 'person',
            label: 'View Full Profile',
            onTap: onViewProfile,
          ),
          SizedBox(height: 2.h),
          _buildActionButton(
            context,
            theme,
            icon: 'message',
            label: 'Send Message',
            onTap: onSendMessage,
          ),
          SizedBox(height: 2.h),
          _buildActionButton(
            context,
            theme,
            icon: 'calendar_today',
            label: 'Schedule Interview',
            onTap: onScheduleInterview,
          ),
          SizedBox(height: 2.h),
          _buildActionButton(
            context,
            theme,
            icon: 'favorite_border',
            label: 'Add to Favorites',
            onTap: onAddToFavorites,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    ThemeData theme, {
    required String icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: theme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
