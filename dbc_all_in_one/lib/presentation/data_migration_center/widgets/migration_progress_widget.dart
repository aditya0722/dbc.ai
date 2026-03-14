import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class MigrationProgressWidget extends StatelessWidget {
  final int totalRecords;
  final int processedRecords;
  final int failedRecords;

  const MigrationProgressWidget({
    super.key,
    required this.totalRecords,
    required this.processedRecords,
    required this.failedRecords,
  });

  @override
  Widget build(BuildContext context) {
    final progressPercent =
        totalRecords > 0 ? (processedRecords / totalRecords * 100).toInt() : 0;
    final remainingRecords = totalRecords - processedRecords;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Migration Progress',
                style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600)),
            Text('$progressPercent%',
                style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2196F3))),
          ],
        ),
        SizedBox(height: 1.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.0),
          child: LinearProgressIndicator(
            value: totalRecords > 0 ? processedRecords / totalRecords : 0,
            backgroundColor: Colors.grey.shade200,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2196F3)),
            minHeight: 8,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ProgressStat(
              icon: Icons.check_circle_outline,
              label: 'Processed',
              value: processedRecords.toString(),
              color: const Color(0xFF4CAF50),
            ),
            _ProgressStat(
              icon: Icons.pending_outlined,
              label: 'Remaining',
              value: remainingRecords.toString(),
              color: const Color(0xFFFF9800),
            ),
            _ProgressStat(
              icon: Icons.error_outline,
              label: 'Failed',
              value: failedRecords.toString(),
              color: const Color(0xFFF44336),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ProgressStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        SizedBox(width: 1.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: color)),
            Text(label, style: TextStyle(fontSize: 9.sp, color: Colors.grey)),
          ],
        ),
      ],
    );
  }
}
