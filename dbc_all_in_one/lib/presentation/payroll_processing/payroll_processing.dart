import 'dart:io' if (dart.library.io) 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:universal_html/html.dart' as html;

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/pay_period_selector_widget.dart';
import './widgets/payroll_card_widget.dart';
import './widgets/payroll_summary_widget.dart';
import './widgets/search_filter_widget.dart';

class PayrollProcessing extends StatefulWidget {
  const PayrollProcessing({super.key});

  @override
  State<PayrollProcessing> createState() => _PayrollProcessingState();
}

class _PayrollProcessingState extends State<PayrollProcessing> {
  String _selectedPeriod = 'daily';
  final TextEditingController _searchController = TextEditingController();
  String _selectedDepartment = 'All';
  String _selectedStatus = 'All';
  String _selectedWageType = 'All';
  final Set<int> _expandedCards = {};
  final Set<int> _selectedCards = {};
  bool _isMultiSelectMode = false;
  bool _isLoading = false;

  final List<Map<String, dynamic>> _payrollData = [
    {
      "id": 1,
      "name": "Michael Rodriguez",
      "role": "Cashier",
      "department": "Front",
      "wageType": "Hourly",
      "basePay": 480.0,
      "overtimeHours": 5,
      "overtimeRate": 18.0,
      "overtimeAmount": 90.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 50.0,
      "lateFines": 0.0,
      "deductions": 20.0,
      "netPay": 600.0,
      "status": "Pending",
    },
    {
      "id": 2,
      "name": "Sarah Chen",
      "role": "Cook",
      "department": "Kitchen",
      "wageType": "Daily",
      "basePay": 800.0,
      "overtimeHours": 0,
      "overtimeRate": 0.0,
      "overtimeAmount": 0.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 100.0,
      "lateFines": 10.0,
      "deductions": 30.0,
      "netPay": 860.0,
      "status": "Paid",
    },
    {
      "id": 3,
      "name": "James Wilson",
      "role": "Waiter",
      "department": "Front",
      "wageType": "Hourly",
      "basePay": 400.0,
      "overtimeHours": 8,
      "overtimeRate": 15.0,
      "overtimeAmount": 120.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 75.0,
      "lateFines": 5.0,
      "deductions": 15.0,
      "netPay": 575.0,
      "status": "Pending",
    },
    {
      "id": 4,
      "name": "Emily Thompson",
      "role": "Cleaner",
      "department": "Rooms",
      "wageType": "Piece Rate",
      "basePay": 0.0,
      "overtimeHours": 0,
      "overtimeRate": 0.0,
      "overtimeAmount": 0.0,
      "pieceRateUnits": 45,
      "pieceRateAmount": 450.0,
      "bonus": 25.0,
      "lateFines": 0.0,
      "deductions": 10.0,
      "netPay": 465.0,
      "status": "Paid",
    },
    {
      "id": 5,
      "name": "David Martinez",
      "role": "Trainer",
      "department": "Gym",
      "wageType": "Hourly",
      "basePay": 600.0,
      "overtimeHours": 3,
      "overtimeRate": 25.0,
      "overtimeAmount": 75.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 150.0,
      "lateFines": 0.0,
      "deductions": 25.0,
      "netPay": 800.0,
      "status": "Pending",
    },
    {
      "id": 6,
      "name": "Lisa Anderson",
      "role": "Worker",
      "department": "Production",
      "wageType": "Daily",
      "basePay": 700.0,
      "overtimeHours": 0,
      "overtimeRate": 0.0,
      "overtimeAmount": 0.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 50.0,
      "lateFines": 15.0,
      "deductions": 20.0,
      "netPay": 715.0,
      "status": "Paid",
    },
    {
      "id": 7,
      "name": "Robert Taylor",
      "role": "Guard",
      "department": "Front",
      "wageType": "Hourly",
      "basePay": 520.0,
      "overtimeHours": 10,
      "overtimeRate": 16.0,
      "overtimeAmount": 160.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 30.0,
      "lateFines": 0.0,
      "deductions": 18.0,
      "netPay": 692.0,
      "status": "Pending",
    },
    {
      "id": 8,
      "name": "Maria Garcia",
      "role": "Cook",
      "department": "Kitchen",
      "wageType": "Daily",
      "basePay": 750.0,
      "overtimeHours": 0,
      "overtimeRate": 0.0,
      "overtimeAmount": 0.0,
      "pieceRateUnits": 0,
      "pieceRateAmount": 0.0,
      "bonus": 80.0,
      "lateFines": 5.0,
      "deductions": 25.0,
      "netPay": 800.0,
      "status": "Paid",
    },
  ];

  List<Map<String, dynamic>> get _filteredPayrollData {
    return _payrollData.where((payroll) {
      final matchesSearch = _searchController.text.isEmpty ||
          (payroll['name'] as String)
              .toLowerCase()
              .contains(_searchController.text.toLowerCase()) ||
          (payroll['role'] as String)
              .toLowerCase()
              .contains(_searchController.text.toLowerCase());

      final matchesDepartment = _selectedDepartment == 'All' ||
          payroll['department'] == _selectedDepartment;
      final matchesStatus =
          _selectedStatus == 'All' || payroll['status'] == _selectedStatus;
      final matchesWageType = _selectedWageType == 'All' ||
          payroll['wageType'] == _selectedWageType;

      return matchesSearch &&
          matchesDepartment &&
          matchesStatus &&
          matchesWageType;
    }).toList();
  }

  double get _totalPayroll {
    return _filteredPayrollData.fold(
        0.0, (sum, payroll) => sum + (payroll['netPay'] as double));
  }

  int get _totalEmployees => _filteredPayrollData.length;

  int get _paidEmployees {
    return _filteredPayrollData
        .where((payroll) => payroll['status'] == 'Paid')
        .length;
  }

  int get _pendingEmployees {
    return _filteredPayrollData
        .where((payroll) => payroll['status'] == 'Pending')
        .length;
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
  }

  void _handleCardAction(int payrollId, String action) {
    final payroll = _payrollData.firstWhere((p) => p['id'] == payrollId);

    switch (action) {
      case 'mark_paid':
        setState(() {
          payroll['status'] = 'Paid';
        });
        _showSnackBar('Payment marked as paid for ${payroll['name']}');
        break;
      case 'generate_slip':
        _generatePaySlip(payroll);
        break;
      case 'send_payment':
        _showSnackBar('Payment sent to ${payroll['name']}');
        break;
      case 'add_bonus':
        _showBonusDialog(payroll);
        break;
      case 'calculate':
        _calculateWages(payroll);
        break;
      case 'export':
        _exportPaySlip(payroll);
        break;
    }
  }

  void _calculateWages(Map<String, dynamic> payroll) {
    setState(() => _isLoading = true);

    Future.delayed(const Duration(milliseconds: 500), () {
      final basePay = payroll['basePay'] as double;
      final overtimeAmount = payroll['overtimeAmount'] as double;
      final pieceRateAmount = payroll['pieceRateAmount'] as double;
      final bonus = payroll['bonus'] as double;
      final lateFines = payroll['lateFines'] as double;
      final deductions = payroll['deductions'] as double;

      final netPay = basePay +
          overtimeAmount +
          pieceRateAmount +
          bonus -
          lateFines -
          deductions;

      setState(() {
        payroll['netPay'] = netPay;
        _isLoading = false;
      });

      _showSnackBar(
          'Wages calculated for ${payroll['name']}: \$${netPay.toStringAsFixed(2)}');
    });
  }

  Future<void> _generatePaySlip(Map<String, dynamic> payroll) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'DBC All-In-One',
                style:
                    pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Pay Slip',
                style:
                    pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 20),
              pw.Text('Employee: ${payroll['name']}'),
              pw.Text('Role: ${payroll['role']}'),
              pw.Text('Department: ${payroll['department']}'),
              pw.Text('Pay Period: $_selectedPeriod'),
              pw.SizedBox(height: 20),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text('Earnings:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Base Pay: \$${(payroll['basePay'] as double).toStringAsFixed(2)}'),
              pw.Text(
                  'Overtime: \$${(payroll['overtimeAmount'] as double).toStringAsFixed(2)}'),
              pw.Text(
                  'Piece Rate: \$${(payroll['pieceRateAmount'] as double).toStringAsFixed(2)}'),
              pw.Text(
                  'Bonus: \$${(payroll['bonus'] as double).toStringAsFixed(2)}'),
              pw.SizedBox(height: 10),
              pw.Text('Deductions:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
              pw.Text(
                  'Late Fines: \$${(payroll['lateFines'] as double).toStringAsFixed(2)}'),
              pw.Text(
                  'Other Deductions: \$${(payroll['deductions'] as double).toStringAsFixed(2)}'),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 10),
              pw.Text(
                'Net Pay: \$${(payroll['netPay'] as double).toStringAsFixed(2)}',
                style:
                    pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
              ),
            ],
          );
        },
      ),
    );

    final bytes = await pdf.save();
    final fileName =
        'payslip_${payroll['name'].toString().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}.pdf';

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute("download", fileName)
        ..click();
      html.Url.revokeObjectUrl(url);
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([XFile(file.path)],
          text: 'Pay slip for ${payroll['name']}');
    }

    _showSnackBar('Pay slip generated for ${payroll['name']}');
  }

  Future<void> _exportPaySlip(Map<String, dynamic> payroll) async {
    await _generatePaySlip(payroll);
  }

  void _showBonusDialog(Map<String, dynamic> payroll) {
    final TextEditingController bonusController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('Add Bonus'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Employee: ${payroll['name']}'),
              SizedBox(height: 2.h),
              TextField(
                controller: bonusController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Bonus Amount',
                  prefixText: '\$',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final bonusAmount =
                    double.tryParse(bonusController.text) ?? 0.0;
                setState(() {
                  payroll['bonus'] = (payroll['bonus'] as double) + bonusAmount;
                  payroll['netPay'] =
                      (payroll['netPay'] as double) + bonusAmount;
                });
                Navigator.pop(context);
                _showSnackBar(
                    'Bonus of \$${bonusAmount.toStringAsFixed(2)} added to ${payroll['name']}');
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _handleBulkPayment() {
    if (_selectedCards.isEmpty) {
      _showSnackBar('Please select employees for bulk payment');
      return;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Bulk Payment'),
          content: Text('Mark ${_selectedCards.length} employees as paid?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  for (final id in _selectedCards) {
                    final payroll =
                        _payrollData.firstWhere((p) => p['id'] == id);
                    payroll['status'] = 'Paid';
                  }
                  _selectedCards.clear();
                  _isMultiSelectMode = false;
                });
                Navigator.pop(context);
                _showSnackBar('Bulk payment processed successfully');
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Payroll Processing',
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: theme.colorScheme.onSurface,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
                  _selectedCards.clear();
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: PayPeriodSelectorWidget(
                          selectedPeriod: _selectedPeriod,
                          onPeriodChanged: (period) {
                            setState(() => _selectedPeriod = period);
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: PayrollSummaryWidget(
                          totalPayroll: _totalPayroll,
                          totalEmployees: _totalEmployees,
                          paidEmployees: _paidEmployees,
                          pendingEmployees: _pendingEmployees,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: SearchFilterWidget(
                          searchController: _searchController,
                          selectedDepartment: _selectedDepartment,
                          selectedStatus: _selectedStatus,
                          selectedWageType: _selectedWageType,
                          onDepartmentChanged: (value) {
                            setState(() => _selectedDepartment = value);
                          },
                          onStatusChanged: (value) {
                            setState(() => _selectedStatus = value);
                          },
                          onWageTypeChanged: (value) {
                            setState(() => _selectedWageType = value);
                          },
                          onClearFilters: () {
                            setState(() {
                              _selectedDepartment = 'All';
                              _selectedStatus = 'All';
                              _selectedWageType = 'All';
                              _searchController.clear();
                            });
                          },
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _filteredPayrollData.isEmpty
                          ? Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 10.h),
                                child: Column(
                                  children: [
                                    CustomIconWidget(
                                      iconName: 'search_off',
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 64,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      'No payroll records found',
                                      style:
                                          theme.textTheme.titleMedium?.copyWith(
                                        color:
                                            theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _filteredPayrollData.length,
                              itemBuilder: (context, index) {
                                final payroll = _filteredPayrollData[index];
                                final payrollId = payroll['id'] as int;
                                final isExpanded =
                                    _expandedCards.contains(payrollId);
                                final isSelected =
                                    _selectedCards.contains(payrollId);

                                return GestureDetector(
                                  onLongPress: () {
                                    setState(() {
                                      _isMultiSelectMode = true;
                                      _selectedCards.add(payrollId);
                                    });
                                  },
                                  child: Stack(
                                    children: [
                                      PayrollCardWidget(
                                        payrollData: payroll,
                                        isExpanded: isExpanded,
                                        onTap: () {
                                          if (_isMultiSelectMode) {
                                            setState(() {
                                              isSelected
                                                  ? _selectedCards
                                                      .remove(payrollId)
                                                  : _selectedCards
                                                      .add(payrollId);
                                            });
                                          } else {
                                            setState(() {
                                              isExpanded
                                                  ? _expandedCards
                                                      .remove(payrollId)
                                                  : _expandedCards
                                                      .add(payrollId);
                                            });
                                          }
                                        },
                                        onAction: (action) => _handleCardAction(
                                            payrollId, action),
                                      ),
                                      if (_isMultiSelectMode)
                                        Positioned(
                                          top: 2.h,
                                          right: 6.w,
                                          child: Checkbox(
                                            value: isSelected,
                                            onChanged: (value) {
                                              setState(() {
                                                value == true
                                                    ? _selectedCards
                                                        .add(payrollId)
                                                    : _selectedCards
                                                        .remove(payrollId);
                                              });
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
      ),
      floatingActionButton: _isMultiSelectMode
          ? FloatingActionButton.extended(
              onPressed: _handleBulkPayment,
              icon: CustomIconWidget(
                iconName: 'payment',
                color: Colors.white,
                size: 24,
              ),
              label: Text('Process ${_selectedCards.length} Payments'),
            )
          : FloatingActionButton.extended(
              onPressed: _handleBulkPayment,
              icon: CustomIconWidget(
                iconName: 'payment',
                color: Colors.white,
                size: 24,
              ),
              label: Text('Bulk Payment'),
            ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 3,
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }
}
