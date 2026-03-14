import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class AdvancedFilterSheetWidget extends StatefulWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? statusFilter;
  final double? minAmount;
  final double? maxAmount;
  final Function(DateTime?, DateTime?, String?, double?, double?) onApply;
  final VoidCallback onClear;

  const AdvancedFilterSheetWidget({
    super.key,
    this.startDate,
    this.endDate,
    this.statusFilter,
    this.minAmount,
    this.maxAmount,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<AdvancedFilterSheetWidget> createState() =>
      _AdvancedFilterSheetWidgetState();
}

class _AdvancedFilterSheetWidgetState extends State<AdvancedFilterSheetWidget> {
  late DateTime? _startDate;
  late DateTime? _endDate;
  late String? _statusFilter;
  late double? _minAmount;
  late double? _maxAmount;

  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startDate = widget.startDate;
    _endDate = widget.endDate;
    _statusFilter = widget.statusFilter;
    _minAmount = widget.minAmount;
    _maxAmount = widget.maxAmount;

    if (_minAmount != null) _minAmountController.text = _minAmount.toString();
    if (_maxAmount != null) _maxAmountController.text = _maxAmount.toString();
  }

  @override
  void dispose() {
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDateRange() async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Header
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Advanced Filters',
                        style: TextStyle(
                            fontSize: 18.sp, fontWeight: FontWeight.w600),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        widget.onClear();
                        Navigator.pop(context);
                      },
                      child: const Text('Clear All'),
                    ),
                  ],
                ),
              ),

              // Filter Options
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  children: [
                    // Date Range Filter
                    Text('Date Range',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 1.h),
                    InkWell(
                      onTap: _selectDateRange,
                      child: Container(
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.date_range, color: Colors.grey[600]),
                            SizedBox(width: 2.w),
                            Expanded(
                              child: Text(
                                _startDate != null && _endDate != null
                                    ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                                    : 'Select date range',
                                style: TextStyle(
                                    fontSize: 14.sp,
                                    color: _startDate != null
                                        ? Colors.black
                                        : Colors.grey),
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios,
                                size: 16.0, color: Colors.grey[400]),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Status Filter
                    Text('Status',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: [
                        'draft',
                        'sent',
                        'paid',
                        'overdue',
                        'active',
                        'pending'
                      ].map((status) {
                        final isSelected = _statusFilter == status;
                        return FilterChip(
                          label: Text(status.toUpperCase()),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(
                                () => _statusFilter = selected ? status : null);
                          },
                          selectedColor: Colors.blue.withAlpha(51),
                          labelStyle: TextStyle(
                            fontSize: 12.sp,
                            color: isSelected ? Colors.blue : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),

                    SizedBox(height: 2.h),

                    // Amount Range Filter
                    Text('Amount Range',
                        style: TextStyle(
                            fontSize: 14.sp, fontWeight: FontWeight.w600)),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _minAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Min Amount',
                              labelStyle: TextStyle(fontSize: 12.sp),
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                            ),
                            onChanged: (value) {
                              _minAmount = double.tryParse(value);
                            },
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: TextField(
                            controller: _maxAmountController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Max Amount',
                              labelStyle: TextStyle(fontSize: 12.sp),
                              prefixText: '₹ ',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 3.w, vertical: 1.h),
                            ),
                            onChanged: (value) {
                              _maxAmount = double.tryParse(value);
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Apply Button
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  border: Border(top: BorderSide(color: Colors.grey[200]!)),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(_startDate, _endDate, _statusFilter,
                        _minAmount, _maxAmount);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    minimumSize: Size(double.infinity, 6.h),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0)),
                  ),
                  child: Text('Apply Filters',
                      style: TextStyle(fontSize: 15.sp, color: Colors.white)),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
