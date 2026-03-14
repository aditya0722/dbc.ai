import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../routes/app_routes.dart';
import './widgets/module_filter_chip_widget.dart';
import './widgets/workflow_node_widget.dart';
import './widgets/workflow_search_widget.dart';

class AppWorkflowOverview extends StatefulWidget {
  const AppWorkflowOverview({super.key});

  @override
  State<AppWorkflowOverview> createState() => _AppWorkflowOverviewState();
}

class _AppWorkflowOverviewState extends State<AppWorkflowOverview> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All';
  final TransformationController _transformationController =
      TransformationController();

  final List<Map<String, dynamic>> _workflowModules = [
    {
      'name': 'Security',
      'color': Colors.red,
      'icon': Icons.security,
      'screens': [
        {
          'title': 'Security Alerts Dashboard',
          'route': AppRoutes.securityAlertsDashboard,
          'description': 'Monitor and manage security incidents in real-time',
        },
        {
          'title': 'Security Events History',
          'route': AppRoutes.securityEventsHistory,
          'description': 'View historical security event logs and analytics',
        },
        {
          'title': 'Live Camera View',
          'route': AppRoutes.liveCameraView,
          'description': 'Real-time surveillance camera monitoring',
        },
      ],
      'connections': ['Notifications', 'Staff Management'],
    },
    {
      'name': 'Inventory',
      'color': Colors.blue,
      'icon': Icons.inventory,
      'screens': [
        {
          'title': 'Inventory Management',
          'route': AppRoutes.inventoryManagement,
          'description': 'Track stock levels and manage inventory',
        },
        {
          'title': 'Marketplace Product Catalog',
          'route': AppRoutes.marketplaceProductCatalog,
          'description': 'Browse and order products from suppliers',
        },
      ],
      'connections': ['Marketplace', 'Orders'],
    },
    {
      'name': 'Staff Management',
      'color': Colors.green,
      'icon': Icons.people,
      'screens': [
        {
          'title': 'Staff Management',
          'route': AppRoutes.staffManagement,
          'description': 'Manage employee records and schedules',
        },
        {
          'title': 'Staff Hiring',
          'route': AppRoutes.staffHiring,
          'description': 'Post job positions and manage applications',
        },
        {
          'title': 'Hiring Marketplace',
          'route': AppRoutes.hiringMarketplace,
          'description': 'Browse and recruit talented candidates',
        },
        {
          'title': 'Payroll Processing',
          'route': AppRoutes.payrollProcessing,
          'description': 'Calculate and process employee salaries',
        },
      ],
      'connections': ['Finance', 'Notifications'],
    },
    {
      'name': 'Finance',
      'color': Colors.purple,
      'icon': Icons.account_balance,
      'screens': [
        {
          'title': 'Payment Processing',
          'route': AppRoutes.paymentProcessingCenter,
          'description': 'Process customer payments and transactions',
        },
        {
          'title': 'GST Filing Center',
          'route': AppRoutes.gstFilingCenter,
          'description': 'Manage GST returns and compliance',
        },
        {
          'title': 'GST Reports',
          'route': AppRoutes.gstReports,
          'description': 'Generate detailed GST reports and analytics',
        },
      ],
      'connections': ['Orders', 'Marketplace'],
    },
    {
      'name': 'Marketplace',
      'color': Colors.orange,
      'icon': Icons.store,
      'screens': [
        {
          'title': 'Vendor Marketplace',
          'route': AppRoutes.vendorMarketplace,
          'description': 'Connect with verified suppliers and vendors',
        },
      ],
      'connections': ['Inventory', 'Finance'],
    },
    {
      'name': 'Orders',
      'color': Colors.teal,
      'icon': Icons.receipt_long,
      'screens': [
        {
          'title': 'Order Management Hub',
          'route': AppRoutes.orderManagementHub,
          'description': 'Track and manage customer orders',
        },
      ],
      'connections': ['Inventory', 'Finance'],
    },
    {
      'name': 'Notifications',
      'color': Colors.indigo,
      'icon': Icons.notifications,
      'screens': [
        {
          'title': 'Notification Center',
          'route': AppRoutes.notificationCenter,
          'description': 'View all system and business notifications',
        },
        {
          'title': 'Notification Settings',
          'route': AppRoutes.notificationSettings,
          'description': 'Customize notification preferences',
        },
      ],
      'connections': ['Security', 'Staff Management', 'Orders'],
    },
    {
      'name': 'News & Updates',
      'color': Colors.cyan,
      'icon': Icons.newspaper,
      'screens': [
        {
          'title': 'News Updates Hub',
          'route': AppRoutes.newsUpdatesHub,
          'description': 'Stay updated with industry news',
        },
      ],
      'connections': [],
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    _transformationController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredModules {
    return _workflowModules.where((module) {
      final matchesFilter =
          _selectedFilter == 'All' || module['name'] == _selectedFilter;
      final matchesSearch = _searchQuery.isEmpty ||
          module['name'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (module['screens'] as List).any(
            (screen) => screen['title'].toLowerCase().contains(
                  _searchQuery.toLowerCase(),
                ),
          );
      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: Text(
          'App Workflow Overview',
          style: TextStyle(
            color: Colors.grey[900],
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey[900]),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline, color: Colors.grey[700]),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_in, color: Colors.grey[700]),
            onPressed: () {
              _transformationController.value =
                  _transformationController.value.scaled(1.2);
            },
          ),
          IconButton(
            icon: Icon(Icons.zoom_out, color: Colors.grey[700]),
            onPressed: () {
              _transformationController.value =
                  _transformationController.value.scaled(0.8);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.delayed(const Duration(seconds: 1));
          setState(() {});
        },
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: EdgeInsets.all(2.w),
              child: Column(
                children: [
                  WorkflowSearchWidget(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                  ),
                  SizedBox(height: 1.h),
                  SizedBox(
                    height: 5.h,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        ModuleFilterChipWidget(
                          label: 'All',
                          isSelected: _selectedFilter == 'All',
                          onSelected: () {
                            setState(() {
                              _selectedFilter = 'All';
                            });
                          },
                        ),
                        ..._workflowModules.map((module) {
                          return ModuleFilterChipWidget(
                            label: module['name'],
                            isSelected: _selectedFilter == module['name'],
                            color: module['color'],
                            onSelected: () {
                              setState(() {
                                _selectedFilter = module['name'];
                              });
                            },
                          );
                        }),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredModules.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 20.w,
                            color: Colors.grey[400],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'No modules found',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : InteractiveViewer(
                      transformationController: _transformationController,
                      minScale: 0.5,
                      maxScale: 3.0,
                      boundaryMargin: EdgeInsets.all(10.w),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(3.w),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(12.0),
                                border: Border.all(
                                  color: Colors.blue[200]!,
                                  width: 2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.rocket_launch,
                                    color: Colors.blue[700],
                                    size: 6.w,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Start: Splash Screen → Business Dashboard',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[900],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 3.h),
                            ..._filteredModules.map((module) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 3.h),
                                child: WorkflowNodeWidget(
                                  module: module,
                                  onScreenTap: (route) {
                                    Navigator.pushNamed(context, route);
                                  },
                                ),
                              );
                            }),
                            if (_filteredModules.length > 1)
                              Container(
                                margin: EdgeInsets.only(top: 2.h),
                                padding: EdgeInsets.all(2.w),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.account_tree,
                                      color: Colors.grey[700],
                                      size: 8.w,
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Module Connections',
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[800],
                                      ),
                                    ),
                                    SizedBox(height: 1.h),
                                    Text(
                                      'Data flows between connected modules\nfor seamless business operations',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showGuidedTour(context);
        },
        backgroundColor: Colors.blue[700],
        icon: const Icon(Icons.tour),
        label: const Text('Start Guided Tour'),
      ),
    );
  }

  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Workflow Overview Help'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '🎯 How to Use:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('• Tap on any screen card to navigate directly'),
              const Text('• Use search to find specific features'),
              const Text('• Filter by module to view specific workflows'),
              const Text('• Pinch to zoom in/out of workflow diagram'),
              const Text('• Pull down to refresh workflow data'),
              const SizedBox(height: 16),
              const Text(
                '🎨 Color Codes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildColorLegend('Security', Colors.red),
              _buildColorLegend('Inventory', Colors.blue),
              _buildColorLegend('Staff', Colors.green),
              _buildColorLegend('Finance', Colors.purple),
              _buildColorLegend('Marketplace', Colors.orange),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  Widget _buildColorLegend(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
    );
  }

  void _showGuidedTour(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 70.h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue[700]!, Colors.blue[500]!],
                ),
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.tour, color: Colors.white, size: 7.w),
                  SizedBox(width: 2.w),
                  Text(
                    'Guided Tour',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.all(3.w),
                children: [
                  _buildTourStep(
                    '1. Start Your Journey',
                    'Begin at Business Dashboard to view overall metrics',
                    Icons.dashboard,
                    Colors.blue,
                  ),
                  _buildTourStep(
                    '2. Monitor Security',
                    'Check Security Alerts for real-time incident monitoring',
                    Icons.security,
                    Colors.red,
                  ),
                  _buildTourStep(
                    '3. Manage Inventory',
                    'Track stock levels and place orders when needed',
                    Icons.inventory,
                    Colors.blue,
                  ),
                  _buildTourStep(
                    '4. Handle Staff',
                    'Manage employees, hiring, and process payroll',
                    Icons.people,
                    Colors.green,
                  ),
                  _buildTourStep(
                    '5. Process Orders',
                    'Track customer orders from placement to delivery',
                    Icons.receipt_long,
                    Colors.teal,
                  ),
                  _buildTourStep(
                    '6. Financial Management',
                    'Process payments and file GST returns on time',
                    Icons.account_balance,
                    Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTourStep(
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 6.w),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
