import 'package:flutter/material.dart';
import '../core/app_notification.dart';
import 'notification_service.dart';

class AppNotifications {
  static void show(BuildContext context, AppNotification notification) {
    NotificationService.show(
      context,
      message: notification.message,
      color: _getColor(notification.type),
      duration: notification.duration,
    );
  }

  static Color _getColor(AppNotificationType type) {
    switch (type) {
      case AppNotificationType.payment:
        return const Color(0xFF16A34A); // modern green
      case AppNotificationType.security:
        return const Color(0xFFDC2626); // strong red
      case AppNotificationType.inventory:
        return const Color(0xFFF59E0B); // amber
      case AppNotificationType.employee:
        return const Color.fromARGB(
            255, 163, 31, 42); // cyan (better than random)
      default:
        return Colors.grey;
    }
  }
}
