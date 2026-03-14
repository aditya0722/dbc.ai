import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../../services/security_alerts_service.dart';

class AlertCardWidget extends StatelessWidget {
  final Map<String, dynamic> alert;
  final Color severityColor;
  final VoidCallback onStatusChange;

  const AlertCardWidget({
    super.key,
    required this.alert,
    required this.severityColor,
    required this.onStatusChange,
  });

  String _formatDateTime(String? dateTimeStr) {
    if (dateTimeStr == null) return 'N/A';
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'active':
        return 'Active';
      case 'investigating':
        return 'Investigating';
      case 'resolved':
        return 'Resolved';
      case 'false_alarm':
        return 'False Alarm';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'active':
        return Colors.red;
      case 'investigating':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'false_alarm':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Future<void> _updateStatus(BuildContext context, String newStatus) async {
    try {
      final service = SecurityAlertsService();
      await service.updateAlertStatus(alertId: alert['id'], status: newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Alert status updated successfully')),
        );
      }
      onStatusChange();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Alert Status'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.circle, color: Colors.red),
                  title: const Text('Active'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(context, 'active');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.circle, color: Colors.orange),
                  title: const Text('Investigating'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(context, 'investigating');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.circle, color: Colors.green),
                  title: const Text('Resolved'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(context, 'resolved');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.circle, color: Colors.grey),
                  title: const Text('False Alarm'),
                  onTap: () {
                    Navigator.pop(context);
                    _updateStatus(context, 'false_alarm');
                  },
                ),
              ],
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reportedBy = alert['reported_by_profile'];
    final reporterName = reportedBy?['full_name'] ?? 'Unknown User';
    final amountStolen = alert['amount_stolen'];
    final location = alert['location'] ?? 'Not specified';

    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: severityColor, width: 2),
      ),
      child: InkWell(
        onTap: () => _showStatusDialog(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: severityColor.withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      alert['severity'].toString().toUpperCase(),
                      style: TextStyle(
                        color: severityColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(alert['status']).withAlpha(51),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _getStatusLabel(alert['status']),
                      style: TextStyle(
                        color: _getStatusColor(alert['status']),
                        fontWeight: FontWeight.w600,
                        fontSize: 11.sp,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.warning_amber_rounded,
                    color: severityColor,
                    size: 24,
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                alert['title'] ?? 'Untitled Alert',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                alert['description'] ?? 'No description available',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      location,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                ],
              ),
              if (amountStolen != null) ...[
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: Colors.red.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'Amount: \$${amountStolen.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ],
              SizedBox(height: 12.h),
              Divider(color: Colors.grey.shade300),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey.shade600),
                  SizedBox(width: 4.w),
                  Text(
                    'Reported by: $reporterName',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatDateTime(alert['incident_time']),
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
