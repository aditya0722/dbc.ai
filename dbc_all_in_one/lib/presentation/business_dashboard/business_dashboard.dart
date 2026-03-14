import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/invoicing_service.dart';
import '../../services/notification_service.dart';
import '../../services/security_alerts_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/business_header_widget.dart';
import './widgets/metrics_card_widget.dart';
import './widgets/quick_action_card_widget.dart';
import './widgets/security_notification_widget.dart';
import '../live_camera_view/live_camera_view.dart';
import '../inventory_management/inventory_management.dart';
import '../staff_management/staff_management.dart';

/// Business Dashboard - Central command center for small business operations
/// Optimized for quick mobile oversight and critical task access
class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({super.key});

  @override   
  State<BusinessDashboard> createState() => _BusinessDashboardState();

}

class _BusinessDashboardState extends State<BusinessDashboard> {
  Widget _getScreen() {
  switch (_currentBottomNavIndex) {
    case 0:
      return _buildDashboard();
    case 1:
      return LiveCameraView(); // loads only when opened
    case 2:
      return InventoryManagement();
    case 3:
      return StaffManagement();
    case 4:
      return _buildMore();
    default:
      return _buildDashboard();
  }
}

  int _currentBottomNavIndex = 0;
  bool _isRefreshing = false;

  // Mock business data
  final String businessName = "DBC Cafe & Bistro";
  final int notificationCount = 5;

  // Mock metrics data - Comprehensive business overview
  final List<Map<String, dynamic>> metricsData = [
    {
      "title": "Payments",
      "value": "\$2,450.00",
      "icon": "attach_money",
      "color": Color(0xFF10B981),
      "trend": "+12.5%",
      "route": "/payment-processing-center",
    },
    {
      "title": "CCTV & Security",
      "value": "8/10",
      "icon": "videocam",
      "color": Color(0xFF6B46C1),
      "trend": "2 offline",
      "route": "/live-camera-view",
    },
    {
      "title": "Inventory",
      "value": "12 Low",
      "icon": "inventory_2",
      "color": Color(0xFFF59E0B),
      "trend": "Needs attention",
      "route": "/inventory-management",
    },
    {
      "title": "Staff Management",
      "value": "15/18",
      "icon": "people",
      "color": Color(0xFF0EA5E9),
      "trend": "3 absent",
      "route": "/staff-management",
    },
    {
      "title": "GST Filing",
      "value": "2 Pending",
      "icon": "account_balance",
      "color": Color(0xFFE11D48),
      "trend": "Due in 7 days",
      "route": "/gst-filing-center",
    },
    {
      "title": "Data Migration",
      "value": "2 Active",
      "icon": "swap_horiz",
      "color": Color(0xFF9C27B0),
      "trend": "In progress",
      "route": "/data-migration-center",
    },
    {
      "title": "News & Updates",
      "value": "8 New",
      "icon": "article",
      "color": Color(0xFFEC4899),
      "trend": "Today",
      "route": "/news-updates-hub",
    },
    {
      "title": "Orders",
      "value": "24 Active",
      "icon": "shopping_cart",
      "color": Color(0xFF8B5CF6),
      "trend": "+8 today",
      "route": "/order-management-hub",
    },
    {
      "title": "Payroll",
      "value": "\$12,500",
      "icon": "payments",
      "color": Color(0xFF06B6D4),
      "trend": "Processing",
      "route": "/payroll-processing",
    },
    {
      "title": "Hiring",
      "value": "5 Open",
      "icon": "work",
      "color": Color(0xFFF97316),
      "trend": "12 applications",
      "route": "/staff-hiring",
    },
    {
      "title": "Marketplace",
      "value": "45 Products",
      "icon": "storefront",
      "color": Color(0xFF14B8A6),
      "trend": "3 new vendors",
      "route": "/marketplace-product-catalog",
    },
    {
      "title": "Security Alerts",
      "value": "3 Active",
      "icon": "warning",
      "color": Color(0xFFEF4444),
      "trend": "View all",
      "route": "/security-alerts-dashboard",
    },
    {
      "title": "GST Reports",
      "value": "Generate",
      "icon": "description",
      "color": Color(0xFF6366F1),
      "trend": "Compliance",
      "route": "/gst-reports",
    },
  ];

  // Mock quick actions data - Essential operations
  List<Map<String, dynamic>> get _quickActions => [
        {
  "title": "Invoices",
  "icon": "receipt_long",
  "color": const Color(0xFF10B981),
  "route": AppRoutes.invoiceManagementCenter,
},
        {
          "title": "View Live Cameras",
          "icon": "videocam",
          "color": Color(0xFF6B46C1),
          "route": "/live-camera-view",
        },
        {
          "title": "News & Updates",
          "icon": "article",
          "color": Color(0xFFEC4899),
          "route": "/news-updates-hub",
        },
        {
          "title": "Add Inventory",
          "icon": "add_box",
          "color": Color(0xFF10B981),
          "route": "/inventory-management",
        },
        {
          "title": "Mark Attendance",
          "icon": "how_to_reg",
          "color": Color(0xFF0EA5E9),
          "route": "/staff-management",
        },
        {
          "title": "Emergency Alerts",
          "icon": "warning",
          "color": Color(0xFFEF4444),
          "route": "/security-events-history",
        },
        {
          "title": "Process Orders",
          "icon": "shopping_cart",
          "color": Color(0xFF8B5CF6),
          "route": "/order-management-hub",
        },
        {
          "title": "Hiring Portal",
          "icon": "work",
          "color": Color(0xFFF97316),
          "route": "/hiring-marketplace",
        },
        {
          "title": "Vendor Marketplace",
          "icon": "storefront",
          "color": Color(0xFF14B8A6),
          "route": "/vendor-marketplace",
        },
        {
  "title": "Data Migration",
  "icon": "swap_horiz",
  "color": const Color(0xFF9C27B0),
  "route": AppRoutes.dataMigrationCenter,
},

      ];

  final SecurityAlertsService _alertsService = SecurityAlertsService();
  final SessionManager _sessionManager = SessionManager();
  final NotificationService _notificationService = NotificationService();
  int _activeAlertsCount = 0;
  OverlayEntry? _notificationOverlay;
  int _unreadNotificationCount = 0;

  @override
  void initState() {
    super.initState();
    _checkForSecurityAlerts();
    _loadUnreadNotificationCount();
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() => _unreadNotificationCount = count);
      }
    } catch (e) {
      // Silent fail - notification count is not critical
    }
  }

  @override
  void dispose() {
    _notificationOverlay?.remove();
    _notificationOverlay = null;
    super.dispose();
  }

  Future<void> _checkForSecurityAlerts() async {
    try {
      // Check if alert was already shown in current session
      final hasShownInSession =
          await _sessionManager.wasAlertShownInCurrentSession();

      if (hasShownInSession) {
        return; // Don't show notification if already shown in this session
      }

      final count = await _alertsService.getActiveAlertsCount();
      setState(() => _activeAlertsCount = count);

      if (count > 0) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            _showSecurityNotification();
            // Mark alert as shown for current session
            await _sessionManager.markAlertAsShown();
          }
        });
      }
    } catch (e) {
      // Silent fail - don't block dashboard loading
    }
  }

  void _showSecurityNotification() {
    _notificationOverlay?.remove();

    _notificationOverlay = OverlayEntry(
      builder: (context) => SecurityNotificationWidget(
        alertsCount: _activeAlertsCount,
        onTap: () {
          _notificationOverlay?.remove();
          _notificationOverlay = null;
          Navigator.pushNamed(context, AppRoutes.securityAlertsDashboard);
        },
        onDismiss: () {
          _notificationOverlay?.remove();
          _notificationOverlay = null;
        },
      ),
    );

    Overlay.of(context).insert(_notificationOverlay!);
  }

  /// Show invoice templates bottom sheet
  void _showInvoiceTemplatesBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  // Handle bar
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 1.h),
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
                  SizedBox(height: 1.h),
                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Choose Invoice Template",
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        IconButton(
                          icon: CustomIconWidget(
                            iconName: 'close',
                            color: theme.colorScheme.onSurface,
                            size: 24,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 1.h),
                  // Templates list
                  Expanded(
                    child: FutureBuilder<List<Map<String, dynamic>>>(
                      future: InvoicingService().getInvoiceTemplates(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return Center(
                            child: CircularProgressIndicator(
                              color: theme.colorScheme.primary,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'error',
                                  color: theme.colorScheme.error,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Failed to load templates',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          );
                        }

                        final templates = snapshot.data ?? [];
                        if (templates.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CustomIconWidget(
                                  iconName: 'description',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 48,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No templates available',
                                  style: theme.textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          );
                        }

                        return ListView.builder(
                          controller: scrollController,
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 1.h,
                          ),
                          itemCount: templates.length,
                          itemBuilder: (context, index) {
                            final template = templates[index];
                            return _buildTemplateCard(context, theme, template);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// Build template card widget
  Widget _buildTemplateCard(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> template,
  ) {
    final categoryColors = {
      'restaurant': Color(0xFFE74C3C),
      'retail': Color(0xFF3498DB),
      'services': Color(0xFF16A085),
      'general': Color(0xFF95A5A6),
    };

    final categoryIcons = {
      'restaurant': 'restaurant',
      'retail': 'shopping_cart',
      'services': 'work',
      'general': 'description',
    };

    final category = template['category'] as String;
    final color = categoryColors[category] ?? Color(0xFF95A5A6);
    final icon = categoryIcons[category] ?? 'description';

    return Card(
      margin: EdgeInsets.only(bottom: 1.5.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.pop(context);
          _showInvoiceCreationDialog(context, template);
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(3.w),
          child: Row(
            children: [
              // Template preview image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 20.w,
                  height: 20.w,
                  child: template['preview_image_url'] != null
                      ? CachedNetworkImage(
                          imageUrl: template['preview_image_url'],
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: color.withValues(alpha: 0.1),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: color,
                                strokeWidth: 2,
                              ),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: color.withValues(alpha: 0.1),
                            child: CustomIconWidget(
                              iconName: icon,
                              color: color,
                              size: 32,
                            ),
                          ),
                        )
                      : Container(
                          color: color.withValues(alpha: 0.1),
                          child: CustomIconWidget(
                            iconName: icon,
                            color: color,
                            size: 32,
                          ),
                        ),
                ),
              ),
              SizedBox(width: 3.w),
              // Template info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template['template_name'],
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 0.5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 2.w,
                        vertical: 0.5.h,
                      ),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        category.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(
                      template['description'] ?? '',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 2.w),
              // Arrow icon
              CustomIconWidget(
                iconName: 'arrow_forward',
                color: theme.colorScheme.primary,
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show invoice creation dialog
  void _showInvoiceCreationDialog(
    BuildContext context,
    Map<String, dynamic> template,
  ) {
    final theme = Theme.of(context);
    final customerNameController = TextEditingController();
    final customerEmailController = TextEditingController();
    final customerPhoneController = TextEditingController();
    final notesController = TextEditingController();
    DateTime dueDate = DateTime.now().add(const Duration(days: 30));

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                'Create Invoice',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Template: ${template['template_name']}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: customerNameController,
                      decoration: InputDecoration(
                        labelText: 'Customer Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    TextField(
                      controller: customerEmailController,
                      decoration: InputDecoration(
                        labelText: 'Customer Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 1.5.h),
                    TextField(
                      controller: customerPhoneController,
                      decoration: InputDecoration(
                        labelText: 'Customer Phone',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 1.5.h),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: dueDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() {
                            dueDate = picked;
                          });
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          prefixIcon: Icon(Icons.calendar_today),
                        ),
                        child: Text(
                          '${dueDate.day}/${dueDate.month}/${dueDate.year}',
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: 'Notes (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.note),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (customerNameController.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please enter customer name'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                      return;
                    }

                    try {
                      await InvoicingService().createInvoiceFromTemplate(
                        templateId: template['id'],
                        customerName: customerNameController.text.trim(),
                        customerEmail:
                            customerEmailController.text.trim().isEmpty
                                ? null
                                : customerEmailController.text.trim(),
                        customerPhone:
                            customerPhoneController.text.trim().isEmpty
                                ? null
                                : customerPhoneController.text.trim(),
                        dueDate: dueDate,
                        notes: notesController.text.trim().isEmpty
                            ? null
                            : notesController.text.trim(),
                      );

                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Invoice created successfully!'),
                          backgroundColor: theme.colorScheme.primary,
                        ),
                      );
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to create invoice: $error'),
                          backgroundColor: theme.colorScheme.error,
                        ),
                      );
                    }
                  },
                  child: Text('Create Invoice'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showCreateInvoiceDialog() {
    final TextEditingController customerNameController =
        TextEditingController();
    final TextEditingController customerEmailController =
        TextEditingController();
    final TextEditingController amountController = TextEditingController();
    final TextEditingController notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.receipt_long, color: Color(0xFF10B981)),
            SizedBox(width: 2.w),
            Text('Create Invoice', style: TextStyle(fontSize: 16.sp)),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: customerNameController,
                decoration: InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: customerEmailController,
                decoration: InputDecoration(
                  labelText: 'Customer Email (Optional)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: notesController,
                decoration: InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (customerNameController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter customer name')),
                );
                return;
              }

              try {
                final invoiceService = InvoicingService();
                await invoiceService.createInvoiceFromTemplate(
                  templateId: 'default',
                  customerName: customerNameController.text,
                  customerEmail: customerEmailController.text.isEmpty
                      ? null
                      : customerEmailController.text,
                  dueDate: DateTime.now().add(Duration(days: 30)),
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                );

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Invoice created successfully!'),
                    backgroundColor: Color(0xFF10B981),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error creating invoice: $e')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF10B981),
            ),
            child: Text('Create'),
          ),
        ],
      ),
    );
  }
  Widget _buildPlaceholder(String title) {
  return Center(
    child: Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}
Widget _buildDashboard() {
  final theme = Theme.of(context);

  return RefreshIndicator(
    onRefresh: _handleRefresh,
    child: CustomScrollView(
      slivers: [

        // Header
        SliverToBoxAdapter(
          child: BusinessHeaderWidget(
            businessName: businessName,
            notificationCount: 0,
            onNotificationTap: () {},
          ),
        ),
        /// 🚨 CCTV ALERT CARD
if (_activeAlertsCount > 0)
  SliverToBoxAdapter(
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red),
        ),
        child: Row(
          children: [
            const Icon(Icons.warning, color: Colors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                "$_activeAlertsCount CCTV Alerts Active",
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.securityAlertsDashboard,
                );
              },
              child: const Text("View"),
            )
          ],
        ),
      ),
    ),
  ),

        // Metrics
        SliverToBoxAdapter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: metricsData.length,
            itemBuilder: (context, index) {
              final metric = metricsData[index];
              return MetricsCardWidget(
                title: metric["title"],
                value: metric["value"],
                icon: metric["icon"],
                color: metric["color"],
                trend: metric["trend"],
                onTap: () {
                  Navigator.pushNamed(context, metric["route"]);
                },
              );
            },
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _quickActions.length,
            itemBuilder: (context, index) {
              final action = _quickActions[index];
              return QuickActionCardWidget(
                title: action["title"],
                icon: action["icon"],
                color: action["color"],
                onTap: () {
                  Navigator.pushNamed(context, action["route"]);
                },
              );
            },
          ),
        ),
      ],
    ),
  );
}
Widget _buildSecurity() {
  return Center(
    child: Text("Security Data Coming Here"),
  );
}

Widget _buildInventory() {
  return Center(
    child: Text("Inventory Data Coming Here"),
  );
}

Widget _buildStaff() {
  return Center(
    child: Text("Staff Data Coming Here"),
  );
}
Widget _buildMore() {
  return ListView(
    children: [
      ListTile(
        leading: Icon(Icons.person),
        title: Text("Profile"),
        onTap: () {},
      ),
      ListTile(
        leading: Icon(Icons.settings),
        title: Text("Settings"),
        onTap: () {},
      ),
      ListTile(
        leading: Icon(Icons.notifications),
        title: Text("Notifications"),
        onTap: () {},
      ),
      ListTile(
        leading: Icon(Icons.help),
        title: Text("Help"),
        onTap: () {},
      ),
      ListTile(
        leading: Icon(Icons.logout, color: Colors.red),
        title: Text("Logout"),
        onTap: () {},
      ),
    ],
  );
}
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Business Dashboard",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    AppRoutes.notificationCenter,
                  ).then((_) => _loadUnreadNotificationCount());
                },
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      _unreadNotificationCount > 99
                          ? '99+'
                          : _unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
body: _getScreen(),
     floatingActionButton: FloatingActionButton.extended(
  onPressed: _showCreateInvoiceDialog,
  backgroundColor: const Color(0xFF10B981),
  icon: const Icon(Icons.receipt_long),
  label: const Text('Bill'),
),


      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          setState(() {
            _currentBottomNavIndex = index;
          });
        },
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  /// Handle pull-to-refresh
  Future<void> _handleRefresh() async {
    setState(() {
      _isRefreshing = true;
    });

    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isRefreshing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Dashboard refreshed successfully"),
          backgroundColor: Theme.of(context).colorScheme.primary,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  /// Show quick actions bottom sheet for metric cards
  void _showQuickActionsBottomSheet(BuildContext context, String metricTitle) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
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
                  metricTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'file_download',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text("Export Data", style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Exporting $metricTitle data..."),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'notifications_active',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title: Text("Set Alerts", style: theme.textTheme.bodyLarge),
                  onTap: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Setting alerts for $metricTitle..."),
                        backgroundColor: theme.colorScheme.primary,
                      ),
                    );
                  },
                ),
                SizedBox(height: 2.h),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Show quick add bottom sheet
  void _showQuickAddBottomSheet(BuildContext context) {
    final theme = Theme.of(context);

    final List<Map<String, dynamic>> quickAddOptions = [
      {"title": "Add Camera", "icon": "videocam", "route": "/live-camera-view"},
      {
        "title": "Add Inventory Item",
        "icon": "inventory_2",
        "route": "/inventory-management",
      },
      {
        "title": "Add Staff Member",
        "icon": "person_add",
        "route": "/staff-management",
      },
      {
        "title": "Record Attendance",
        "icon": "how_to_reg",
        "route": "/staff-management",
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
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
                  "Bill",
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2.h),
                ...quickAddOptions.map(
                  (option) => ListTile(
                    leading: CustomIconWidget(
                      iconName: option["icon"] as String,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(
                      option["title"] as String,
                      style: theme.textTheme.bodyLarge,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(context, option["route"] as String);
                    },
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
}