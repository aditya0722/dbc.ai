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
import './widgets/notification_carousel_widget.dart';
import '../live_camera_view/live_camera_view.dart';
import '../inventory_management/inventory_management.dart';
import '../staff_management/staff_management.dart';

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
        return LiveCameraView();
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
  bool _showNotificationCarousel = true;

  final String businessName = "DBC Cafe & Bistro";
  final int notificationCount = 5;

  late List<NotificationItem> _notificationItems;

  // Primary metrics shown prominently on dashboard
  final List<Map<String, dynamic>> _primaryMetrics = [
    {
      "title": "Total Payments",
      "value": "\$2,450.00",
      "icon": "attach_money",
      "color": Color(0xFF6B46C1),
      "trend": "+12.5%",
      "trendUp": true,
      "route": "/payment-processing-center",
    },
    {
      "title": "Active Orders",
      "value": "24 Active",
      "icon": "restaurant",
      "color": Color(0xFF6B46C1),
      "trend": "+ 8 today",
      "trendUp": true,
      "route": "/order-management-hub",
    },
  ];

  // Management section - shown in 2x2 grid
  final List<Map<String, dynamic>> _managementMetrics = [
    {
      "title": "Staff",
      "value": "15/18 Present",
      "icon": "people",
      "color": Color(0xFF6B46C1),
      "iconBg": Color(0xFFEDE9FE),
      "valueColor": Color(0xFF1A1A1A),
      "route": "/staff-management",
    },
    {
      "title": "Inventory",
      "value": "12 Low Items",
      "icon": "inventory_2",
      "color": Color(0xFFF59E0B),
      "iconBg": Color(0xFFFEF3C7),
      "valueColor": Color(0xFFF59E0B),
      "route": "/inventory-management",
    },
    {
      "title": "Security",
      "value": "Active",
      "icon": "verified_user",
      "color": Color(0xFF10B981),
      "iconBg": Color(0xFFD1FAE5),
      "valueColor": Color(0xFF10B981),
      "route": "/live-camera-view",
    },
    {
      "title": "News",
      "value": "8 New Updates",
      "icon": "article",
      "color": Color(0xFF6B46C1),
      "iconBg": Color(0xFFEDE9FE),
      "valueColor": Color(0xFF6B6B6B),
      "route": "/news-updates-hub",
    },
  ];

  // Less important metrics - shown in the More tab
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

  // Less important items for More tab
  final List<Map<String, dynamic>> _moreMenuItems = [
    {
      "title": "GST Filing",
      "subtitle": "2 Pending · Due in 7 days",
      "icon": "account_balance",
      "color": Color(0xFFE11D48),
      "route": "/gst-filing-center",
    },
    {
      "title": "GST Reports",
      "subtitle": "Compliance & reports",
      "icon": "description",
      "color": Color(0xFF6366F1),
      "route": "/gst-reports",
    },
    {
      "title": "Payroll",
      "subtitle": "\$12,500 · Processing",
      "icon": "payments",
      "color": Color(0xFF06B6D4),
      "route": "/payroll-processing",
    },
    {
      "title": "Hiring",
      "subtitle": "5 Open · 12 applications",
      "icon": "work",
      "color": Color(0xFFF97316),
      "route": "/staff-hiring",
    },
    {
      "title": "Vendor Marketplace",
      "subtitle": "45 Products · 3 new vendors",
      "icon": "storefront",
      "color": Color(0xFF14B8A6),
      "route": "/marketplace-product-catalog",
    },
    {
      "title": "Data Migration",
      "subtitle": "2 Active · In progress",
      "icon": "swap_horiz",
      "color": Color(0xFF9C27B0),
      "route": AppRoutes.dataMigrationCenter,
    },
    {
      "title": "Security Alerts",
      "subtitle": "3 Active alerts",
      "icon": "warning",
      "color": Color(0xFFEF4444),
      "route": "/security-alerts-dashboard",
    },
    {
      "title": "Order Management",
      "subtitle": "24 Active · +8 today",
      "icon": "shopping_cart",
      "color": Color(0xFF8B5CF6),
      "route": "/order-management-hub",
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
    _initializeNotifications();
    _checkForSecurityAlerts();
    _loadUnreadNotificationCount();
  }

  void _initializeNotifications() {
    _notificationItems = [
      NotificationItem(
        title: 'Payment Received ✓',
        message: 'Customer paid \$2,450.00 for Invoice #INV-2024-001',
        icon: 'payment',
        color: const Color(0xFF10B981),
        displayDuration: 2,
      ),
      NotificationItem(
        title: 'Security Alert ⚠️',
        message: 'Unauthorized access detected in CCTV zone 3 - Please review',
        icon: 'security',
        color: const Color(0xFFEF4444),
        displayDuration: 5,
      ),
      NotificationItem(
        title: 'Low Inventory Alert',
        message: 'Espresso Beans stock below 10 units - Reorder recommended',
        icon: 'inventory',
        color: const Color(0xFFF59E0B),
        displayDuration: 3,
      ),
    ];
  }

  Future<void> _loadUnreadNotificationCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      if (mounted) {
        setState(() => _unreadNotificationCount = count);
      }
    } catch (e) {
      // Silent fail
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
      final hasShownInSession =
          await _sessionManager.wasAlertShownInCurrentSession();
      if (hasShownInSession) return;

      final count = await _alertsService.getActiveAlertsCount();
      setState(() => _activeAlertsCount = count);

      if (count > 0) {
        Future.delayed(const Duration(milliseconds: 500), () async {
          if (mounted) {
            _showSecurityNotification();
            await _sessionManager.markAlertAsShown();
          }
        });
      }
    } catch (e) {
      // Silent fail
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
                  Center(
                    child: Container(
                      margin: EdgeInsets.symmetric(vertical: 1.h),
                      width: 12.w,
                      height: 0.5.h,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),
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
                            return _buildTemplateCard(
                                context, theme, template);
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template['template_name'],
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
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
                style: theme.textTheme.titleLarge
                    ?.copyWith(fontWeight: FontWeight.w600),
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
                            borderRadius: BorderRadius.circular(8)),
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 1.5.h),
                    TextField(
                      controller: customerEmailController,
                      decoration: InputDecoration(
                        labelText: 'Customer Email',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
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
                            borderRadius: BorderRadius.circular(8)),
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
                          lastDate:
                              DateTime.now().add(Duration(days: 365)),
                        );
                        if (picked != null) {
                          setState(() => dueDate = picked);
                        }
                      },
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Due Date',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8)),
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
                            borderRadius: BorderRadius.circular(8)),
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

  // ─────────────────────────────────────────────────────────────
  // NEW DASHBOARD BUILD – matches Image 1 design
  // ─────────────────────────────────────────────────────────────

  Widget _buildDashboard() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 600;
        final isDesktop = constraints.maxWidth > 900;

        return RefreshIndicator(
          onRefresh: _handleRefresh,
          color: const Color(0xFF6B46C1),
          child: CustomScrollView(
            slivers: [
              // ── Always-present top spacing ──
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Notification Carousel (card-style wrapper) ──
              if (_showNotificationCarousel && _notificationItems.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: NotificationCarousel(
                      notifications: _notificationItems,
                      onDismiss: () {
                        setState(() => _showNotificationCarousel = false);
                      },
                    ),
                  ),
                ),

              // ── Welcome Header ──
              SliverToBoxAdapter(
                child: _buildWelcomeHeader(),
              ),

              // ── Active Security Alerts Banner ──
              if (_activeAlertsCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _buildAlertsBanner(),
                  ),
                ),

              // ── Primary Metric Cards (Payments + Orders) ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: isDesktop
                      ? Row(
                          children: _primaryMetrics
                              .map((m) => Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 12),
                                      child: _buildPrimaryMetricCard(m),
                                    ),
                                  ))
                              .toList(),
                        )
                      : Row(
                          children: _primaryMetrics
                              .map((m) => Expanded(
                                    child: Padding(
                                      padding: EdgeInsets.only(
                                        right: m == _primaryMetrics.last
                                            ? 0
                                            : 12,
                                      ),
                                      child: _buildPrimaryMetricCard(m),
                                    ),
                                  ))
                              .toList(),
                        ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Management Section Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Management',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() => _currentBottomNavIndex = 4);
                        },
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF6B46C1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // ── Management 2×2 Grid ──
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _managementMetrics[index];
                      return _buildManagementCard(item);
                    },
                    childCount: _managementMetrics.length,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isDesktop ? 4 : (isWide ? 3 : 2),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 130, // fixed height - same on all screen sizes
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // ── Featured Quick Action Banner ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildFeaturedBanner(),
                ),
              ),

              // ── Bottom padding for FAB ──
              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        );
      },
    );
  }

  /// Clean welcome header row
  Widget _buildWelcomeHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B6B6B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  businessName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF6B46C1),
                  ),
                ),
              ],
            ),
          ),
          // Search icon
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.search, color: Color(0xFF1A1A1A)),
              onPressed: () {},
            ),
          ),
          const SizedBox(width: 8),
          // Notification icon with badge
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Color(0xFF1A1A1A)),
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.notificationCenter)
                        .then((_) => _loadUnreadNotificationCount());
                  },
                ),
              ),
              if (_unreadNotificationCount > 0)
                Positioned(
                  right: 6,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 14,
                      minHeight: 14,
                    ),
                    child: Text(
                      _unreadNotificationCount > 99
                          ? '99+'
                          : _unreadNotificationCount.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
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
    );
  }

  /// Large primary metric card (Payments / Orders)
  Widget _buildPrimaryMetricCard(Map<String, dynamic> metric) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, metric['route']),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
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
                  metric['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B6B6B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  metric['trendUp'] == true
                      ? Icons.trending_up
                      : Icons.restaurant,
                  color: const Color(0xFF6B46C1),
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              metric['value'],
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.arrow_upward,
                  size: 12,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(width: 2),
                Text(
                  metric['trend'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Management 2×2 grid card
  Widget _buildManagementCard(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, item['route']),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start, // compact top-aligned
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item['iconBg'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(item['icon']),
                color: item['color'],
                size: 22,
              ),
            ),
            const SizedBox(height: 12), // fixed gap, not spaceBetween
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  item['value'],
                  style: TextStyle(
                    fontSize: 12,
                    color: item['valueColor'],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Security alerts inline banner
  Widget _buildAlertsBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$_activeAlertsCount CCTV Alert${_activeAlertsCount > 1 ? 's' : ''} Active',
              style: const TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.pushNamed(
                context, AppRoutes.securityAlertsDashboard),
            child: const Text(
              'View',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Featured promotional / quick-action banner (like "Plan your weekend menu")
  Widget _buildFeaturedBanner() {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/order-management-hub'),
      child: Container(
        height: 130,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6B46C1), Color(0xFF8B5CF6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Stack(
          children: [
            // Background icon decoration
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.15,
                child: Icon(
                  Icons.restaurant_menu,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Plan your weekend menu',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: const Text(
                      'NEW FEATURE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // UPDATED MORE TAB – includes less-important metrics
  // ─────────────────────────────────────────────────────────────
  Widget _buildMore() {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        // Account section
        _buildMoreSectionHeader('Account'),
        _buildMoreTile(
          icon: Icons.person_outline,
          iconColor: const Color(0xFF6B46C1),
          title: 'Profile',
          onTap: () {},
        ),
        _buildMoreTile(
          icon: Icons.settings_outlined,
          iconColor: const Color(0xFF6B46C1),
          title: 'Settings',
          onTap: () {},
        ),
        _buildMoreTile(
          icon: Icons.notifications_outlined,
          iconColor: const Color(0xFF6B46C1),
          title: 'Notifications',
          onTap: () =>
              Navigator.pushNamed(context, AppRoutes.notificationCenter),
        ),
        _buildMoreTile(
          icon: Icons.help_outline,
          iconColor: const Color(0xFF6B46C1),
          title: 'Help',
          onTap: () {},
        ),

        const SizedBox(height: 8),
        _buildMoreSectionHeader('Business Tools'),

        // Less-important metrics
        ..._moreMenuItems.map((item) => _buildMoreTile(
              icon: _getIconData(item['icon']),
              iconColor: item['color'],
              title: item['title'],
              subtitle: item['subtitle'],
              onTap: () => Navigator.pushNamed(context, item['route']),
            )),

        const Divider(height: 24, indent: 16, endIndent: 16),
        _buildMoreTile(
          icon: Icons.logout,
          iconColor: Colors.red,
          title: 'Logout',
          titleColor: Colors.red,
          onTap: () {},
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMoreSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Color(0xFF9E9E9E),
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildMoreTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor ?? const Color(0xFF1A1A1A),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF9E9E9E),
              ),
            )
          : null,
      trailing: Icon(
        Icons.chevron_right,
        color: const Color(0xFFBDBDBD),
        size: 20,
      ),
      onTap: onTap,
    );
  }

  /// Helper – maps icon name string to IconData
  IconData _getIconData(String name) {
    const map = {
      'people': Icons.people,
      'inventory_2': Icons.inventory_2,
      'verified_user': Icons.verified_user,
      'article': Icons.article,
      'attach_money': Icons.attach_money,
      'videocam': Icons.videocam,
      'account_balance': Icons.account_balance,
      'swap_horiz': Icons.swap_horiz,
      'shopping_cart': Icons.shopping_cart,
      'payments': Icons.payments,
      'work': Icons.work,
      'storefront': Icons.storefront,
      'warning': Icons.warning,
      'description': Icons.description,
      'restaurant': Icons.restaurant,
    };
    return map[name] ?? Icons.circle;
  }

  // ─────────────────────────────────────────────────────────────
  // Unused legacy placeholder builds (kept for safety)
  // ─────────────────────────────────────────────────────────────
  Widget _buildPlaceholder(String title) {
    return Center(
      child: Text(title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildSecurity() =>
      const Center(child: Text("Security Data Coming Here"));
  Widget _buildInventory() =>
      const Center(child: Text("Inventory Data Coming Here"));
  Widget _buildStaff() =>
      const Center(child: Text("Staff Data Coming Here"));

  // ─────────────────────────────────────────────────────────────
  // SCAFFOLD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // AppBar hidden on Home tab – header is inline
      appBar: _currentBottomNavIndex == 0
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                _getAppBarTitle(),
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              actions: [
                Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.notifications_outlined,
                          color: Color(0xFF1A1A1A)),
                      onPressed: () {
                        Navigator.pushNamed(
                                context, AppRoutes.notificationCenter)
                            .then((_) => _loadUnreadNotificationCount());
                      },
                    ),
                    if (_unreadNotificationCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
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
          setState(() => _currentBottomNavIndex = index);
        },
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  String _getAppBarTitle() {
    switch (_currentBottomNavIndex) {
      case 1:
        return 'Security';
      case 2:
        return 'Inventory';
      case 3:
        return 'Staff';
      case 4:
        return 'More';
      default:
        return 'Dashboard';
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isRefreshing = false);
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
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  metricTitle,
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                ListTile(
                  leading: CustomIconWidget(
                    iconName: 'file_download',
                    color: theme.colorScheme.primary,
                    size: 24,
                  ),
                  title:
                      Text("Export Data", style: theme.textTheme.bodyLarge),
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
                  title:
                      Text("Set Alerts", style: theme.textTheme.bodyLarge),
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

  void _showQuickAddBottomSheet(BuildContext context) {
    final theme = Theme.of(context);
    final List<Map<String, dynamic>> quickAddOptions = [
      {
        "title": "Add Camera",
        "icon": "videocam",
        "route": "/live-camera-view"
      },
      {
        "title": "Add Inventory Item",
        "icon": "inventory_2",
        "route": "/inventory-management"
      },
      {
        "title": "Add Staff Member",
        "icon": "person_add",
        "route": "/staff-management"
      },
      {
        "title": "Record Attendance",
        "icon": "how_to_reg",
        "route": "/staff-management"
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
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  "Bill",
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 2.h),
                ...quickAddOptions.map(
                  (option) => ListTile(
                    leading: CustomIconWidget(
                      iconName: option["icon"] as String,
                      color: theme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(option["title"] as String,
                        style: theme.textTheme.bodyLarge),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.pushNamed(
                          context, option["route"] as String);
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