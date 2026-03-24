

enum AppNotificationType {
  payment,
  security,
  inventory,
  employee,
}

class AppNotification {
  final String message;
  final AppNotificationType type;
  final Duration duration;

  AppNotification({
    required this.message,
    required this.type,
    this.duration = const Duration(seconds: 5),
  });
}