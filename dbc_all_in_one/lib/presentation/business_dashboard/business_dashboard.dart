import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/security_alerts_service.dart';
import '../../services/session_manager.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../live_camera_view/live_camera_view.dart';
import '../inventory_management/inventory_management.dart';
import '../staff_management/staff_management.dart';
import '../payment_processing_center/payment_processing_center.dart';
import './widgets/security_notification_widget.dart';
import './widgets/desktop_sidebar_widget.dart';
import './widgets/desktop_right_panel_widget.dart';
import './widgets/dashboard_tab_widget.dart';
import './widgets/more_tab_widget.dart';
import './widgets/show_create_invoice_dialog.dart';
import '../../services/app_notifications.dart';
import '../../core/app_notification.dart';
import '../order_management_hub/order_management_hub.dart';

// ─────────────────────────────────────────────────────────────
//  Staff Notification Model
// ─────────────────────────────────────────────────────────────

enum StaffAlertType { absent, late, overtime, newApplication }

class StaffAlert {
  final String message;
  final String staffName;
  final StaffAlertType type;
  final DateTime time;
  bool isRead;

  StaffAlert({
    required this.message,
    required this.staffName,
    required this.type,
    required this.time,
    this.isRead = false,
  });

  IconData get icon {
    switch (type) {
      case StaffAlertType.absent:
        return Icons.person_off_outlined;
      case StaffAlertType.late:
        return Icons.schedule_outlined;
      case StaffAlertType.overtime:
        return Icons.more_time_outlined;
      case StaffAlertType.newApplication:
        return Icons.work_outline_rounded;
    }
  }

  Color get color {
    switch (type) {
      case StaffAlertType.absent:
        return const Color(0xffDC2626);
      case StaffAlertType.late:
        return const Color(0xffD97706);
      case StaffAlertType.overtime:
        return const Color(0xff7C3AED);
      case StaffAlertType.newApplication:
        return const Color(0xff0D9488);
    }
  }

  Color get bg {
    switch (type) {
      case StaffAlertType.absent:
        return const Color(0xffFEE2E2);
      case StaffAlertType.late:
        return const Color(0xffFEF3C7);
      case StaffAlertType.overtime:
        return const Color(0xffEDE9FE);
      case StaffAlertType.newApplication:
        return const Color(0xffCCFBF1);
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  Staff Notification Overlay Widget
// ─────────────────────────────────────────────────────────────

class StaffNotificationWidget extends StatefulWidget {
  final List<StaffAlert> alerts;
  final VoidCallback onDismiss;
  final VoidCallback onViewAll;

  const StaffNotificationWidget({
    super.key,
    required this.alerts,
    required this.onDismiss,
    required this.onViewAll,
  });

  @override
  State<StaffNotificationWidget> createState() =>
      _StaffNotificationWidgetState();
}

class _StaffNotificationWidgetState extends State<StaffNotificationWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<Offset> _slide;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 380));
    _slide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();

    // Auto-dismiss after 6 seconds
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) _dismiss();
    });
  }

  void _dismiss() async {
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 12,
      right: 16,
      left: 16,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Material(
            elevation: 4,
            borderRadius: BorderRadius.circular(16),
            color: Colors.white,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xffE5E7EB)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: const BoxDecoration(
                      color: Color(0xffF5F3FF),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: const Color(0xff6D28D9),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.people_outline,
                              color: Colors.white, size: 17),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Staff Alerts",
                                style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 14,
                                    color: Color(0xff111827))),
                            Text(
                                "${widget.alerts.where((a) => !a.isRead).length} new notifications",
                                style: const TextStyle(
                                    fontSize: 11, color: Color(0xff6B7280))),
                          ],
                        ),
                        const Spacer(),
                        GestureDetector(
                          onTap: _dismiss,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: const Color(0xffF3F4F8),
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: const Icon(Icons.close,
                                size: 14, color: Color(0xff6B7280)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Alert list (max 3 shown)
                  ...widget.alerts.take(3).map(
                        (a) => _alertRow(a),
                      ),
                  // Footer
                  InkWell(
                    onTap: () {
                      _dismiss();
                      widget.onViewAll();
                    },
                    borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: const BoxDecoration(
                        border:
                            Border(top: BorderSide(color: Color(0xffE5E7EB))),
                        borderRadius:
                            BorderRadius.vertical(bottom: Radius.circular(16)),
                      ),
                      child: const Center(
                        child: Text("View All Staff Alerts",
                            style: TextStyle(
                                color: Color(0xff6D28D9),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _alertRow(StaffAlert a) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: Color(0xffF3F4F8)))),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
                color: a.bg, borderRadius: BorderRadius.circular(9)),
            child: Icon(a.icon, color: a.color, size: 17),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a.staffName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Color(0xff111827))),
                Text(a.message,
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xff6B7280))),
              ],
            ),
          ),
          if (!a.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                  color: Color(0xff6D28D9), shape: BoxShape.circle),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  BusinessDashboard
// ─────────────────────────────────────────────────────────────

class BusinessDashboard extends StatefulWidget {
  final int initialIndex;

  const BusinessDashboard({super.key, this.initialIndex = 0});

  @override
  State<BusinessDashboard> createState() => _BusinessDashboardState();
}

class _BusinessDashboardState extends State<BusinessDashboard> {
  late int _currentNavIndex;

  final String businessName = "DBC Cafe & Bistro";

  final SecurityAlertsService _alertsService = SecurityAlertsService();
  final SessionManager _sessionManager = SessionManager();

  int _activeAlertsCount = 0;
  OverlayEntry? _securityOverlay;
  OverlayEntry? _staffOverlay;

  // ── Staff alerts data ─────────────────────────────────────
  final List<StaffAlert> _staffAlerts = [
    StaffAlert(
      staffName: "Rahul Sharma",
      message: "Marked absent today",
      type: StaffAlertType.absent,
      time: DateTime.now().subtract(const Duration(minutes: 10)),
    ),
    StaffAlert(
      staffName: "Priya Nair",
      message: "Arrived 18 minutes late",
      type: StaffAlertType.late,
      time: DateTime.now().subtract(const Duration(minutes: 25)),
    ),
    StaffAlert(
      staffName: "Marcus Kane",
      message: "New application for Senior Chef",
      type: StaffAlertType.newApplication,
      time: DateTime.now().subtract(const Duration(hours: 1)),
    ),
    StaffAlert(
      staffName: "Elena Rossi",
      message: "Exceeded shift by 2.5 hours",
      type: StaffAlertType.overtime,
      time: DateTime.now().subtract(const Duration(hours: 2)),
    ),
  ];

  int get _unreadStaffAlerts => _staffAlerts.where((a) => !a.isRead).length;

  // ── Nav items (now includes Payments) ─────────────────────
  static const _navItems = [
    {
      'icon': Icons.home_outlined,
      'activeIcon': Icons.home,
      'label': 'Home',
    },
    {
      'icon': Icons.security_outlined,
      'activeIcon': Icons.security,
      'label': 'Security',
    },
    {
      'icon': Icons.inventory_2_outlined,
      'activeIcon': Icons.inventory_2,
      'label': 'Stock',
    },
    {
      'icon': Icons.people_outline,
      'activeIcon': Icons.people,
      'label': 'Staff',
    },
    {
      'icon': Icons.account_balance_wallet_outlined,
      'activeIcon': Icons.account_balance_wallet,
      'label': 'Payments',
    },
    {
      'icon': Icons.more_horiz,
      'activeIcon': Icons.more_horiz,
      'label': 'More',
    },
  ];

  @override
  void initState() {
    super.initState();
    _currentNavIndex = widget.initialIndex;
    _checkForSecurityAlerts();
    _triggerDemoNotifications();
  }

  void _triggerDemoNotifications() {
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

    // Staff notification — triggers the rich overlay
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
    _staffOverlay?.remove();
    _staffOverlay = null;
    super.dispose();
  }

  // ── Security alerts ───────────────────────────────────────

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

  // ── Staff notifications ───────────────────────────────────

  void _showStaffNotification() {
    _staffOverlay?.remove();
    _staffOverlay = OverlayEntry(
      builder: (context) => StaffNotificationWidget(
        alerts: _staffAlerts,
        onDismiss: () {
          _staffOverlay?.remove();
          _staffOverlay = null;
        },
        onViewAll: () {
          _staffOverlay?.remove();
          _staffOverlay = null;
          setState(() => _currentNavIndex = 3); // Go to Staff tab
        },
      ),
    );
    Overlay.of(context).insert(_staffOverlay!);
  }

  void _markStaffAlertsRead() {
    setState(() {
      for (final a in _staffAlerts) {
        a.isRead = true;
      }
    });
  }

  // ─────────────────────────────────────────────────────────────
  //  BUILD
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
  //  DESKTOP: sidebar | constrained content | right panel
  // ─────────────────────────────────────────────────────────────

  Widget _buildDesktopScaffold() {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F1F5),
      body: Row(
        children: [
          // Left sidebar — pass badge counts
          _DesktopSidebarWithBadges(
            currentIndex: _currentNavIndex,
            navItems: _navItems,
            staffBadgeCount: _unreadStaffAlerts,
            onTap: (i) {
              setState(() => _currentNavIndex = i);
              if (i == 3) _markStaffAlertsRead();
            },
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

          // Right panel
          const DesktopRightPanelWidget(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  MOBILE: bottom nav bar
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
              actions: _currentNavIndex == 3
                  ? [
                      // Staff bell with badge
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Color(0xFF1A1A1A)),
                            onPressed: () {
                              _showStaffNotification();
                              _markStaffAlertsRead();
                            },
                          ),
                          if (_unreadStaffAlerts > 0)
                            Positioned(
                              right: 8,
                              top: 8,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xffDC2626),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$_unreadStaffAlerts',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ]
                  : null,
            ),
      body: _getScreen(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showCreateInvoiceDialog(context),
        backgroundColor: const Color(0xFF10B981),
        icon: const Icon(Icons.receipt_long),
        label: const Text('Bill'),
      ),
      bottomNavigationBar: _MobileBottomBarWithBadge(
        currentIndex: _currentNavIndex,
        staffBadgeCount: _unreadStaffAlerts,
        onTap: (i) {
          setState(() => _currentNavIndex = i);
          if (i == 3) _markStaffAlertsRead();
        },
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  //  SCREEN ROUTER
  // ─────────────────────────────────────────────────────────────

  Widget _getScreen() {
    switch (_currentNavIndex) {
      case 0:
        return DashboardTabWidget(
          businessName: businessName,
          activeAlertsCount: _activeAlertsCount,
          onViewAll: () => setState(() => _currentNavIndex = 5),
          onRefresh: _handleRefresh,
          // Pass callback so tapping Total Payments card navigates here:
          onPaymentsTap: () => setState(() => _currentNavIndex = 4),
        );
      case 1:
        return const LiveCameraView();
      case 2:
        return const InventoryManagement();
      case 3:
        return const StaffManagement();
      case 4:
        return const PaymentProcessingCenter();
      case 5:
        return const MoreTabWidget();
      case 6:
        return const OrderManagementHub();
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
        return 'Payments';
      case 5:
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

// ─────────────────────────────────────────────────────────────
//  Desktop Sidebar with Staff Badge
//  Wraps DesktopSidebarWidget and overlays a badge on Staff item
// ─────────────────────────────────────────────────────────────

class _DesktopSidebarWithBadges extends StatelessWidget {
  final int currentIndex;
  final List<Map<String, dynamic>> navItems;
  final int staffBadgeCount;
  final void Function(int) onTap;

  const _DesktopSidebarWithBadges({
    required this.currentIndex,
    required this.navItems,
    required this.staffBadgeCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // We build a custom sidebar that mirrors DesktopSidebarWidget
    // but adds a badge on the Staff item (index 3).
    // If your DesktopSidebarWidget supports a badgeCounts param,
    // pass it there instead and remove this wrapper.
    return Container(
      width: 72,
      color: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            // Logo
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xff6D28D9),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.store, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 24),
            // Nav items
            Expanded(
              child: Column(
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  final isActive = currentIndex == i;
                  final isStaff = i == 3;

                  return GestureDetector(
                    onTap: () => onTap(i),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 8),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xffEDE9FE)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isActive
                                      ? item['activeIcon'] as IconData
                                      : item['icon'] as IconData,
                                  size: 22,
                                  color: isActive
                                      ? const Color(0xff6D28D9)
                                      : const Color(0xff9CA3AF),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  item['label'] as String,
                                  style: TextStyle(
                                    fontSize: 8,
                                    fontWeight: isActive
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: isActive
                                        ? const Color(0xff6D28D9)
                                        : const Color(0xff9CA3AF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Badge for Staff
                          if (isStaff && staffBadgeCount > 0)
                            Positioned(
                              top: 6,
                              right: 6,
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xffDC2626),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '$staffBadgeCount',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 8,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  Mobile Bottom Bar with Staff Badge
// ─────────────────────────────────────────────────────────────

class _MobileBottomBarWithBadge extends StatelessWidget {
  final int currentIndex;
  final int staffBadgeCount;
  final void Function(int) onTap;

  const _MobileBottomBarWithBadge({
    required this.currentIndex,
    required this.staffBadgeCount,
    required this.onTap,
  });

  static const _items = [
    {'icon': Icons.home_outlined, 'active': Icons.home, 'label': 'Home'},
    {
      'icon': Icons.security_outlined,
      'active': Icons.security,
      'label': 'Security'
    },
    {
      'icon': Icons.inventory_2_outlined,
      'active': Icons.inventory_2,
      'label': 'Stock'
    },
    {'icon': Icons.people_outline, 'active': Icons.people, 'label': 'Staff'},
    {
      'icon': Icons.account_balance_wallet_outlined,
      'active': Icons.account_balance_wallet,
      'label': 'Payments'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64 + MediaQuery.of(context).padding.bottom,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xffE5E7EB))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(_items.length, (i) {
            final item = _items[i];
            final isActive = currentIndex == i;
            final isStaff = i == 3;

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isActive
                              ? item['active'] as IconData
                              : item['icon'] as IconData,
                          size: 22,
                          color: isActive
                              ? const Color(0xff6D28D9)
                              : const Color(0xff9CA3AF),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['label'] as String,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive
                                ? const Color(0xff6D28D9)
                                : const Color(0xff9CA3AF),
                          ),
                        ),
                      ],
                    ),
                    if (isStaff && staffBadgeCount > 0)
                      Positioned(
                        top: 6,
                        right:
                            (MediaQuery.of(context).size.width / 5 - 44) / 2 +
                                22,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: const BoxDecoration(
                            color: Color(0xffDC2626),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$staffBadgeCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
