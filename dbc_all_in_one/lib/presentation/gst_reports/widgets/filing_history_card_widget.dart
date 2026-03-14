import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';


class FilingHistoryCardWidget extends StatefulWidget {
  final Map<String, dynamic> filing;
  final VoidCallback onDownload;

  const FilingHistoryCardWidget({
    super.key,
    required this.filing,
    required this.onDownload,
  });

  @override
  State<FilingHistoryCardWidget> createState() =>
      _FilingHistoryCardWidgetState();
}

class _FilingHistoryCardWidgetState extends State<FilingHistoryCardWidget> {
  bool _isExpanded = false;

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'filed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return 'N/A';
    try {
      final dateTime =
          date is DateTime ? date : DateTime.parse(date.toString());
      return DateFormat('dd MMM yyyy').format(dateTime);
    } catch (e) {
      return 'Invalid date';
    }
  }

  String _formatCurrency(dynamic value) {
    if (value == null) return '₹0';
    final amount =
        value is num ? value : double.tryParse(value.toString()) ?? 0;
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final status = widget.filing['filing_status']?.toString() ?? 'draft';
    final statusColor = _getStatusColor(status);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(3.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.filing['return_period']?.toString() ??
                                  'N/A',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Generated: ${_formatDate(widget.filing['created_at'])}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(26),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      _buildInfoChip(
                        Icons.calendar_today,
                        'Deadline: ${_formatDate(widget.filing['filing_deadline'])}',
                      ),
                      SizedBox(width: 2.w),
                      if (widget.filing['acknowledgment_number'] != null)
                        Icon(
                          Icons.verified,
                          size: 16.0,
                          color: Colors.green,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isExpanded) ...[
              const Divider(height: 1),
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Report Details',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    _buildDetailRow(
                      'Total Sales',
                      _formatCurrency(widget.filing['total_sales']),
                    ),
                    _buildDetailRow(
                      'Total Purchases',
                      _formatCurrency(widget.filing['total_purchases']),
                    ),
                    _buildDetailRow(
                      'Tax Collected',
                      _formatCurrency(widget.filing['output_tax']),
                    ),
                    _buildDetailRow(
                      'Input Credit',
                      _formatCurrency(widget.filing['input_tax_credit']),
                    ),
                    _buildDetailRow(
                      'Net Payable',
                      _formatCurrency(widget.filing['gst_payable']),
                    ),
                    if (widget.filing['acknowledgment_number'] != null) ...[
                      SizedBox(height: 1.h),
                      _buildDetailRow(
                        'ACK Number',
                        widget.filing['acknowledgment_number'].toString(),
                      ),
                      _buildDetailRow(
                        'Filed Date',
                        _formatDate(widget.filing['filed_date']),
                      ),
                    ],
                    SizedBox(height: 1.h),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: widget.onDownload,
                        icon: const Icon(Icons.download, size: 18.0),
                        label: Text(
                          'Download Report',
                          style: TextStyle(fontSize: 13.sp),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 1.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.0, color: Colors.grey[600]),
        SizedBox(width: 1.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 11.sp,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
