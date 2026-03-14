import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class ApplicationStatusChipWidget extends StatelessWidget {
  final String status;

  const ApplicationStatusChipWidget({
    Key? key,
    required this.status,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final statusConfig = _getStatusConfig(status);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: statusConfig['color'].withAlpha(38),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            statusConfig['icon'],
            size: 14.sp,
            color: statusConfig['color'],
          ),
          SizedBox(width: 4.w),
          Text(
            statusConfig['label'],
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: statusConfig['color'],
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getStatusConfig(String status) {
    final Map<String, Map<String, dynamic>> configs = {
      'pending': {
        'label': 'Pending',
        'icon': Icons.schedule,
        'color': Colors.orange,
      },
      'reviewing': {
        'label': 'Reviewing',
        'icon': Icons.visibility,
        'color': Colors.blue,
      },
      'shortlisted': {
        'label': 'Shortlisted',
        'icon': Icons.star,
        'color': Colors.green,
      },
      'rejected': {
        'label': 'Rejected',
        'icon': Icons.close,
        'color': Colors.red,
      },
      'hired': {
        'label': 'Hired',
        'icon': Icons.check_circle,
        'color': Colors.teal,
      },
    };

    return configs[status] ??
        {
          'label': status,
          'icon': Icons.help_outline,
          'color': Colors.grey,
        };
  }
}
