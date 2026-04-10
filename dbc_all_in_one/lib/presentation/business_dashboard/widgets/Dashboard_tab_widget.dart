import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

class DashboardTabWidget extends StatelessWidget {
  const DashboardTabWidget({
    super.key,
    required this.businessName,
    required this.activeAlertsCount,
    required this.onViewAll,
    required this.onRefresh,
    this.onPaymentsTap,
  });

  final String businessName;
  final int activeAlertsCount;
  final VoidCallback onViewAll;
  final VoidCallback? onPaymentsTap;
  final Future<void> Function() onRefresh;

  // ── Data ──
  static final List<Map<String, dynamic>> _primaryMetrics = [
    {
      "title": "Finance Manager",
      "value": "\$2,450.00",
      "trend": "+12.5%",
      "trendUp": true,
      "route": "/payment-processing-center",
    },
    {
      "title": "Active Order",
      "value": "24 Active",
      "trend": "+ 8 today",
      "trendUp": true,
      "route": "/order-management-hub",
    },
  ];

  static final List<Map<String, dynamic>> _managementMetrics = [
    {
      "title": "Finance Manager",
      "value": "\$2,450.00",
      "icon": Icons.attach_money,
      "color": Color.fromARGB(255, 70, 193, 101),
      "iconBg": Color(0xFFEDE9FE),
      "valueColor": Color.fromARGB(255, 70, 193, 101),
      "route": "/payment-processing-center",
    },
    {
      "title": "Bussiness Manager",
      "value": "Manage your business details",
      "icon": Icons.business,
      "color": Color.fromARGB(255, 170, 193, 70),
      "iconBg": Color(0xFFEDE9FE),
      "valueColor": Color(0xFF1A1A1A),
      "route": "/order-management-hub",
    },
    {
      "title": "Staff Manager",
      "value": "15/18 Present",
      "icon": Icons.people,
      "color": Color(0xFF6B46C1),
      "iconBg": Color(0xFFEDE9FE),
      "valueColor": Color(0xFF1A1A1A),
      "route": "/staff-management",
    },
    {
      "title": "Inventory Manager",
      "value": "12 Low Items",
      "icon": Icons.inventory_2,
      "color": Color(0xFFF59E0B),
      "iconBg": Color(0xFFFEF3C7),
      "valueColor": Color(0xFFF59E0B),
      "route": "/inventory-management",
    },
    {
      "title": "Security Manager",
      "value": "Active",
      "icon": Icons.verified_user,
      "color": Color(0xFF10B981),
      "iconBg": Color(0xFFD1FAE5),
      "valueColor": Color(0xFF10B981),
      "route": "/live-camera-view",
    },
    {
      "title": "News/Blog",
      "value": "8 New Updates",
      "icon": Icons.article,
      "color": Color(0xFF6B46C1),
      "iconBg": Color(0xFFEDE9FE),
      "valueColor": Color(0xFF6B6B6B),
      "route": "/Marketing Manager",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 500;

        return RefreshIndicator(
          onRefresh: onRefresh,
          color: const Color(0xFF6B46C1),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Welcome header
              SliverToBoxAdapter(
                child: _WelcomeHeader(businessName: businessName),
              ),

              // Alerts banner
              if (activeAlertsCount > 0)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: _AlertsBanner(alertsCount: activeAlertsCount),
                  ),
                ),

              // Primary metric cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: _primaryMetrics.map((m) {
                      final isLast = m == _primaryMetrics.last;
                      return Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: isLast ? 0 : 12),
                          child: _PrimaryMetricCard(metric: m),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Management header
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Bussiness Management',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1A1A1A))),
                      GestureDetector(
                        onTap: onViewAll,
                        child: const Text('View All',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF6B46C1))),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 12)),

              // Management grid
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _managementMetrics[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamed(context, item['route']);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                )
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: item['iconBg'],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    item['icon'],
                                    color: item['color'],
                                    size: 26,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item['value'],
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: item['valueColor'],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey.shade400,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                    childCount: _managementMetrics.length,
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              // Featured banner
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: _FeaturedBanner(),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 90)),
            ],
          ),
        );
      },
    );
  }
}

// ── Welcome header ──────────────────────────────────────────
class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader({required this.businessName});

  final String businessName;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Welcome back,',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF6B6B6B))),
                const SizedBox(height: 2),
                Text(businessName,
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6B46C1))),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.search,
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.globalSearchCenter),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: IconButton(
          icon: Icon(icon, color: const Color(0xFF1A1A1A)),
          onPressed: onPressed),
    );
  }
}

// ── Primary metric card ──────────────────────────────────────
class _PrimaryMetricCard extends StatelessWidget {
  const _PrimaryMetricCard({required this.metric});
  final Map<String, dynamic> metric;

  @override
  Widget build(BuildContext context) {
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
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(metric['title'],
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF6B6B6B),
                        fontWeight: FontWeight.w500)),
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
            Text(metric['value'],
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.arrow_upward,
                    size: 12, color: Color(0xFF10B981)),
                const SizedBox(width: 2),
                Text(metric['trend'],
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF10B981),
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Management card ──────────────────────────────────────────
class _ManagementCard extends StatelessWidget {
  const _ManagementCard({required this.item});
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
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
                offset: const Offset(0, 3))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                  color: item['iconBg'],
                  borderRadius: BorderRadius.circular(12)),
              child: Icon(item['icon'] as IconData,
                  color: item['color'] as Color, size: 22),
            ),
            const SizedBox(height: 12),
            Text(item['title'],
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A))),
            const SizedBox(height: 2),
            Text(item['value'],
                style: TextStyle(
                    fontSize: 12,
                    color: item['valueColor'] as Color,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// ── Alerts banner ────────────────────────────────────────────
class _AlertsBanner extends StatelessWidget {
  const _AlertsBanner({required this.alertsCount});
  final int alertsCount;

  @override
  Widget build(BuildContext context) {
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
              '$alertsCount CCTV Alert${alertsCount > 1 ? 's' : ''} Active',
              style: const TextStyle(
                  color: Colors.red, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.securityAlertsDashboard),
            child: const Text('View',
                style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}

// ── Featured banner ──────────────────────────────────────────
class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner();

  @override
  Widget build(BuildContext context) {
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
            Positioned(
              right: -10,
              bottom: -10,
              child: Opacity(
                opacity: 0.15,
                child:
                    Icon(Icons.restaurant_menu, size: 100, color: Colors.white),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('File GST for Free',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.5), width: 1),
                    ),
                    child: const Text('Cloud based GST calculation and filing',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.8)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
