import 'package:flutter/material.dart';
import '../presentation/business_dashboard/widgets/app_notification_widget.dart';
import '../main.dart';

class NotificationService {
  static final List<_NotificationItem> _queue = [];
  static bool _isShowing = false;

  static void show(
    BuildContext context, {
    required String message,
    required Color color,
    Duration duration = const Duration(seconds: 5),
  }) {
    _queue.add(
      _NotificationItem(
        message: message,
        color: color,
        duration: duration,
      ),
    );

    _processQueue();
  }

  static void _processQueue() {
    if (_isShowing || _queue.isEmpty) return;

    _isShowing = true;

    final item = _queue.removeAt(0);

    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 20,
        right: 20,
        child: AppNotificationWidget(
          message: item.message,
          color: item.color,
          duration: item.duration,
          onDismiss: () {
            entry.remove();
            _isShowing = false;

            Future.delayed(const Duration(milliseconds: 7000), () {
              _processQueue();
            });
          },
        ),
      ),
    );

    overlayState.insert(entry);
  }
}

class _NotificationItem {
  final String message;
  final Color color;
  final Duration duration;

  _NotificationItem({
    required this.message,
    required this.color,
    required this.duration,
  });
}
