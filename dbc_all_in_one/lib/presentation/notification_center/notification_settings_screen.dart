import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/notification_service.dart';
import '../../widgets/custom_app_bar.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = true;

  // Quiet hours
  bool _quietHoursEnabled = false;
  TimeOfDay _quietHoursStart = const TimeOfDay(hour: 22, minute: 0);
  TimeOfDay _quietHoursEnd = const TimeOfDay(hour: 7, minute: 0);

  // Priority preferences
  bool _enableLow = true;
  bool _enableMedium = true;
  bool _enableHigh = true;
  bool _enableCritical = true;

  // Delivery methods
  final Map<String, String> _deliveryMethods = {};

  // History management
  int _autoArchiveDays = 30;
  int _autoDeleteDays = 90;

  final List<String> _notificationTypes = [
    'security',
    'inventory',
    'staff',
    'orders',
    'system',
    'gst',
    'payroll',
    'hiring',
    'marketplace'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await _notificationService.getNotificationPreferences();

      if (prefs != null) {
        setState(() {
          _quietHoursEnabled = prefs['quiet_hours_enabled'] ?? false;
          _quietHoursStart = _parseTime(prefs['quiet_hours_start']);
          _quietHoursEnd = _parseTime(prefs['quiet_hours_end']);

          _enableLow = prefs['enable_low_priority'] ?? true;
          _enableMedium = prefs['enable_medium_priority'] ?? true;
          _enableHigh = prefs['enable_high_priority'] ?? true;
          _enableCritical = prefs['enable_critical_priority'] ?? true;

          for (var type in _notificationTypes) {
            _deliveryMethods[type] = prefs['${type}_delivery'] ?? 'push';
          }

          _autoArchiveDays = prefs['auto_archive_days'] ?? 30;
          _autoDeleteDays = prefs['auto_delete_archived_days'] ?? 90;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading preferences: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String? timeString) {
    if (timeString == null) return const TimeOfDay(hour: 22, minute: 0);
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  Future<void> _saveQuietHours() async {
    try {
      await _notificationService.updateQuietHours(
        enabled: _quietHoursEnabled,
        startTime: _formatTimeOfDay(_quietHoursStart),
        endTime: _formatTimeOfDay(_quietHoursEnd),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Quiet hours updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _savePriorityPreferences() async {
    try {
      await _notificationService.updatePriorityPreferences(
        enableLow: _enableLow,
        enableMedium: _enableMedium,
        enableHigh: _enableHigh,
        enableCritical: _enableCritical,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Priority preferences updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  Future<void> _saveHistorySettings() async {
    try {
      await _notificationService.updateHistorySettings(
        autoArchiveDays: _autoArchiveDays,
        autoDeleteArchivedDays: _autoDeleteDays,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('History settings updated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Notification Settings'),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const CustomAppBar(title: 'Notification Settings'),
      body: ListView(
        padding: EdgeInsets.all(3.w),
        children: [
          // Quiet Hours Section
          _buildSectionCard(
            title: 'Quiet Hours',
            icon: Icons.bedtime,
            children: [
              SwitchListTile(
                title: const Text('Enable Quiet Hours'),
                subtitle:
                    const Text('Mute notifications during specific hours'),
                value: _quietHoursEnabled,
                onChanged: (value) {
                  setState(() => _quietHoursEnabled = value);
                  _saveQuietHours();
                },
              ),
              if (_quietHoursEnabled) ...[
                ListTile(
                  title: const Text('Start Time'),
                  trailing: Text(
                    _quietHoursStart.format(context),
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _quietHoursStart,
                    );
                    if (time != null) {
                      setState(() => _quietHoursStart = time);
                      _saveQuietHours();
                    }
                  },
                ),
                ListTile(
                  title: const Text('End Time'),
                  trailing: Text(
                    _quietHoursEnd.format(context),
                    style:
                        TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
                  ),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _quietHoursEnd,
                    );
                    if (time != null) {
                      setState(() => _quietHoursEnd = time);
                      _saveQuietHours();
                    }
                  },
                ),
              ],
            ],
          ),

          SizedBox(height: 2.h),

          // Alert Priorities Section
          _buildSectionCard(
            title: 'Alert Priorities',
            icon: Icons.priority_high,
            children: [
              SwitchListTile(
                title: const Text('Low Priority'),
                value: _enableLow,
                onChanged: (value) {
                  setState(() => _enableLow = value);
                  _savePriorityPreferences();
                },
              ),
              SwitchListTile(
                title: const Text('Medium Priority'),
                value: _enableMedium,
                onChanged: (value) {
                  setState(() => _enableMedium = value);
                  _savePriorityPreferences();
                },
              ),
              SwitchListTile(
                title: const Text('High Priority'),
                value: _enableHigh,
                onChanged: (value) {
                  setState(() => _enableHigh = value);
                  _savePriorityPreferences();
                },
              ),
              SwitchListTile(
                title: const Text('Critical Priority'),
                value: _enableCritical,
                onChanged: (value) {
                  setState(() => _enableCritical = value);
                  _savePriorityPreferences();
                },
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Delivery Methods Section
          _buildSectionCard(
            title: 'Delivery Methods',
            icon: Icons.notifications_active,
            children: _notificationTypes.map((type) {
              return ListTile(
                title: Text(_formatNotificationType(type)),
                trailing: DropdownButton<String>(
                  value: _deliveryMethods[type] ?? 'push',
                  items: const [
                    DropdownMenuItem(value: 'push', child: Text('Push')),
                    DropdownMenuItem(value: 'email', child: Text('Email')),
                    DropdownMenuItem(value: 'sms', child: Text('SMS')),
                    DropdownMenuItem(value: 'all', child: Text('All')),
                  ],
                  onChanged: (value) async {
                    if (value != null) {
                      setState(() => _deliveryMethods[type] = value);
                      try {
                        await _notificationService.updateDeliveryMethod(
                            type, value);
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(
                                    '${_formatNotificationType(type)} delivery updated')),
                          );
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to update: $e')),
                          );
                        }
                      }
                    }
                  },
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 2.h),

          // History Management Section
          _buildSectionCard(
            title: 'History Management',
            icon: Icons.history,
            children: [
              ListTile(
                title: const Text('Auto-archive after'),
                subtitle: Text('$_autoArchiveDays days'),
                trailing: SizedBox(
                  width: 30.w,
                  child: Slider(
                    value: _autoArchiveDays.toDouble(),
                    min: 7,
                    max: 90,
                    divisions: 11,
                    label: '$_autoArchiveDays days',
                    onChanged: (value) {
                      setState(() => _autoArchiveDays = value.round());
                    },
                    onChangeEnd: (value) {
                      _saveHistorySettings();
                    },
                  ),
                ),
              ),
              ListTile(
                title: const Text('Auto-delete archived after'),
                subtitle: Text('$_autoDeleteDays days'),
                trailing: SizedBox(
                  width: 30.w,
                  child: Slider(
                    value: _autoDeleteDays.toDouble(),
                    min: 30,
                    max: 180,
                    divisions: 10,
                    label: '$_autoDeleteDays days',
                    onChanged: (value) {
                      setState(() => _autoDeleteDays = value.round());
                    },
                    onChangeEnd: (value) {
                      _saveHistorySettings();
                    },
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: ElevatedButton.icon(
                  onPressed: () async {
                    try {
                      await _notificationService.triggerAutoArchive();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Auto-archive triggered')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed: $e')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.archive),
                  label: const Text('Archive Old Notifications Now'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 1.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Row(
              children: [
                Icon(icon, color: Colors.blue[700]),
                SizedBox(width: 2.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }

  String _formatNotificationType(String type) {
    return type[0].toUpperCase() + type.substring(1).replaceAll('_', ' ');
  }
}
