import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class StaffCardWidget extends StatelessWidget {
  final Map<String, dynamic> staff;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMarkAttendance;
  final VoidCallback onViewTimesheet;
  final VoidCallback onCalculatePay;
  final VoidCallback onSendMessage;

  const StaffCardWidget({
    super.key,
    required this.staff,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onMarkAttendance,
    required this.onViewTimesheet,
    required this.onCalculatePay,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isCheckedIn = staff['status'] == 'checked-in';

    return Slidable(
      key: ValueKey(staff['id']),
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onMarkAttendance(),
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            icon: isCheckedIn ? Icons.logout : Icons.login,
            label: isCheckedIn ? 'Check Out' : 'Check In',
          ),
          SlidableAction(
            onPressed: (_) => onViewTimesheet(),
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
            icon: Icons.schedule,
            label: 'Timesheet',
          ),
          SlidableAction(
            onPressed: (_) => onCalculatePay(),
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            icon: Icons.attach_money,
            label: 'Pay',
          ),
          SlidableAction(
            onPressed: (_) => onSendMessage(),
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
            icon: Icons.message,
            label: 'Message',
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                Row(
                  children: [
                    // Profile Photo
                    Stack(
                      children: [
                        Container(
                          width: 15.w,
                          height: 15.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCheckedIn
                                  ? Colors.green.shade600
                                  : theme.colorScheme.outline,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: CustomImageWidget(
                              imageUrl: staff['profilePhoto'] as String,
                              width: 15.w,
                              height: 15.w,
                              fit: BoxFit.cover,
                              semanticLabel: staff['semanticLabel'] as String,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: Container(
                              width: 5.w,
                              height: 5.w,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: theme.colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 3.w,
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    SizedBox(width: 3.w),

                    // Staff Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            staff['name'] as String,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  staff['role'] as String,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 2.w,
                                  vertical: 0.5.h,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.secondary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  staff['department'] as String,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: theme.colorScheme.secondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Status Indicator
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isCheckedIn
                                ? Colors.green.shade50
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 2.w,
                                height: 2.w,
                                decoration: BoxDecoration(
                                  color: isCheckedIn
                                      ? Colors.green.shade600
                                      : Colors.grey.shade400,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                isCheckedIn ? 'In' : 'Out',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: isCheckedIn
                                      ? Colors.green.shade700
                                      : Colors.grey.shade700,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          staff['checkInTime'] as String,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                SizedBox(height: 2.h),

                // Hours and Wage Info
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoItem(
                        context,
                        icon: 'schedule',
                        label: 'Hours Today',
                        value: '${staff['hoursWorked']}h',
                      ),
                      Container(
                        width: 1,
                        height: 4.h,
                        color: theme.colorScheme.outline.withValues(alpha: 0.2),
                      ),
                      _buildInfoItem(
                        context,
                        icon: 'attach_money',
                        label: 'Wage Type',
                        value: _getWageTypeDisplay(staff),
                      ),
                      if (staff['wageType'] == 'piece-rate') ...[
                        Container(
                          width: 1,
                          height: 4.h,
                          color:
                              theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
                        _buildInfoItem(
                          context,
                          icon: 'inventory',
                          label: 'Units',
                          value: staff['unitsCompleted'] as String? ?? '0',
                        ),
                      ],
                    ],
                  ),
                ),

                // Quick Actions
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onMarkAttendance,
                        icon: Icon(
                          isCheckedIn ? Icons.logout : Icons.login,
                          size: 4.w,
                        ),
                        label: Text(
                          isCheckedIn ? 'Check Out' : 'Check In',
                          style: theme.textTheme.labelMedium,
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          side: BorderSide(
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onViewTimesheet,
                        icon: Icon(
                          Icons.calendar_today,
                          size: 4.w,
                        ),
                        label: Text(
                          'Timesheet',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
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

  Widget _buildInfoItem(
    BuildContext context, {
    required String icon,
    required String label,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        children: [
          CustomIconWidget(
            iconName: icon,
            color: theme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(height: 0.5.h),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 0.25.h),
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getWageTypeDisplay(Map<String, dynamic> staff) {
    final wageType = staff['wageType'] as String;
    switch (wageType) {
      case 'hourly':
        return staff['hourlyRate'] as String? ?? '\$0/hr';
      case 'daily':
        return staff['dailyRate'] as String? ?? '\$0/day';
      case 'piece-rate':
        return staff['pieceRate'] as String? ?? '\$0/unit';
      default:
        return 'N/A';
    }
  }
}
