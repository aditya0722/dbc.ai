import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';


class DateRangeSelectorWidget extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime?, DateTime?) onDateRangeSelected;

  const DateRangeSelectorWidget({
    super.key,
    this.startDate,
    this.endDate,
    required this.onDateRangeSelected,
  });

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: startDate != null && endDate != null
          ? DateTimeRange(start: startDate!, end: endDate!)
          : null,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).primaryColor,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onDateRangeSelected(picked.start, picked.end);
    }
  }

  void _clearDateRange() {
    onDateRangeSelected(null, null);
  }

  @override
  Widget build(BuildContext context) {
    final hasDateRange = startDate != null && endDate != null;

    return GestureDetector(
      onTap: () => _selectDateRange(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(2.w),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              size: 5.w,
              color: Theme.of(context).primaryColor,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                hasDateRange
                    ? '${DateFormat('MMM dd, yyyy').format(startDate!)} - ${DateFormat('MMM dd, yyyy').format(endDate!)}'
                    : 'Select date range',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: hasDateRange ? Colors.black87 : Colors.grey,
                ),
              ),
            ),
            if (hasDateRange)
              GestureDetector(
                onTap: _clearDateRange,
                child: Icon(
                  Icons.close,
                  size: 5.w,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
