import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/payment_method_selector_widget.dart';
import './widgets/daily_summary_widget.dart';
import './widgets/transaction_card_widget.dart';

/// Payment Processing Center - Demo-ready payment management with transaction handling
class PaymentProcessingCenter extends StatefulWidget {
  const PaymentProcessingCenter({super.key});

  @override
  State<PaymentProcessingCenter> createState() =>
      _PaymentProcessingCenterState();
}

class _PaymentProcessingCenterState extends State<PaymentProcessingCenter>
    with SingleTickerProviderStateMixin {
  String _selectedPaymentMethod = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  List<String> _selectedTransactions = [];
  bool _isMultiSelectMode = false;

  // Mock transaction data
  final List<Map<String, dynamic>> _transactions = [
    {
      'id': 'TXN001',
      'amount': 1250.00,
      'recipient': 'Acme Corp',
      'method': 'credit_card',
      'status': 'pending',
      'date': '2025-12-13',
      'time': '10:30 AM',
      'description': 'Monthly subscription payment',
      'fee': 25.00,
      'estimatedCompletion': '2-3 hours',
      'cardLast4': '4242',
      'securityBadges': ['PCI-DSS', 'SSL', '3D-Secure'],
    },
    {
      'id': 'TXN002',
      'amount': 3500.00,
      'recipient': 'Tech Solutions Inc',
      'method': 'bank_transfer',
      'status': 'processing',
      'date': '2025-12-13',
      'time': '09:15 AM',
      'description': 'Service invoice payment',
      'fee': 15.00,
      'estimatedCompletion': '1-2 business days',
      'accountNumber': '****5678',
      'securityBadges': ['Bank-Grade', 'Encrypted'],
    },
    {
      'id': 'TXN003',
      'amount': 850.00,
      'recipient': 'Digital Marketing Co',
      'method': 'digital_wallet',
      'status': 'completed',
      'date': '2025-12-12',
      'time': '03:45 PM',
      'description': 'Ad campaign payment',
      'fee': 8.50,
      'estimatedCompletion': 'Instant',
      'walletId': 'wallet@example.com',
      'securityBadges': ['2FA', 'Biometric'],
    },
    {
      'id': 'TXN004',
      'amount': 500.00,
      'recipient': 'Office Supplies Ltd',
      'method': 'cash',
      'status': 'pending',
      'date': '2025-12-13',
      'time': '11:20 AM',
      'description': 'Office equipment purchase',
      'fee': 0.00,
      'estimatedCompletion': 'Immediate',
      'securityBadges': ['Receipt-Verified'],
    },
    {
      'id': 'TXN005',
      'amount': 2200.00,
      'recipient': 'Cloud Services Provider',
      'method': 'credit_card',
      'status': 'failed',
      'date': '2025-12-13',
      'time': '08:00 AM',
      'description': 'Annual hosting fee',
      'fee': 44.00,
      'estimatedCompletion': 'Retry available',
      'cardLast4': '9876',
      'securityBadges': ['PCI-DSS', 'SSL'],
      'failureReason': 'Insufficient funds',
    },
  ];

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTransactions {
    return _transactions.where((transaction) {
      final matchesMethod =
          _selectedPaymentMethod == 'all' ||
          transaction['method'] == _selectedPaymentMethod;
      final matchesSearch =
          _searchQuery.isEmpty ||
          transaction['recipient'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          transaction['id'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );
      return matchesMethod && matchesSearch;
    }).toList();
  }

  double get _totalBalance {
    return _transactions.fold(0.0, (sum, transaction) {
      if (transaction['status'] == 'completed') {
        return sum + (transaction['amount'] as num).toDouble();
      }
      return sum;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      appBar: CustomAppBar(
        title: 'Payment Processing',
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterSheet,
          ),
          if (_isMultiSelectMode)
            IconButton(
              icon: CustomIconWidget(
                iconName: 'close',
                color: theme.colorScheme.onSurface,
                size: 24,
              ),
              onPressed: () {
                setState(() {
                  _isMultiSelectMode = false;
                  _selectedTransactions.clear();
                });
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Payment Method Selector
            PaymentMethodSelectorWidget(
              selectedMethod: _selectedPaymentMethod,
              onMethodSelected: (method) {
                setState(() {
                  _selectedPaymentMethod = method;
                });
              },
            ),

            // Daily Summary
            DailySummaryWidget(
              totalBalance: _totalBalance,
              pendingCount:
                  _transactions.where((t) => t['status'] == 'pending').length,
              completedCount:
                  _transactions.where((t) => t['status'] == 'completed').length,
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: TextField(
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Search by recipient or ID...',
                  prefixIcon: Icon(
                    Icons.search,
                    color: theme.colorScheme.primary,
                  ),
                  suffixIcon:
                      _searchQuery.isNotEmpty
                          ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                          : IconButton(
                            icon: Icon(
                              Icons.mic,
                              color: theme.colorScheme.primary,
                            ),
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text('Voice search activated'),
                                  backgroundColor: theme.colorScheme.primary,
                                ),
                              );
                            },
                          ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: theme.colorScheme.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: theme.colorScheme.primary,
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surface,
                ),
              ),
            ),

            // Multi-select action bar
            if (_isMultiSelectMode && _selectedTransactions.isNotEmpty)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                color: theme.colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_selectedTransactions.length} selected',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _processBatchPayments(),
                      icon: CustomIconWidget(
                        iconName: 'payments',
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                      label: Text(
                        'Process Batch',
                        style: TextStyle(color: theme.colorScheme.primary),
                      ),
                    ),
                  ],
                ),
              ),

            // Transaction List
            Expanded(
              child:
                  _filteredTransactions.isEmpty
                      ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'search_off',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 64,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No transactions found',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'Try adjusting your filters',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                      : ListView.separated(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.h,
                        ),
                        itemCount: _filteredTransactions.length,
                        separatorBuilder:
                            (context, index) => SizedBox(height: 1.5.h),
                        itemBuilder: (context, index) {
                          final transaction = _filteredTransactions[index];
                          return TransactionCardWidget(
                            transaction: transaction,
                            isSelected: _selectedTransactions.contains(
                              transaction['id'],
                            ),
                            isMultiSelectMode: _isMultiSelectMode,
                            onTap: () => _handleTransactionTap(transaction),
                            onLongPress: () => _enableMultiSelect(transaction),
                            onSwipeRight:
                                () => _showQuickActions(context, transaction),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _generateDemoTransaction,
        backgroundColor: theme.colorScheme.primary,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'New Payment',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  void _handleTransactionTap(Map<String, dynamic> transaction) {
    if (_isMultiSelectMode) {
      setState(() {
        if (_selectedTransactions.contains(transaction['id'])) {
          _selectedTransactions.remove(transaction['id']);
        } else {
          _selectedTransactions.add(transaction['id'] as String);
        }
      });
    } else {
      _showTransactionDetails(transaction);
    }
  }

  void _enableMultiSelect(Map<String, dynamic> transaction) {
    setState(() {
      _isMultiSelectMode = true;
      _selectedTransactions.add(transaction['id'] as String);
    });
  }

  void _showTransactionDetails(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => Container(
            height: 70.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 1.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(4.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Transaction ID and Status
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              transaction['id'] as String,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            _buildStatusChip(
                              transaction['status'] as String,
                              theme,
                            ),
                          ],
                        ),
                        SizedBox(height: 3.h),

                        // Amount
                        Text(
                          'Amount',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '\$${transaction['amount'].toStringAsFixed(2)}',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(height: 2.h),

                        // Details
                        _buildDetailRow(
                          'Recipient',
                          transaction['recipient'] as String,
                          theme,
                        ),
                        _buildDetailRow(
                          'Description',
                          transaction['description'] as String,
                          theme,
                        ),
                        _buildDetailRow(
                          'Date & Time',
                          '${transaction['date']} at ${transaction['time']}',
                          theme,
                        ),
                        _buildDetailRow(
                          'Processing Fee',
                          '\$${transaction['fee'].toStringAsFixed(2)}',
                          theme,
                        ),
                        _buildDetailRow(
                          'Estimated Completion',
                          transaction['estimatedCompletion'] as String,
                          theme,
                        ),

                        // Payment method specific details
                        if (transaction['cardLast4'] != null)
                          _buildDetailRow(
                            'Card',
                            '**** **** **** ${transaction['cardLast4']}',
                            theme,
                          ),
                        if (transaction['accountNumber'] != null)
                          _buildDetailRow(
                            'Account',
                            transaction['accountNumber'] as String,
                            theme,
                          ),
                        if (transaction['walletId'] != null)
                          _buildDetailRow(
                            'Wallet',
                            transaction['walletId'] as String,
                            theme,
                          ),

                        // Failure reason if applicable
                        if (transaction['status'] == 'failed' &&
                            transaction['failureReason'] != null)
                          Container(
                            margin: EdgeInsets.only(top: 2.h),
                            padding: EdgeInsets.all(2.w),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.errorContainer,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'error',
                                  color: theme.colorScheme.error,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Expanded(
                                  child: Text(
                                    transaction['failureReason'] as String,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        SizedBox(height: 2.h),

                        // Security badges
                        Text(
                          'Security & Compliance',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        Wrap(
                          spacing: 2.w,
                          runSpacing: 1.h,
                          children:
                              (transaction['securityBadges'] as List)
                                  .map(
                                    (badge) => Chip(
                                      label: Text(badge as String),
                                      backgroundColor:
                                          theme.colorScheme.primaryContainer,
                                      labelStyle: TextStyle(
                                        color:
                                            theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                        fontSize: 12,
                                      ),
                                      avatar: CustomIconWidget(
                                        iconName: 'verified_user',
                                        color: theme.colorScheme.primary,
                                        size: 16,
                                      ),
                                    ),
                                  )
                                  .toList(),
                        ),
                        SizedBox(height: 3.h),

                        // Action buttons
                        if (transaction['status'] == 'pending')
                          Column(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _processPayment(transaction);
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'payments',
                                    color: theme.colorScheme.onPrimary,
                                    size: 20,
                                  ),
                                  label: const Text('Process Now'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    foregroundColor:
                                        theme.colorScheme.onPrimary,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 1.5.h,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 1.h),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                    _schedulePayment(transaction);
                                  },
                                  icon: CustomIconWidget(
                                    iconName: 'schedule',
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  label: const Text('Schedule Payment'),
                                ),
                              ),
                            ],
                          ),
                        if (transaction['status'] == 'failed')
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _retryPayment(transaction);
                              },
                              icon: CustomIconWidget(
                                iconName: 'refresh',
                                color: theme.colorScheme.onPrimary,
                                size: 20,
                              ),
                              label: const Text('Retry Payment'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                                padding: EdgeInsets.symmetric(vertical: 1.5.h),
                              ),
                            ),
                          ),
                        if (transaction['status'] == 'completed')
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _generateReceipt(transaction);
                              },
                              icon: CustomIconWidget(
                                iconName: 'receipt_long',
                                color: theme.colorScheme.primary,
                                size: 20,
                              ),
                              label: const Text('Generate Receipt'),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildStatusChip(String status, ThemeData theme) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'pending':
        backgroundColor = theme.colorScheme.tertiaryContainer;
        textColor = theme.colorScheme.onTertiaryContainer;
        label = 'Pending';
        break;
      case 'processing':
        backgroundColor = theme.colorScheme.primaryContainer;
        textColor = theme.colorScheme.onPrimaryContainer;
        label = 'Processing';
        break;
      case 'completed':
        backgroundColor = theme.colorScheme.secondaryContainer;
        textColor = theme.colorScheme.onSecondaryContainer;
        label = 'Completed';
        break;
      case 'failed':
        backgroundColor = theme.colorScheme.errorContainer;
        textColor = theme.colorScheme.onErrorContainer;
        label = 'Failed';
        break;
      default:
        backgroundColor = theme.colorScheme.surfaceContainerHighest;
        textColor = theme.colorScheme.onSurface;
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.5.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  void _showQuickActions(
    BuildContext context,
    Map<String, dynamic> transaction,
  ) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: EdgeInsets.only(top: 1.h),
                  width: 12.w,
                  height: 0.5.h,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurfaceVariant.withValues(
                      alpha: 0.3,
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    children: [
                      if (transaction['status'] == 'pending') ...[
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'payments',
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          title: const Text('Process Now'),
                          onTap: () {
                            Navigator.pop(context);
                            _processPayment(transaction);
                          },
                        ),
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'schedule',
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          title: const Text('Schedule Payment'),
                          onTap: () {
                            Navigator.pop(context);
                            _schedulePayment(transaction);
                          },
                        ),
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'cancel',
                            color: theme.colorScheme.error,
                            size: 24,
                          ),
                          title: const Text('Cancel Transaction'),
                          onTap: () {
                            Navigator.pop(context);
                            _cancelTransaction(transaction);
                          },
                        ),
                      ],
                      if (transaction['status'] == 'failed')
                        ListTile(
                          leading: CustomIconWidget(
                            iconName: 'refresh',
                            color: theme.colorScheme.primary,
                            size: 24,
                          ),
                          title: const Text('Retry Payment'),
                          onTap: () {
                            Navigator.pop(context);
                            _retryPayment(transaction);
                          },
                        ),
                      ListTile(
                        leading: CustomIconWidget(
                          iconName: 'receipt_long',
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        title: const Text('Generate Receipt'),
                        onTap: () {
                          Navigator.pop(context);
                          _generateReceipt(transaction);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showFilterSheet() {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Filter Options',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Payment Status',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children:
                        ['All', 'Pending', 'Processing', 'Completed', 'Failed']
                            .map(
                              (status) => FilterChip(
                                label: Text(status),
                                selected: false,
                                onSelected: (selected) {
                                  // Filter by status logic
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Date Range',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 2.w,
                    children:
                        ['Today', 'This Week', 'This Month', 'Custom']
                            .map(
                              (range) => FilterChip(
                                label: Text(range),
                                selected: false,
                                onSelected: (selected) {
                                  // Filter by date range logic
                                  Navigator.pop(context);
                                },
                              ),
                            )
                            .toList(),
                  ),
                  SizedBox(height: 2.h),
                ],
              ),
            ),
          ),
    );
  }

  void _processPayment(Map<String, dynamic> transaction) {
    _showProcessingDialog(transaction);
  }

  void _schedulePayment(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment ${transaction['id']} scheduled successfully'),
        backgroundColor: theme.colorScheme.primary,
        action: SnackBarAction(
          label: 'UNDO',
          textColor: theme.colorScheme.onPrimary,
          onPressed: () {},
        ),
      ),
    );
  }

  void _cancelTransaction(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancel Transaction'),
            content: Text(
              'Are you sure you want to cancel transaction ${transaction['id']}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Transaction ${transaction['id']} cancelled',
                      ),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                },
                child: const Text('Yes, Cancel'),
              ),
            ],
          ),
    );
  }

  void _retryPayment(Map<String, dynamic> transaction) {
    _showProcessingDialog(transaction, isRetry: true);
  }

  void _generateReceipt(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Generating receipt for ${transaction['id']}...'),
        backgroundColor: theme.colorScheme.primary,
        duration: const Duration(seconds: 2),
      ),
    );

    // Simulate receipt generation
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Receipt generated and sent to your email'),
            backgroundColor: theme.colorScheme.secondary,
            action: SnackBarAction(
              label: 'VIEW',
              textColor: theme.colorScheme.onSecondary,
              onPressed: () {},
            ),
          ),
        );
      }
    });
  }

  void _processBatchPayments() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Process Batch Payments'),
            content: Text(
              'Process ${_selectedTransactions.length} selected payments?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showBatchProcessingDialog();
                },
                child: const Text('Process'),
              ),
            ],
          ),
    );
  }

  void _showProcessingDialog(
    Map<String, dynamic> transaction, {
    bool isRetry = false,
  }) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                SizedBox(height: 2.h),
                Text(
                  isRetry ? 'Retrying payment...' : 'Processing payment...',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  transaction['id'] as String,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
    );

    // Simulate processing with realistic delay
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pop(context); // Close processing dialog

        // Show success animation
        _showSuccessDialog(transaction);
      }
    });
  }

  void _showSuccessDialog(Map<String, dynamic> transaction) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: CustomIconWidget(
                    iconName: 'check_circle',
                    color: theme.colorScheme.secondary,
                    size: 48,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Payment Successful!',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.secondary,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  '\$${transaction['amount'].toStringAsFixed(2)}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  'to ${transaction['recipient']}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _generateReceipt(transaction);
                },
                child: const Text('Get Receipt'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Done'),
              ),
            ],
          ),
    );
  }

  void _showBatchProcessingDialog() {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                SizedBox(height: 2.h),
                Text(
                  'Processing batch payments...',
                  style: theme.textTheme.titleMedium,
                ),
                SizedBox(height: 1.h),
                Text(
                  '${_selectedTransactions.length} transactions',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
    );

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pop(context);
        setState(() {
          _isMultiSelectMode = false;
          _selectedTransactions.clear();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Batch processing completed successfully'),
            backgroundColor: theme.colorScheme.secondary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void _generateDemoTransaction() {
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Demo transaction generated successfully'),
        backgroundColor: theme.colorScheme.primary,
        action: SnackBarAction(
          label: 'VIEW',
          textColor: theme.colorScheme.onPrimary,
          onPressed: () {},
        ),
      ),
    );
  }
}