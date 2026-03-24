import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/security_alerts_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../live_camera_view/live_camera_view.dart';
import '../inventory_management/inventory_management.dart';
import '../staff_management/staff_management.dart';
import './widgets/security_notification_widget.dart';
import './widgets/desktop_sidebar_widget.dart';
import './widgets/desktop_right_panel_widget.dart';
import './widgets/dashboard_tab_widget.dart';
import './widgets/more_tab_widget.dart';
import './widgets/show_create_invoice_dialog.dart';
import '../../services/app_notifications.dart';
import '../../core/app_notification.dart';

class BusinessDashboard extends StatefulWidget {
  const BusinessDashboard({super.key});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  int _currentNavIndex = 0;

  final String businessName = "DBC Cafe & Bistro";

  final SecurityAlertsService _alertsService = SecurityAlertsService();
  final SessionManager _sessionManager = SessionManager();

  int _activeAlertsCount = 0;
  OverlayEntry? _securityOverlay;

  static const _navItems = [
    {'icon': Icons.home_outlined, 'activeIcon': Icons.home, 'label': 'Home'},
    {
      'icon': Icons.security_outlined,
      'activeIcon': Icons.security,
      'label': 'Security'
    },
    {
      'icon': Icons.inventory_2_outlined,
      'activeIcon': Icons.inventory_2,
      'label': 'Stock'
    },
    {
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
      'label': 'Staff'
    },
    {'icon': Icons.more_horiz, 'activeIcon': Icons.more_horiz, 'label': 'More'},
  ];

  @override
  void initState() {
    super.initState();

    _checkForSecurityAlerts();

    // 🔥 AUTO DEMO NOTIFICATIONS
    _triggerDemoNotifications();
  }

  void _triggerDemoNotifications() {
    // Delay ensures UI is fully built
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;

      AppNotifications.show(
        context,
        AppNotification(
          message: "₹1,250 payment received successfully",
          type: AppNotificationType.payment,
        ),
      );
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;

      AppNotifications.show(
        context,
        AppNotification(
          message: "Motion detected near entrance",
          type: AppNotificationType.security,
        ),
      );
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;

      AppNotifications.show(
        context,
        AppNotification(
          message: "Only 5 items left in stock",
          type: AppNotificationType.inventory,
        ),
      );
    });

    Future.delayed(const Duration(seconds: 7), () {
      if (!mounted) return;

      AppNotifications.show(
        context,
        AppNotification(
          message: "Rahul marked absent today",
          type: AppNotificationType.employee,
        ),
      );
    });
  }

  @override
  void dispose() {
    _securityOverlay?.remove();
    _securityOverlay = null;
    super.dispose();
  }

  Future<void> _checkForSecurityAlerts() async {
    try {
      final hasShown = await _sessionManager.wasAlertShownInCurrentSession();
      if (hasShown) return;
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
    } catch (_) {}
  }

  void _showSecurityNotification() {
    _securityOverlay?.remove();
    _securityOverlay = OverlayEntry(
      builder: (context) => SecurityNotificationWidget(
        alertsCount: _activeAlertsCount,
        onTap: () {
          _securityOverlay?.remove();
          _securityOverlay = null;
          Navigator.pushNamed(context, AppRoutes.securityAlertsDashboard);
        },
        onDismiss: () {
          _securityOverlay?.remove();
          _securityOverlay = null;
        },
      ),
    );
    Overlay.of(context).insert(_securityOverlay!);
  }

  // ─────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 700;
        return isDesktop ? _buildDesktopScaffold() : _buildMobileScaffold();
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // DESKTOP: sidebar | constrained content | right panel
  // ─────────────────────────────────────────────────────────────
  Widget _buildDesktopScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Row(
        children: [
          // Left sidebar — no notification count needed
          DesktopSidebarWidget(
            currentIndex: _currentNavIndex,
            navItems: _navItems,
            onTap: (i) => setState(() => _currentNavIndex = i),
          ),

          // Center content — capped at 780px
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 780),
                child: Stack(
                  children: [
                    _getScreen(),
                    Positioned(
                      bottom: 24,
                      right: 24,
                      child: FloatingActionButton.extended(
                        onPressed: () => showCreateInvoiceDialog(context),
                        backgroundColor: const Color(0xFF10B981),
                        icon: const Icon(Icons.receipt_long),
                        label: const Text('Bill'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Right panel — no notification count needed
          const DesktopRightPanelWidget(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // MOBILE: bottom nav bar
  // ─────────────────────────────────────────────────────────────
  Widget _buildMobileScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: _currentNavIndex == 0
          ? null
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: Text(
                _getAppBarTitle(),
                style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 18),
              ),
            ),
      body: _getScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateInvoiceDialog(context),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Bill'),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentNavIndex,
        onTap: (i) => setState(() => _currentNavIndex = i),
        variant: CustomBottomBarVariant.standard,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // SCREEN ROUTER
  // ─────────────────────────────────────────────────────────────
  Widget _getScreen() {
    switch (_currentNavIndex) {
      case 0:
        return DashboardTabWidget(
          businessName: businessName,
          activeAlertsCount: _activeAlertsCount,
          onViewAll: () => setState(() => _currentNavIndex = 4),
          onRefresh: _handleRefresh,
        );
      case 1:
        return const LiveCameraView();
      case 2:
        return const InventoryManagement();
      case 3:
        return const StaffManagement();
      case 4:
        return const MoreTabWidget();
      default:
        return const SizedBox();
    }
  }

  String _getAppBarTitle() {
    switch (_currentNavIndex) {
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
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Dashboard refreshed successfully'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        duration: const Duration(seconds: 2),
      ));
    }
  }
}
