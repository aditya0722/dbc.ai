import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/invoicing_service.dart';
import './widgets/date_range_selector_widget.dart';
import './widgets/invoice_timeline_card_widget.dart';
import './widgets/payment_status_filter_chip_widget.dart';

class InvoiceManagementCenter extends StatefulWidget {
  const InvoiceManagementCenter({super.key});

  @override
  State<InvoiceManagementCenter> createState() =>
      _InvoiceManagementCenterState();
}

class _InvoiceManagementCenterState extends State<InvoiceManagementCenter> {
  final InvoicingService _invoicingService = InvoicingService();
  final TextEditingController _searchController = TextEditingController();

  List<Map<String, dynamic>> _invoices = [];
  bool _isLoading = true;
  String _selectedStatus = 'all';
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadInvoices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInvoices() async {
    setState(() => _isLoading = true);

    try {
      final invoices = await _invoicingService.getFilteredInvoices(
        statusFilter: _selectedStatus,
        startDate: _startDate,
        endDate: _endDate,
        customerSearch:
            _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        _invoices = invoices;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load invoices: $e')),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _loadInvoices();
    setState(() => _isRefreshing = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invoices refreshed'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _handleStatusFilter(String status) {
    setState(() {
      _selectedStatus = status;
    });
    _loadInvoices();
  }

  void _handleDateRangeSelected(DateTime? start, DateTime? end) {
    setState(() {
      _startDate = start;
      _endDate = end;
    });
    _loadInvoices();
  }

  Future<void> _markAsPaid(String invoiceId) async {
    try {
      await _invoicingService.updateInvoiceStatus(invoiceId, 'paid');
      await _loadInvoices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice marked as paid')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update invoice: $e')),
        );
      }
    }
  }

  Future<void> _duplicateInvoice(String invoiceId) async {
    try {
      await _invoicingService.duplicateInvoice(invoiceId);
      await _loadInvoices();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice duplicated successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to duplicate invoice: $e')),
        );
      }
    }
  }

  void _viewInvoiceDetails(String invoiceId) {
    // Navigate to invoice details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for invoice: $invoiceId')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Invoice Management',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(4.w),
                bottomRight: Radius.circular(4.w),
              ),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadInvoices(),
                  style: TextStyle(fontSize: 14.sp),
                  decoration: InputDecoration(
                    hintText: 'Search by customer or invoice number',
                    hintStyle: TextStyle(fontSize: 13.sp),
                    prefixIcon: Icon(Icons.search, size: 5.w),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(2.w),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 1.5.h,
                      horizontal: 3.w,
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      PaymentStatusFilterChipWidget(
                        label: 'All',
                        isSelected: _selectedStatus == 'all',
                        onTap: () => _handleStatusFilter('all'),
                      ),
                      SizedBox(width: 2.w),
                      PaymentStatusFilterChipWidget(
                        label: 'Paid',
                        isSelected: _selectedStatus == 'paid',
                        color: Colors.green,
                        onTap: () => _handleStatusFilter('paid'),
                      ),
                      SizedBox(width: 2.w),
                      PaymentStatusFilterChipWidget(
                        label: 'Pending',
                        isSelected: _selectedStatus == 'sent',
                        color: Colors.orange,
                        onTap: () => _handleStatusFilter('sent'),
                      ),
                      SizedBox(width: 2.w),
                      PaymentStatusFilterChipWidget(
                        label: 'Overdue',
                        isSelected: _selectedStatus == 'overdue',
                        color: Colors.red,
                        onTap: () => _handleStatusFilter('overdue'),
                      ),
                      SizedBox(width: 2.w),
                      PaymentStatusFilterChipWidget(
                        label: 'Draft',
                        isSelected: _selectedStatus == 'draft',
                        color: Colors.grey,
                        onTap: () => _handleStatusFilter('draft'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                DateRangeSelectorWidget(
                  startDate: _startDate,
                  endDate: _endDate,
                  onDateRangeSelected: _handleDateRangeSelected,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _invoices.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long_outlined,
                              size: 15.w,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No invoices found',
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _handleRefresh,
                        child: ListView.builder(
                          padding: EdgeInsets.all(3.w),
                          itemCount: _invoices.length,
                          itemBuilder: (context, index) {
                            final invoice = _invoices[index];
                            return InvoiceTimelineCardWidget(
                              invoiceNumber: invoice['invoice_number'] ?? 'N/A',
                              customerName: invoice['customer_name'] ?? 'N/A',
                              issueDate: DateTime.parse(invoice['issue_date']),
                              dueDate: DateTime.parse(invoice['due_date']),
                              totalAmount: (invoice['total_amount'] as num?)
                                      ?.toDouble() ??
                                  0.0,
                              status: invoice['status'] ?? 'draft',
                              onTap: () => _viewInvoiceDetails(invoice['id']),
                              onMarkAsPaid: () => _markAsPaid(invoice['id']),
                              onDuplicate: () =>
                                  _duplicateInvoice(invoice['id']),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create-invoice');
        },
        icon: const Icon(Icons.add),
        label: Text('New Invoice', style: TextStyle(fontSize: 13.sp)),
        backgroundColor: Theme.of(context).primaryColor,
      ),
    );
  }
}
