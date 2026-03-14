import './supabase_service.dart';

class SecurityAlertsService {
  final _supabase = SupabaseService.instance.client;

  /// Fetch all security alerts with optional filtering
  Future<List<Map<String, dynamic>>> getSecurityAlerts({
    String? status,
    String? severity,
    int? limit,
  }) async {
    try {
      dynamic query = _supabase.from('security_alerts').select('''
            *,
            reported_by_profile:user_profiles!security_alerts_reported_by_fkey(
              id, full_name, email, avatar_url
            ),
            assigned_to_profile:user_profiles!security_alerts_assigned_to_fkey(
              id, full_name, email, avatar_url
            )
          ''');

      if (status != null) {
        query = query.eq('status', status);
      }

      if (severity != null) {
        query = query.eq('severity', severity);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query.order('incident_time', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch security alerts: $e');
    }
  }

  /// Get active security alerts (active + investigating)
  Future<List<Map<String, dynamic>>> getActiveAlerts() async {
    try {
      final response = await _supabase.from('security_alerts').select('''
            *,
            reported_by_profile:user_profiles!security_alerts_reported_by_fkey(
              id, full_name, email
            )
          ''').inFilter('status', [
        'active',
        'investigating'
      ]).order('incident_time', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch active alerts: $e');
    }
  }

  /// Get count of active security alerts
  Future<int> getActiveAlertsCount() async {
    try {
      final response = await _supabase.rpc('get_active_security_alerts_count');
      return response as int;
    } catch (e) {
      throw Exception('Failed to get active alerts count: $e');
    }
  }

  /// Create a new security alert
  Future<Map<String, dynamic>> createSecurityAlert({
    required String alertType,
    required String severity,
    required String title,
    required String description,
    String? location,
    double? amountStolen,
    String? assignedTo,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final alertData = {
        'alert_type': alertType,
        'severity': severity,
        'title': title,
        'description': description,
        'location': location,
        'amount_stolen': amountStolen,
        'reported_by': userId,
        'assigned_to': assignedTo,
        'incident_time': DateTime.now().toIso8601String(),
      };

      final response = await _supabase
          .from('security_alerts')
          .insert(alertData)
          .select()
          .single();

      return response;
    } catch (e) {
      throw Exception('Failed to create security alert: $e');
    }
  }

  /// Update security alert status
  Future<void> updateAlertStatus({
    required String alertId,
    required String status,
    String? notes,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (notes != null) {
        updateData['notes'] = notes;
      }

      if (status == 'resolved') {
        updateData['resolved_at'] = DateTime.now().toIso8601String();
      }

      await _supabase
          .from('security_alerts')
          .update(updateData)
          .eq('id', alertId);
    } catch (e) {
      throw Exception('Failed to update alert status: $e');
    }
  }

  /// Assign alert to a user
  Future<void> assignAlert({
    required String alertId,
    required String assignedToId,
  }) async {
    try {
      await _supabase.from('security_alerts').update({
        'assigned_to': assignedToId,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', alertId);
    } catch (e) {
      throw Exception('Failed to assign alert: $e');
    }
  }

  /// Delete a security alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _supabase.from('security_alerts').delete().eq('id', alertId);
    } catch (e) {
      throw Exception('Failed to delete alert: $e');
    }
  }

  /// Stream real-time security alerts
  Stream<List<Map<String, dynamic>>> streamSecurityAlerts() {
    return _supabase
        .from('security_alerts')
        .stream(primaryKey: ['id'])
        .order('incident_time', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }
}
