import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class NotificationCardWidget extends StatelessWidget {
  final Map<String, dynamic> notification;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final VoidCallback onMarkRead;
  final VoidCallback onArchive;

  const NotificationCardWidget({
    Key? key,
    required this.notification,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    required this.onMarkRead,
    required this.onArchive,
  }) : super(key: key);

  Color _getPriorityColor() {
    switch (notification['priority']) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.blue;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon() {
    switch (notification['notification_type']) {
      case 'security':
        return Icons.security;
      case 'inventory':
        return Icons.inventory;
      case 'staff':
        return Icons.people;
      case 'orders':
        return Icons.shopping_cart;
      case 'system':
        return Icons.settings;
      case 'gst':
        return Icons.account_balance;
      case 'payroll':
        return Icons.payments;
      case 'hiring':
        return Icons.work;
      case 'marketplace':
        return Icons.store;
      default:
        return Icons.notifications;
    }
  }

  String _formatTimestamp(String? timestamp) {
    if (timestamp == null) return '';
    try {
      final date = DateTime.parse(timestamp);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inHours < 1) {
        return '${difference.inMinutes}m ago';
      } else if (difference.inDays < 1) {
        return '${difference.inHours}h ago';
      } else if (difference.inDays < 7) {
        return '${difference.inDays}d ago';
      } else {
        return DateFormat('MMM dd, yyyy').format(date);
      }
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRead = notification['is_read'] ?? false;

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: EdgeInsets.only(bottom: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withAlpha(26)
              : (isRead ? Colors.white : Colors.blue[50]),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: isSelected
                ? Colors.blue
                : (isRead ? Colors.grey[300]! : Colors.blue[100]!),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selection checkbox or type icon
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: _getPriorityColor().withAlpha(26),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : Icon(_getTypeIcon(),
                        color: _getPriorityColor(), size: 18.sp),
              ),
              SizedBox(width: 3.w),

              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'] ?? 'Notification',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight:
                                  isRead ? FontWeight.w500 : FontWeight.w600,
                              color: Colors.grey[900],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 2.w,
                            height: 2.w,
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      notification['message'] ?? '',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _formatTimestamp(notification['created_at']),
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[500],
                          ),
                        ),
                        Row(
                          children: [
                            if (!isRead)
                              GestureDetector(
                                onTap: onMarkRead,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 2.w,
                                    vertical: 0.5.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(6.0),
                                  ),
                                  child: Text(
                                    'Mark Read',
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(width: 2.w),
                            GestureDetector(
                              onTap: onArchive,
                              child: Icon(
                                Icons.archive_outlined,
                                size: 16.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
