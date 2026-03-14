import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../services/gst_service.dart';
import '../../widgets/custom_app_bar.dart';
import './widgets/date_range_picker_widget.dart';
import './widgets/export_button_widget.dart';
import './widgets/filing_history_card_widget.dart';
import './widgets/format_selector_widget.dart';
import './widgets/report_metrics_card_widget.dart';
import './widgets/report_type_selector_widget.dart';

class GSTReportsScreen extends StatefulWidget {
  const GSTReportsScreen({super.key});

  @override
  State<GSTReportsScreen> createState() => _GSTReportsScreenState();
}

class _GSTReportsScreenState extends State<GSTReportsScreen> {
  final _gstService = GSTService();

  String _selectedReportType = 'Return Summary';
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 90));
  DateTime _endDate = DateTime.now();
  String _selectedFormat = 'PDF';

  List<Map<String, dynamic>> _filingHistory = [];
  Map<String, dynamic>? _reportData;
  bool _isLoading = false;
  bool _isLoadingHistory = true;

  @override
  void initState() {
    super.initState();
    _loadFilingHistory();
  }

  Future<void> _loadFilingHistory() async {
    setState(() => _isLoadingHistory = true);
    try {
      final history = await _gstService.getGSTReturns();
      setState(() {
        _filingHistory = history;
        _isLoadingHistory = false;
      });
    } catch (e) {
      setState(() => _isLoadingHistory = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load filing history: $e')),
        );
      }
    }
  }

  Future<void> _generateReport() async {
    setState(() => _isLoading = true);
    try {
      Map<String, dynamic> data;

      switch (_selectedReportType) {
        case 'Return Summary':
          data = await _gstService.getReturnSummary(
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case 'Tax Liability':
          data = await _gstService.getTaxLiabilitySummary(
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case 'Input Credit':
          data = await _gstService.getInputCreditSummary(
            startDate: _startDate,
            endDate: _endDate,
          );
          break;
        case 'Compliance Status':
          data = await _gstService.getComplianceStatus();
          break;
        default:
          data = {};
      }

      setState(() {
        _reportData = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate report: $e')),
        );
      }
    }
  }

  Future<void> _exportReport() async {
    if (_reportData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Generate a report first')),
      );
      return;
    }

    try {
      if (_selectedFormat == 'PDF') {
        await _gstService.exportReportToPDF(
          reportType: _selectedReportType,
          data: _reportData!,
          startDate: _startDate,
          endDate: _endDate,
        );
      } else {
        await _gstService.exportReportToCSV(
          reportType: _selectedReportType,
          data: _reportData!,
          startDate: _startDate,
          endDate: _endDate,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Report exported successfully as $_selectedFormat'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to export report: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: 'GST Reports',
        onBackPressed: () => Navigator.pop(context),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFilingHistory,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sticky Header Section
              Container(
                color: Colors.white,
                padding: EdgeInsets.all(4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Generate Report',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.h),

                    // Report Type Selector
                    ReportTypeSelectorWidget(
                      selectedType: _selectedReportType,
                      onTypeChanged: (type) {
                        setState(() => _selectedReportType = type);
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Date Range Picker
                    DateRangePickerWidget(
                      startDate: _startDate,
                      endDate: _endDate,
                      onDateRangeChanged: (start, end) {
                        setState(() {
                          _startDate = start;
                          _endDate = end;
                        });
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Format Selector
                    FormatSelectorWidget(
                      selectedFormat: _selectedFormat,
                      onFormatChanged: (format) {
                        setState(() => _selectedFormat = format);
                      },
                    ),

                    SizedBox(height: 2.h),

                    // Generate Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _generateReport,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2196F3),
                          padding: EdgeInsets.symmetric(vertical: 1.5.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                height: 20.0,
                                width: 20.0,
                                child: const CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                'Generate Report',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 2.h),

              // Report Preview Section
              if (_reportData != null) ...[
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(13),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Report Preview',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          ExportButtonWidget(
                            format: _selectedFormat,
                            onExport: _exportReport,
                          ),
                        ],
                      ),
                      SizedBox(height: 2.h),

                      // Metrics Cards
                      ReportMetricsCardWidget(
                        reportData: _reportData!,
                        reportType: _selectedReportType,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
              ],

              // Filing History Section
              Container(
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 1.h),
                      child: Text(
                        'Filing History',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    _isLoadingHistory
                        ? Center(
                            child: Padding(
                              padding: EdgeInsets.all(4.h),
                              child: const CircularProgressIndicator(),
                            ),
                          )
                        : _filingHistory.isEmpty
                            ? Container(
                                padding: EdgeInsets.all(4.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.inbox_outlined,
                                        size: 48.0,
                                        color: Colors.grey[400],
                                      ),
                                      SizedBox(height: 1.h),
                                      Text(
                                        'No filing history found',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _filingHistory.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(height: 1.h),
                                itemBuilder: (context, index) {
                                  return FilingHistoryCardWidget(
                                    filing: _filingHistory[index],
                                    onDownload: () async {
                                      try {
                                        await _gstService.downloadReturnPDF(
                                          _filingHistory[index]['id'],
                                        );
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Report downloaded successfully',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Download failed: $e',
                                              ),
                                            ),
                                          );
                                        }
                                      }
                                    },
                                  );
                                },
                              ),
                  ],
                ),
              ),

              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
