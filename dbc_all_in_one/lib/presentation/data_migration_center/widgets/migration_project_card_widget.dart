import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import './migration_progress_widget.dart';

class MigrationProjectCardWidget extends StatelessWidget {
  final Map<String, dynamic> project;
  final VoidCallback onTap;
  final VoidCallback onRefresh;

  const MigrationProjectCardWidget({
    super.key,
    required this.project,
    required this.onTap,
    required this.onRefresh,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'importing':
        return const Color(0xFF2196F3);
      case 'validating':
        return const Color(0xFFFF9800);
      case 'failed':
        return const Color(0xFFF44336);
      default:
        return Colors.grey;
    }
  }

  IconData _getSourceIcon(String sourceType) {
    switch (sourceType) {
      case 'quickbooks':
        return Icons.business;
      case 'tally':
        return Icons.account_balance;
      case 'sap':
        return Icons.warehouse;
      case 'excel':
        return Icons.table_chart;
      case 'zoho':
        return Icons.cloud;
      case 'freshbooks':
        return Icons.receipt_long;
      default:
        return Icons.source;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = project['status'] ?? 'draft';
    final sourceType = project['source_type'] ?? 'unknown';
    final totalRecords = project['total_records'] ?? 0;
    final processedRecords = project['processed_records'] ?? 0;
    final failedRecords = project['failed_records'] ?? 0;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(13),
              blurRadius: 10.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withAlpha(26),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Icon(_getSourceIcon(sourceType),
                        color: _getStatusColor(status), size: 24),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          project['project_name'] ?? 'Unnamed Project',
                          style: TextStyle(
                              fontSize: 13.sp, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          sourceType.toUpperCase(),
                          style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                    decoration: BoxDecoration(
                      color: _getStatusColor(status).withAlpha(26),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Text(
                      status.toUpperCase(),
                      style: TextStyle(
                          fontSize: 9.sp,
                          color: _getStatusColor(status),
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
            if (totalRecords > 0)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: MigrationProgressWidget(
                  totalRecords: totalRecords,
                  processedRecords: processedRecords,
                  failedRecords: failedRecords,
                ),
              ),
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.schedule, size: 16, color: Colors.grey),
                      SizedBox(width: 1.w),
                      Text(
                        'Started: ${_formatDate(project['started_at'])}',
                        style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (status == 'completed')
                        Icon(Icons.check_circle,
                            size: 16, color: const Color(0xFF4CAF50)),
                      if (status == 'failed')
                        Icon(Icons.error,
                            size: 16, color: const Color(0xFFF44336)),
                      if (status == 'importing')
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                _getStatusColor(status)),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'Not started';
    try {
      final DateTime dateTime = DateTime.parse(date.toString());
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return 'Invalid date';
    }
  }
}
