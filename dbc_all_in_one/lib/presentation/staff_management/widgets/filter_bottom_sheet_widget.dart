import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FilterBottomSheetWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const FilterBottomSheetWidget({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<FilterBottomSheetWidget> createState() =>
      _FilterBottomSheetWidgetState();
}

class _FilterBottomSheetWidgetState extends State<FilterBottomSheetWidget> {
  String? _selectedDepartment;
  String? _selectedEmploymentType;
  String? _selectedAttendanceStatus;
  String? _selectedPayPeriod;

  final List<String> _departments = [
    'All',
    'Front',
    'Kitchen',
    'Rooms',
    'Floor',
    'Production',
    'Gym'
  ];

  final List<String> _employmentTypes = [
    'All',
    'Hourly',
    'Daily Fixed',
    'Piece Rate'
  ];

  final List<String> _attendanceStatuses = ['All', 'Checked In', 'Checked Out'];

  final List<String> _payPeriods = [
    'Today',
    'This Week',
    'This Month',
    'Custom'
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle Bar
            Container(
              margin: EdgeInsets.only(top: 2.h),
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color:
                    theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Title
            Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter Staff',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedDepartment = null;
                        _selectedEmploymentType = null;
                        _selectedAttendanceStatus = null;
                        _selectedPayPeriod = null;
                      });
                    },
                    child: Text(
                      'Reset',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(
                height: 1,
                color: theme.colorScheme.outline.withValues(alpha: 0.2)),

            // Filter Options
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFilterSection(
                      context,
                      title: 'Department',
                      options: _departments,
                      selectedValue: _selectedDepartment,
                      onChanged: (value) =>
                          setState(() => _selectedDepartment = value),
                    ),
                    SizedBox(height: 3.h),
                    _buildFilterSection(
                      context,
                      title: 'Employment Type',
                      options: _employmentTypes,
                      selectedValue: _selectedEmploymentType,
                      onChanged: (value) =>
                          setState(() => _selectedEmploymentType = value),
                    ),
                    SizedBox(height: 3.h),
                    _buildFilterSection(
                      context,
                      title: 'Attendance Status',
                      options: _attendanceStatuses,
                      selectedValue: _selectedAttendanceStatus,
                      onChanged: (value) =>
                          setState(() => _selectedAttendanceStatus = value),
                    ),
                    SizedBox(height: 3.h),
                    _buildFilterSection(
                      context,
                      title: 'Pay Period',
                      options: _payPeriods,
                      selectedValue: _selectedPayPeriod,
                      onChanged: (value) =>
                          setState(() => _selectedPayPeriod = value),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: EdgeInsets.all(4.w),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApplyFilters({
                      'department': _selectedDepartment,
                      'employmentType': _selectedEmploymentType,
                      'attendanceStatus': _selectedAttendanceStatus,
                      'payPeriod': _selectedPayPeriod,
                    });
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterSection(
    BuildContext context, {
    required String title,
    required List<String> options,
    required String? selectedValue,
    required Function(String?) onChanged,
  }) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: options.map((option) {
            final isSelected = selectedValue == option;
            return GestureDetector(
              onTap: () => onChanged(option),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.colorScheme.outline,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  option,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
