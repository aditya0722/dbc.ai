import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../../widgets/dbc_back_button.dart';
import '../../routes/app_routes.dart';

import '../../services/security_alerts_service.dart';
import './widgets/alert_card_widget.dart';
import './widgets/severity_filter_chip_widget.dart';
import './widgets/status_filter_chip_widget.dart';

class SecurityAlertsDashboard extends StatefulWidget {
  const SecurityAlertsDashboard({super.key});

  @override
  State<SecurityAlertsDashboard> createState() =>
      _SecurityAlertsDashboardState();
}

class _SecurityAlertsDashboardState extends State<SecurityAlertsDashboard> {
  final SecurityAlertsService _alertsService = SecurityAlertsService();
  String? _selectedSeverity;
  String? _selectedStatus;
  List<Map<String, dynamic>> _alerts = [];
  bool _isLoading = true;
  bool _showAllAlerts = false;

  // Camera feeds — use real network images to match Image 2
  final List<Map<String, dynamic>> _cameraFeeds = [
    {
      'name': 'Main Entrance',
      'status': 'live',
      'imageUrl':
          'https://images.unsplash.com/photo-1557597774-9d273605dfa9?w=400&q=80',
    },
    {
      'name': 'Parking Lot A',
      'status': 'live',
      'imageUrl':
          'https://images.unsplash.com/photo-1506521781263-d8422e82f27a?w=400&q=80',
    },
    {
      'name': 'Data Center',
      'status': 'live',
      'imageUrl':
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=400&q=80',
    },
    {
      'name': 'Loading Bay',
      'status': 'live',
      'imageUrl':
          'https://images.unsplash.com/photo-1530124566582-a618bc2615dc?w=400&q=80',
    },
  ];

  // Access log data
  final List<Map<String, dynamic>> _accessLogs = [
    {
      'name': 'Sarah Jenkins',
      'staffId': 'STAFF ID: SJ-9921',
      'status': 'authorized',
      'time': '10:42 AM',
    },
    {
      'name': 'David Miller',
      'staffId': 'STAFF ID: DM-4482',
      'status': 'authorized',
      'time': '10:38 AM',
    },
    {
      'name': 'Unknown Visitor',
      'staffId': 'ACCESS POINT: NORTH GATE',
      'status': 'denied',
      'time': '10:25 AM',
    },
    {
      'name': 'Raj Patel',
      'staffId': 'STAFF ID: RP-1123',
      'status': 'authorized',
      'time': '10:10 AM',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    try {
      final alerts = await _alertsService.getSecurityAlerts(
        severity: _selectedSeverity,
        status: _selectedStatus,
      );
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading alerts: $e')),
        );
      }
    }
  }

  void _onSeverityFilterChanged(String? severity) {
    setState(() {
      _selectedSeverity = severity == _selectedSeverity ? null : severity;
    });
    _loadAlerts();
  }

  void _onStatusFilterChanged(String? status) {
    setState(() {
      _selectedStatus = status == _selectedStatus ? null : status;
    });
    _loadAlerts();
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic>? get _topAlert {
    if (_alerts.isEmpty) return null;
    final active = _alerts.where((a) => a['status'] == 'active').toList();
    if (active.isEmpty) return null;
    const order = ['critical', 'high', 'medium', 'low'];
    active.sort(
        (a, b) => order.indexOf(a['severity']) - order.indexOf(b['severity']));
    return active.first;
  }

  // Quick stat counts derived from alerts
  int get _activeCount => _alerts.where((a) => a['status'] == 'active').length;
  int get _investigatingCount =>
      _alerts.where((a) => a['status'] == 'investigating').length;
  int get _resolvedCount =>
      _alerts.where((a) => a['status'] == 'resolved').length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        onRefresh: _loadAlerts,
        color: const Color(0xFF6B46C1),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF6B46C1)))
            : ListView(
                padding: const EdgeInsets.fromLTRB(0, 12, 0, 80),
                children: [
                  // ── Alert Banner ──
                  if (_topAlert != null)
                    _buildAlertBanner(_topAlert!)
                  else if (_alerts.isNotEmpty)
                    _buildClearBanner(),

                  const SizedBox(height: 20),

                  // ── Threat Summary Cards ──
                  if (_alerts.isNotEmpty) ...[
                    _buildSectionHeader(
                      title: 'Threat Summary',
                      actionLabel: '',
                      onAction: () {},
                    ),
                    const SizedBox(height: 12),
                    _buildThreatSummaryRow(),
                    const SizedBox(height: 24),
                  ],

                  // ── Live Camera Feeds ──
                  _buildSectionHeader(
                    title: 'Live Camera Feeds',
                    actionLabel: 'View All Monitoring',
                    onAction: () =>
                        Navigator.pushNamed(context, '/live-camera-view'),
                  ),
                  const SizedBox(height: 12),
                  _buildCameraGrid(),

                  const SizedBox(height: 24),

                  // ── Recent Access Logs ──
                  _buildSectionHeader(
                    title: 'Recent Access Logs',
                    actionLabel: 'View All',
                    onAction: () => Navigator.pushNamed(
                        context, '/security-events-history'),
                  ),
                  const SizedBox(height: 12),
                  _buildAccessLogs(),

                  const SizedBox(height: 24),

                  // ── All Alerts (collapsible) ──
                  if (_alerts.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'All Alerts',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(
                                () => _showAllAlerts = !_showAllAlerts),
                            child: Text(
                              _showAllAlerts ? 'Hide' : 'Show All',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF6B46C1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFilterRow(),
                    const SizedBox(height: 8),
                    if (_showAllAlerts) _buildAlertsList(),
                  ],
                ],
              ),
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: DBCBackButton(
        onPressed: () async {
          final didPop = await Navigator.maybePop(context);
          if (!didPop) {
            Navigator.pushReplacementNamed(
                context, AppRoutes.businessDashboard);
          }
        },
        backgroundColor: Colors.white,
        iconColor: const Color(0xFF1A1A1A),
        iconSize: 20,
      ),
      title: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF6B46C1).withOpacity(0.12),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.shield_outlined,
                color: Color(0xFF6B46C1), size: 16),
          ),
          const SizedBox(width: 8),
          const Text(
            'Sovereign Security',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontWeight: FontWeight.w700,
              fontSize: 17,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined,
                  color: Color(0xFF1A1A1A)),
              onPressed: () {},
            ),
            if (_activeCount > 0)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh, color: Color(0xFF1A1A1A)),
          onPressed: _loadAlerts,
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(color: const Color(0xFFEEEEEE), height: 1),
      ),
    );
  }

  // ── Alert Banner ──────────────────────────────────────────────────────────
  Widget _buildAlertBanner(Map<String, dynamic> alert) {
    final color = _getSeverityColor(alert['severity'] ?? 'high');
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.warning_amber_rounded, color: color, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert['title'] ?? 'Security Alert',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  alert['description'] ?? 'Immediate attention required.',
                  style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: color,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              elevation: 0,
            ),
            child: const Text('Dispatch',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildClearBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.25)),
      ),
      child: const Row(
        children: [
          Icon(Icons.shield_outlined, color: Color(0xFF10B981), size: 20),
          SizedBox(width: 10),
          Text(
            'All systems secure — no active alerts',
            style: TextStyle(
                fontSize: 13,
                color: Color(0xFF10B981),
                fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // ── Threat Summary Row ────────────────────────────────────────────────────
  Widget _buildThreatSummaryRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _buildSummaryCard(
            label: 'Active',
            count: _activeCount,
            icon: Icons.warning_amber_rounded,
            color: Colors.red,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            label: 'Investigating',
            count: _investigatingCount,
            icon: Icons.search_rounded,
            color: Colors.orange,
          ),
          const SizedBox(width: 10),
          _buildSummaryCard(
            label: 'Resolved',
            count: _resolvedCount,
            icon: Icons.check_circle_outline,
            color: const Color(0xFF10B981),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required String label,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 10),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9E9E9E),
                  fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section Header ────────────────────────────────────────────────────────
  Widget _buildSectionHeader({
    required String title,
    required String actionLabel,
    required VoidCallback onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          if (actionLabel.isNotEmpty)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B46C1),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ── Camera Grid ───────────────────────────────────────────────────────────
  Widget _buildCameraGrid() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _cameraFeeds.length,
        itemBuilder: (context, index) {
          final cam = _cameraFeeds[index];
          return GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/live-camera-view'),
            child: Container(
              width: 185,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(14),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Camera image
                    Image.network(
                      cam['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF1A1A2E),
                        child: Icon(
                          Icons.videocam,
                          color: Colors.white.withOpacity(0.15),
                          size: 48,
                        ),
                      ),
                      loadingBuilder: (_, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: const Color(0xFF1A1A2E),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white30,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),

                    // Dark overlay for readability
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.25),
                            Colors.transparent,
                            Colors.black.withOpacity(0.55),
                          ],
                          stops: const [0.0, 0.4, 1.0],
                        ),
                      ),
                    ),

                    // REC badge
                    Positioned(
                      top: 9,
                      left: 9,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.55),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'REC',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Camera name at bottom
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 9),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              cam['name'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Icon(
                              Icons.crop_free,
                              color: Colors.white.withOpacity(0.75),
                              size: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Access Logs ───────────────────────────────────────────────────────────
  Widget _buildAccessLogs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: List.generate(_accessLogs.length, (index) {
          final log = _accessLogs[index];
          final isDenied = log['status'] == 'denied';
          final isFirst = index == 0;
          final isLast = index == _accessLogs.length - 1;

          return Container(
            decoration: BoxDecoration(
              color:
                  isDenied ? Colors.red.withOpacity(0.03) : Colors.transparent,
              border: isDenied
                  ? const Border(left: BorderSide(color: Colors.red, width: 3))
                  : null,
              borderRadius: isFirst && isLast
                  ? BorderRadius.circular(16)
                  : isFirst
                      ? const BorderRadius.vertical(top: Radius.circular(16))
                      : isLast
                          ? const BorderRadius.vertical(
                              bottom: Radius.circular(16))
                          : null,
            ),
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isDenied
                              ? Colors.red.withOpacity(0.1)
                              : const Color(0xFF6B46C1).withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isDenied
                              ? Icons.person_off_outlined
                              : Icons.person_outline,
                          color:
                              isDenied ? Colors.red : const Color(0xFF6B46C1),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Name + ID
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log['name'],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDenied
                                    ? Colors.red
                                    : const Color(0xFF1A1A1A),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              log['staffId'],
                              style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF9E9E9E),
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Badge + time
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDenied
                                  ? Colors.red
                                  : const Color(0xFF10B981),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              isDenied ? 'DENIED' : 'AUTHORIZED',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            log['time'],
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9E9E9E)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  Divider(
                    height: 1,
                    indent: 64,
                    endIndent: 16,
                    color: Colors.grey.withOpacity(0.1),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  // ── Filter Row ────────────────────────────────────────────────────────────
  Widget _buildFilterRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          SeverityFilterChipWidget(
            label: 'Critical',
            isSelected: _selectedSeverity == 'critical',
            color: Colors.red,
            onSelected: () => _onSeverityFilterChanged('critical'),
          ),
          const SizedBox(width: 6),
          SeverityFilterChipWidget(
            label: 'High',
            isSelected: _selectedSeverity == 'high',
            color: Colors.orange,
            onSelected: () => _onSeverityFilterChanged('high'),
          ),
          const SizedBox(width: 6),
          SeverityFilterChipWidget(
            label: 'Medium',
            isSelected: _selectedSeverity == 'medium',
            color: Colors.amber,
            onSelected: () => _onSeverityFilterChanged('medium'),
          ),
          const SizedBox(width: 6),
          SeverityFilterChipWidget(
            label: 'Low',
            isSelected: _selectedSeverity == 'low',
            color: Colors.blue,
            onSelected: () => _onSeverityFilterChanged('low'),
          ),
          const SizedBox(width: 12),
          StatusFilterChipWidget(
            label: 'Active',
            isSelected: _selectedStatus == 'active',
            onSelected: () => _onStatusFilterChanged('active'),
          ),
          const SizedBox(width: 6),
          StatusFilterChipWidget(
            label: 'Investigating',
            isSelected: _selectedStatus == 'investigating',
            onSelected: () => _onStatusFilterChanged('investigating'),
          ),
          const SizedBox(width: 6),
          StatusFilterChipWidget(
            label: 'Resolved',
            isSelected: _selectedStatus == 'resolved',
            onSelected: () => _onStatusFilterChanged('resolved'),
          ),
        ],
      ),
    );
  }

  // ── All Alerts List ───────────────────────────────────────────────────────
  Widget _buildAlertsList() {
    if (_alerts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.shield_outlined,
                  size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                'No security alerts found',
                style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _alerts.length,
      itemBuilder: (context, index) {
        final alert = _alerts[index];
        return AlertCardWidget(
          alert: alert,
          severityColor: _getSeverityColor(alert['severity']),
          onStatusChange: () => _loadAlerts(),
        );
      },
    );
  }
}
