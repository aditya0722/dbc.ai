import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/security_alerts_service.dart';
import './widgets/alert_card_widget.dart';
import './widgets/severity_filter_chip_widget.dart';
import './widgets/status_filter_chip_widget.dart';

class SecurityAlertsDashboard extends StatefulWidget {
  const SecurityAlertsDashboard({super.key});

  @override
  State<SecurityAlertsDashboard> createState() =>
      _SecurityAlertsDashboardState();
}

class _SecurityAlertsDashboardState extends State<SecurityAlertsDashboard> {
  final SecurityAlertsService _alertsService = SecurityAlertsService();
  String? _selectedSeverity;
  String? _selectedStatus;
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final alerts = await _alertsService.getSecurityAlerts(
        severity: _selectedSeverity,
        status: _selectedStatus,
      );
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading alerts: $e')));
      }
    }
  }

  void _onSeverityFilterChanged(String? severity) {
    setState(() {
      _selectedSeverity = severity == _selectedSeverity ? null : severity;
    });
    _loadAlerts();
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _selectedStatus = status == _selectedStatus ? null : status;
    });
    _loadAlerts();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Security Alerts'),
        backgroundColor: Colors.red.shade700,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadAlerts),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16.0),
            color: Colors.grey.shade100,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter by Severity',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8,
                  children: [
                    SeverityFilterChipWidget(
                      label: 'Critical',
                      isSelected: _selectedSeverity == 'critical',
                      color: Colors.red,
                      onSelected: () => _onSeverityFilterChanged('critical'),
                    ),
                    SeverityFilterChipWidget(
                      label: 'High',
                      isSelected: _selectedSeverity == 'high',
                      color: Colors.orange,
                      onSelected: () => _onSeverityFilterChanged('high'),
                    ),
                    SeverityFilterChipWidget(
                      label: 'Medium',
                      isSelected: _selectedSeverity == 'medium',
                      color: Colors.amber,
                      onSelected: () => _onSeverityFilterChanged('medium'),
                    ),
                    SeverityFilterChipWidget(
                      label: 'Low',
                      isSelected: _selectedSeverity == 'low',
                      color: Colors.blue,
                      onSelected: () => _onSeverityFilterChanged('low'),
                    ),
                  ],
                ),
                SizedBox(height: 16.h),
                Text(
                  'Filter by Status',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 8,
                  children: [
                    StatusFilterChipWidget(
                      label: 'Active',
                      isSelected: _selectedStatus == 'active',
                      onSelected: () => _onStatusFilterChanged('active'),
                    ),
                    StatusFilterChipWidget(
                      label: 'Investigating',
                      isSelected: _selectedStatus == 'investigating',
                      onSelected: () => _onStatusFilterChanged('investigating'),
                    ),
                    StatusFilterChipWidget(
                      label: 'Resolved',
                      isSelected: _selectedStatus == 'resolved',
                      onSelected: () => _onStatusFilterChanged('resolved'),
                    ),
                    StatusFilterChipWidget(
                      label: 'False Alarm',
                      isSelected: _selectedStatus == 'false_alarm',
                      onSelected: () => _onStatusFilterChanged('false_alarm'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child:
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _alerts.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            'No security alerts found',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                    : RefreshIndicator(
                      onRefresh: _loadAlerts,
                      child: ListView.builder(
                        padding: EdgeInsets.all(16.w),
                        itemCount: _alerts.length,
                        itemBuilder: (context, index) {
                          final alert = _alerts[index];
                          return AlertCardWidget(
                            alert: alert,
                            severityColor: _getSeverityColor(alert['severity']),
                            onStatusChange: () => _loadAlerts(),
                          );
                        },
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
