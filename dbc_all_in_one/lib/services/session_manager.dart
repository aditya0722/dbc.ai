import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Session Manager - Manages app session state for one-time notifications
///
/// Purpose: Track unique app sessions to show alerts once per login/session
/// rather than once forever. Each app launch = new session.
class SessionManager {
  static final SessionManager _instance = SessionManager._internal();
  factory SessionManager() => _instance;
  SessionManager._internal();

  String? _currentSessionId;
  static const String _sessionIdKey = 'current_session_id';
  static const String _alertShownInSessionKey = 'alert_shown_in_session';

  /// Initialize a new session (call on app start)
  Future<void> initializeSession() async {
    // Generate unique session ID based on timestamp
    _currentSessionId = DateTime.now().millisecondsSinceEpoch.toString();

    final prefs = await SharedPreferences.getInstance();

    // Clear previous session's alert flag
    await prefs.remove(_alertShownInSessionKey);

    // Store current session ID
    await prefs.setString(_sessionIdKey, _currentSessionId!);

    if (kDebugMode) {
      print('📱 New session initialized: $_currentSessionId');
    }
  }

  /// Check if alert was shown in current session
  Future<bool> wasAlertShownInCurrentSession() async {
    final prefs = await SharedPreferences.getInstance();
    final shownInSession = prefs.getString(_alertShownInSessionKey);

    return shownInSession == _currentSessionId;
  }

  /// Mark alert as shown for current session
  Future<void> markAlertAsShown() async {
    if (_currentSessionId == null) {
      if (kDebugMode) {
        print('⚠️ Session not initialized, initializing now...');
      }
      await initializeSession();
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_alertShownInSessionKey, _currentSessionId!);

    if (kDebugMode) {
      print('✅ Alert marked as shown for session: $_currentSessionId');
    }
  }

  /// Get current session ID
  String? get currentSessionId => _currentSessionId;

  /// Clear session data (call on logout if needed)
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionIdKey);
    await prefs.remove(_alertShownInSessionKey);
    _currentSessionId = null;

    if (kDebugMode) {
      print('🧹 Session data cleared');
    }
  }
}
