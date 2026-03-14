import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class ReportMetricsCardWidget extends StatelessWidget {
  final Map<String, dynamic> reportData;
  final String reportType;

  const ReportMetricsCardWidget({
    super.key,
    required this.reportData,
    required this.reportType,
  });

  String _formatCurrency(dynamic value) {
    if (value == null) return '₹0';
    final amount =
        value is num ? value : double.tryParse(value.toString()) ?? 0;
    return '₹${amount.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (reportType == 'Return Summary') ...[
          _buildMetricRow(
            'Total Sales',
            _formatCurrency(reportData['total_sales']),
            Icons.trending_up,
            Colors.green,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Total Purchases',
            _formatCurrency(reportData['total_purchases']),
            Icons.shopping_cart,
            Colors.orange,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Tax Collected',
            _formatCurrency(reportData['output_tax']),
            Icons.account_balance_wallet,
            Colors.blue,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Net GST Payable',
            _formatCurrency(reportData['gst_payable']),
            Icons.payment,
            Colors.red,
          ),
        ],
        if (reportType == 'Tax Liability') ...[
          _buildMetricRow(
            'Output Tax',
            _formatCurrency(reportData['output_tax']),
            Icons.arrow_upward,
            Colors.red,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Input Tax Credit',
            _formatCurrency(reportData['input_tax_credit']),
            Icons.arrow_downward,
            Colors.green,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Net Liability',
            _formatCurrency(reportData['net_liability']),
            Icons.balance,
            Colors.orange,
          ),
        ],
        if (reportType == 'Input Credit') ...[
          _buildMetricRow(
            'Total ITC Claimed',
            _formatCurrency(reportData['total_itc_claimed']),
            Icons.receipt_long,
            Colors.blue,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'ITC Utilized',
            _formatCurrency(reportData['itc_utilized']),
            Icons.check_circle,
            Colors.green,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'ITC Balance',
            _formatCurrency(reportData['itc_balance']),
            Icons.account_balance,
            Colors.purple,
          ),
        ],
        if (reportType == 'Compliance Status') ...[
          _buildMetricRow(
            'Filed Returns',
            '${reportData['filed_returns'] ?? 0}',
            Icons.check_circle,
            Colors.green,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Pending Returns',
            '${reportData['pending_returns'] ?? 0}',
            Icons.pending,
            Colors.orange,
          ),
          SizedBox(height: 1.h),
          _buildMetricRow(
            'Compliance Score',
            '${reportData['compliance_score'] ?? 0}%',
            Icons.star,
            Colors.amber,
          ),
        ],
      ],
    );
  }

  Widget _buildMetricRow(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(13),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withAlpha(51)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: color, size: 20.0),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
