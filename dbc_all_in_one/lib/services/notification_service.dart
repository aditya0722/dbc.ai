import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all notifications for current user with optional filters
  Future<List<Map<String, dynamic>>> fetchNotifications({
    String? typeFilter,
    bool? isRead,
    bool includeArchived = false,
  }) async {
    try {
      var query = _supabase
          .from('notifications')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id);

      if (typeFilter != null && typeFilter != 'All') {
        query = query.eq('notification_type', typeFilter.toLowerCase());
      }

      if (isRead != null) {
        query = query.eq('is_read', isRead);
      }

      if (!includeArchived) {
        query = query.eq('is_archived', false);
      }

      final response = await query.order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch notifications: $e');
    }
  }

  /// Get unread notification count
  Future<int> getUnreadCount() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase.rpc(
        'get_unread_notification_count',
        params: {'target_user_id': userId},
      );
      return response as int;
    } catch (e) {
      throw Exception('Failed to get unread count: $e');
    }
  }

  /// Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase.rpc(
        'mark_notifications_as_read',
        params: {
          'notification_ids': [notificationId]
        },
      );
    } catch (e) {
      throw Exception('Failed to mark notification as read: $e');
    }
  }

  /// Mark multiple notifications as read
  Future<void> markMultipleAsRead(List<String> notificationIds) async {
    try {
      await _supabase.rpc(
        'mark_notifications_as_read',
        params: {'notification_ids': notificationIds},
      );
    } catch (e) {
      throw Exception('Failed to mark notifications as read: $e');
    }
  }

  /// Archive notification
  Future<void> archiveNotification(String notificationId) async {
    try {
      await _supabase.rpc(
        'archive_notifications',
        params: {
          'notification_ids': [notificationId]
        },
      );
    } catch (e) {
      throw Exception('Failed to archive notification: $e');
    }
  }

  /// Archive multiple notifications
  Future<void> archiveMultiple(List<String> notificationIds) async {
    try {
      await _supabase.rpc(
        'archive_notifications',
        params: {'notification_ids': notificationIds},
      );
    } catch (e) {
      throw Exception('Failed to archive notifications: $e');
    }
  }

  /// Delete notification permanently
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }

  /// Search notifications by keyword
  Future<List<Map<String, dynamic>>> searchNotifications(String keyword) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id)
          .eq('is_archived', false)
          .or('title.ilike.%$keyword%,message.ilike.%$keyword%')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to search notifications: $e');
    }
  }

  /// Create manual notification
  Future<void> createNotification({
    required String userId,
    required String type,
    required String priority,
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? actionData,
  }) async {
    try {
      await _supabase.from('notifications').insert({
        'user_id': userId,
        'notification_type': type,
        'priority': priority,
        'title': title,
        'message': message,
        'action_url': actionUrl,
        'action_data': actionData,
      });
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  /// Subscribe to real-time notification updates
  RealtimeChannel subscribeToNotifications(
    Function(Map<String, dynamic>) onNotification,
  ) {
    final userId = _supabase.auth.currentUser!.id;

    return _supabase
        .channel('notifications:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            onNotification(payload.newRecord);
          },
        )
        .subscribe();
  }

  /// Fetch notification preferences for current user
  Future<Map<String, dynamic>?> getNotificationPreferences() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase
          .from('notification_preferences')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      return response;
    } catch (e) {
      throw Exception('Failed to fetch notification preferences: $e');
    }
  }

  /// Update notification preferences
  Future<void> updateNotificationPreferences(
      Map<String, dynamic> preferences) async {
    try {
      final userId = _supabase.auth.currentUser!.id;

      await _supabase.from('notification_preferences').upsert({
        'user_id': userId,
        ...preferences,
      }, onConflict: 'user_id');
    } catch (e) {
      throw Exception('Failed to update notification preferences: $e');
    }
  }

  /// Update quiet hours settings
  Future<void> updateQuietHours({
    required bool enabled,
    required String startTime,
    required String endTime,
  }) async {
    try {
      await updateNotificationPreferences({
        'quiet_hours_enabled': enabled,
        'quiet_hours_start': startTime,
        'quiet_hours_end': endTime,
      });
    } catch (e) {
      throw Exception('Failed to update quiet hours: $e');
    }
  }

  /// Update priority preferences
  Future<void> updatePriorityPreferences({
    required bool enableLow,
    required bool enableMedium,
    required bool enableHigh,
    required bool enableCritical,
  }) async {
    try {
      await updateNotificationPreferences({
        'enable_low_priority': enableLow,
        'enable_medium_priority': enableMedium,
        'enable_high_priority': enableHigh,
        'enable_critical_priority': enableCritical,
      });
    } catch (e) {
      throw Exception('Failed to update priority preferences: $e');
    }
  }

  /// Update delivery method for specific notification type
  Future<void> updateDeliveryMethod(
      String notificationType, String deliveryMethod) async {
    try {
      await updateNotificationPreferences({
        '${notificationType.toLowerCase()}_delivery': deliveryMethod,
      });
    } catch (e) {
      throw Exception('Failed to update delivery method: $e');
    }
  }

  /// Update history management settings
  Future<void> updateHistorySettings({
    required int autoArchiveDays,
    required int autoDeleteArchivedDays,
  }) async {
    try {
      await updateNotificationPreferences({
        'auto_archive_days': autoArchiveDays,
        'auto_delete_archived_days': autoDeleteArchivedDays,
      });
    } catch (e) {
      throw Exception('Failed to update history settings: $e');
    }
  }

  /// Check if current time is within quiet hours for user
  Future<bool> isWithinQuietHours() async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final response = await _supabase.rpc(
        'is_within_quiet_hours',
        params: {'user_uuid': userId},
      );
      return response as bool;
    } catch (e) {
      throw Exception('Failed to check quiet hours: $e');
    }
  }

  /// Manually trigger auto-archive for old notifications
  Future<void> triggerAutoArchive() async {
    try {
      await _supabase.rpc('auto_archive_old_notifications');
    } catch (e) {
      throw Exception('Failed to trigger auto-archive: $e');
    }
  }

  /// Manually trigger auto-delete for old archived notifications
  Future<void> triggerAutoDelete() async {
    try {
      await _supabase.rpc('auto_delete_archived_notifications');
    } catch (e) {
      throw Exception('Failed to trigger auto-delete: $e');
    }
  }
}