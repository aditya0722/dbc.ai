import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SearchResultCardWidget extends StatelessWidget {
  final Map<String, dynamic> result;
  final VoidCallback onTap;

  const SearchResultCardWidget({
    super.key,
    required this.result,
    required this.onTap,
  });

  String _getModuleIcon() {
    if (result.containsKey('invoice_number')) return '📄';
    if (result.containsKey('product_name')) return '📦';
    if (result.containsKey('full_name') && result.containsKey('email'))
      return '👤';
    if (result.containsKey('vendor_name')) return '🏪';
    if (result.containsKey('item_name')) return '🛒';
    return '📋';
  }

  String _getModuleName() {
    if (result.containsKey('invoice_number')) return 'Invoice';
    if (result.containsKey('product_name')) return 'Product';
    if (result.containsKey('full_name') && result.containsKey('email'))
      return 'Staff';
    if (result.containsKey('vendor_name')) return 'Vendor';
    if (result.containsKey('item_name')) return 'Order';
    return 'Item';
  }

  String _getPrimaryText() {
    if (result.containsKey('invoice_number'))
      return result['invoice_number'] ?? 'N/A';
    if (result.containsKey('product_name'))
      return result['product_name'] ?? 'N/A';
    if (result.containsKey('full_name')) return result['full_name'] ?? 'N/A';
    if (result.containsKey('vendor_name'))
      return result['vendor_name'] ?? 'N/A';
    if (result.containsKey('item_name')) return result['item_name'] ?? 'N/A';
    return 'Unknown';
  }

  String _getSecondaryText() {
    if (result.containsKey('customer_name'))
      return result['customer_name'] ?? '';
    if (result.containsKey('description')) return result['description'] ?? '';
    if (result.containsKey('email')) return result['email'] ?? '';
    if (result.containsKey('contact_email'))
      return result['contact_email'] ?? '';
    return '';
  }

  String? _getStatusText() {
    if (result.containsKey('status'))
      return result['status']?.toString().toUpperCase();
    if (result.containsKey('is_active'))
      return result['is_active'] == true ? 'ACTIVE' : 'INACTIVE';
    if (result.containsKey('is_verified'))
      return result['is_verified'] == true ? 'VERIFIED' : 'UNVERIFIED';
    return null;
  }

  Color _getStatusColor() {
    final status = _getStatusText()?.toLowerCase();
    if (status == null) return Colors.grey;
    if (status.contains('active') ||
        status.contains('verified') ||
        status.contains('paid')) {
      return Colors.green;
    }
    if (status.contains('pending') || status.contains('draft'))
      return Colors.orange;
    if (status.contains('overdue') || status.contains('inactive'))
      return Colors.red;
    return Colors.grey;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 2.h),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(_getModuleIcon(),
                      style: const TextStyle(fontSize: 24.0)),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 2.0),
                              decoration: BoxDecoration(
                                color: Colors.blue.withAlpha(26),
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                _getModuleName(),
                                style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.blue,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                            if (_getStatusText() != null) ...[
                              SizedBox(width: 2.w),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 2.0),
                                decoration: BoxDecoration(
                                  color: _getStatusColor().withAlpha(26),
                                  borderRadius: BorderRadius.circular(4.0),
                                ),
                                child: Text(
                                  _getStatusText()!,
                                  style: TextStyle(
                                      fontSize: 10.sp,
                                      color: _getStatusColor(),
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ],
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          _getPrimaryText(),
                          style: TextStyle(
                              fontSize: 15.sp, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios,
                      size: 16.0, color: Colors.grey[400]),
                ],
              ),
              if (_getSecondaryText().isNotEmpty) ...[
                SizedBox(height: 1.h),
                Text(
                  _getSecondaryText(),
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: 1.h),
              Row(
                children: [
                  if (result.containsKey('total_amount'))
                    _buildInfoChip(
                        '₹${result['total_amount']}', Icons.currency_rupee),
                  if (result.containsKey('rating'))
                    _buildInfoChip('${result['rating']} ⭐', Icons.star),
                  if (result.containsKey('role'))
                    _buildInfoChip(result['role'], Icons.work_outline),
                  if (result.containsKey('created_at'))
                    _buildInfoChip(_formatDate(result['created_at']),
                        Icons.calendar_today),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String text, IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.0, color: Colors.grey[600]),
          const SizedBox(width: 4.0),
          Text(text,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey[700])),
        ],
      ),
    );
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null) return '';
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
