import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/gst_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/filing_timeline_card_widget.dart';
import './widgets/gst_overview_card_widget.dart';
import './widgets/period_selector_widget.dart';
import './widgets/quick_action_button_widget.dart';
import '../../widgets/dbc_back_button.dart';
/// GST Filing Center - Comprehensive tax management with cloud-based GST calculation
class GSTFilingCenter extends StatefulWidget {
  const GSTFilingCenter({super.key});

  @override
  State<GSTFilingCenter> createState() => _GSTFilingCenterState();
}

class _GSTFilingCenterState extends State<GSTFilingCenter> {
  final GSTService _gstService = GSTService();
  String _selectedPeriod = 'quarterly';
  bool _isLoading = true;
  Map<String, dynamic>? _currentPeriodData;
  List<Map<String, dynamic>> _upcomingDeadlines = [];
  Map<String, dynamic>? _gstSettings;

  @override
  void initState() {
    super.initState();
    _loadGSTData();
  }

  Future<void> _loadGSTData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _gstService.getCurrentPeriodSummary();
      final deadlines = await _gstService.getUpcomingDeadlines();
      final settings = await _gstService.getGSTSettings();

      setState(() {
        _currentPeriodData = summary;
        _upcomingDeadlines = deadlines;
        _gstSettings = settings;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load GST data: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.95),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              floating: false,
              backgroundColor: theme.colorScheme.primary,
              expandedHeight: 12.h,
              leading: DBCBackButton(
                onPressed: () => Navigator.maybePop(context),
                iconColor: theme.colorScheme.onPrimary,
                backgroundColor: Colors.transparent,
                iconSize: 24,
              ),
              flexibleSpace: FlexibleSpaceBar(
                title: Text(
                  'GST Filing Center',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.primary.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              ),
              actions: [
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'settings',
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  onPressed: _showSettingsDialog,
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'help_outline',
                    color: theme.colorScheme.onPrimary,
                    size: 24,
                  ),
                  onPressed: _showHelpDialog,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 2.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: PeriodSelectorWidget(
                      selectedPeriod: _selectedPeriod,
                      onPeriodChanged: (period) {
                        setState(() => _selectedPeriod = period);
                        _loadGSTData();
                      },
                    ),
                  ),
                  SizedBox(height: 2.h),
                  if (_isLoading)
                    Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 4.h),
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    )
                  else ...[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Current Period Overview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: GSTOverviewCard(
                        totalSales: _currentPeriodData?['total_sales'] ?? 0.0,
                        totalPurchases:
                            _currentPeriodData?['total_purchases'] ?? 0.0,
                        inputTaxCredit:
                            _currentPeriodData?['input_tax_credit'] ?? 0.0,
                        gstPayable: _currentPeriodData?['gst_payable'] ?? 0.0,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Filing Timeline',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    if (_upcomingDeadlines.isEmpty)
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        child: Center(
                          child: Text(
                            'No upcoming deadlines',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        itemCount: _upcomingDeadlines.length,
                        separatorBuilder: (context, index) =>
                            SizedBox(height: 1.h),
                        itemBuilder: (context, index) {
                          final deadline = _upcomingDeadlines[index];
                          return FilingTimelineCard(
                            returnPeriod: deadline['return_period'] ?? '',
                            filingDeadline: DateTime.parse(
                              deadline['filing_deadline'],
                            ),
                            status: deadline['filing_status'] ?? 'pending',
                            gstPayable:
                                (deadline['gst_payable'] as num?)?.toDouble() ??
                                    0.0,
                            onTap: () => _showReturnDetails(deadline),
                          );
                        },
                      ),
                    SizedBox(height: 2.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Text(
                        'Quick Actions',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Row(
                        children: [
                          Expanded(
                            child: QuickActionButton(
                              icon: 'description',
                              label: 'Generate\nReturn',
                              color: const Color(0xFF10B981),
                              onTap: _generateReturn,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: QuickActionButton(
                              icon: 'upload_file',
                              label: 'Upload\nInvoices',
                              color: const Color(0xFF3B82F6),
                              onTap: _uploadInvoices,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: QuickActionButton(
                              icon: 'file_download',
                              label: 'Download\nCertificates',
                              color: const Color(0xFF8B5CF6),
                              onTap: _downloadCertificates,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: QuickActionButton(
                              icon: 'notifications',
                              label: 'Schedule\nReminders',
                              color: const Color(0xFFF59E0B),
                              onTap: _scheduleReminders,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          Expanded(
                            child: QuickActionButton(
                              icon: 'assessment',
                              label: 'View\nReports',
                              color: const Color(0xFF06B6D4),
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.gstReports);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 4.h),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 0,
        onTap: (index) {},
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  void _showReturnDetails(Map<String, dynamic> returnData) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final dateFormat = DateFormat('dd MMM yyyy');

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'GST Return Details',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),
                _buildDetailRow(theme, 'Period', returnData['return_period']),
                _buildDetailRow(
                  theme,
                  'Filing Deadline',
                  dateFormat.format(
                    DateTime.parse(returnData['filing_deadline']),
                  ),
                ),
                _buildDetailRow(
                  theme,
                  'Total Sales',
                  '₹${NumberFormat('#,##,###.##').format(returnData['total_sales'])}',
                ),
                _buildDetailRow(
                  theme,
                  'GST Payable',
                  '₹${NumberFormat('#,##,###.##').format(returnData['gst_payable'])}',
                  isHighlight: true,
                ),
                _buildDetailRow(
                  theme,
                  'Status',
                  returnData['filing_status'].toString().toUpperCase(),
                ),
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showFilingDialog(returnData);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'File Return',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(
    ThemeData theme,
    String label,
    String value, {
    bool isHighlight = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isHighlight ? FontWeight.w600 : FontWeight.w500,
              color: isHighlight ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilingDialog(Map<String, dynamic> returnData) {
    showDialog(
      context: context,
      builder: (context) {
        final theme = Theme.of(context);
        return AlertDialog(
          title: Text('File GST Return'),
          content: Text(
            'Demo: This will simulate filing the GST return for ${returnData['return_period']}. In production, this would submit to the GST portal.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  final ackNumber =
                      'ACK-${DateTime.now().millisecondsSinceEpoch}';
                  await _gstService.submitGSTReturn(
                    returnData['id'],
                    ackNumber,
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'GST Return filed successfully! ACK: $ackNumber',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                  _loadGSTData();
                } catch (error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to file return: $error'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('File Return'),
            ),
          ],
        );
      },
    );
  }

  void _generateReturn() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo: Generating GST return from invoices...'),
      ),
    );
  }

  void _uploadInvoices() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Demo: Opening invoice upload interface...'),
      ),
    );
  }

  void _downloadCertificates() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo: Downloading GST certificates...')),
    );
  }

  void _scheduleReminders() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo: Setting up filing reminders...')),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('GST Settings'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('GSTIN: ${_gstSettings?['gstin'] ?? 'Not configured'}'),
              SizedBox(height: 1.h),
              Text('Business: ${_gstSettings?['business_name'] ?? 'N/A'}'),
              SizedBox(height: 1.h),
              Text(
                'Default Rate: ${_gstSettings?['default_gst_rate'] ?? '18'}%',
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('GST Filing Help'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'GST Filing Timeline:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),
                Text('• Monthly returns: Due by 20th of next month'),
                Text(
                  '• Quarterly returns: Due by 18th of month following quarter',
                ),
                Text('• Annual returns: Due by 31st December'),
                SizedBox(height: 1.5.h),
                Text(
                  'Important Notes:',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 1.h),
                Text(
                  '• This is a demo interface showing cloud-based GST management',
                ),
                Text('• Actual filing requires GST portal integration'),
                Text('• Contact support for production setup'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Got it'),
            ),
          ],
        );
      },
    );
  }
}
