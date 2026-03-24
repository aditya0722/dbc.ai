import 'package:flutter/material.dart';
import '../../../core/app_export.dart';

class DesktopRightPanelWidget extends StatelessWidget {
  const DesktopRightPanelWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(left: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),

              // Live overview header
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                        color: Color(0xFF10B981), shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  const Text('Live Overview',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A))),
                ],
              ),

              const SizedBox(height: 16),

              _RightStatCard(
                icon: Icons.trending_up,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFD1FAE5),
                label: 'Revenue',
                value: '↑ 12%',
                sub: 'vs last week',
              ),
              _RightStatCard(
                icon: Icons.group_outlined,
                iconColor: const Color(0xFF6B46C1),
                iconBg: const Color(0xFFEDE9FE),
                label: 'Active Staff',
                value: '15 / 18',
                sub: '3 absent today',
              ),
              _RightStatCard(
                icon: Icons.shopping_cart_outlined,
                iconColor: const Color(0xFF0EA5E9),
                iconBg: const Color(0xFFE0F2FE),
                label: 'Orders',
                value: '24 Active',
                sub: '+8 since morning',
              ),
              _RightStatCard(
                icon: Icons.warning_amber_outlined,
                iconColor: const Color(0xFFEF4444),
                iconBg: const Color(0xFFFFEBEE),
                label: 'Alerts',
                value: '2 Active',
                sub: 'Needs attention',
              ),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),

              const Text('Quick Links',
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A))),
              const SizedBox(height: 12),

              _QuickLink(
                  icon: Icons.receipt_long_outlined,
                  label: 'Invoices',
                  color: const Color(0xFF10B981),
                  route: AppRoutes.invoiceManagementCenter),
              _QuickLink(
                  icon: Icons.account_balance_outlined,
                  label: 'GST Filing',
                  color: const Color(0xFFE11D48),
                  route: '/gst-filing-center'),
              _QuickLink(
                  icon: Icons.payments_outlined,
                  label: 'Payroll',
                  color: const Color(0xFF06B6D4),
                  route: '/payroll-processing'),
              _QuickLink(
                  icon: Icons.storefront_outlined,
                  label: 'Marketplace',
                  color: const Color(0xFF14B8A6),
                  route: '/vendor-marketplace'),

              const SizedBox(height: 20),
              const Divider(height: 1, color: Color(0xFFF0F0F0)),
              const SizedBox(height: 16),

              // Footer note
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8F7FF),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFEDE9FE)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.phone_android,
                        size: 14, color: Color(0xFF6B46C1)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Best experience\non mobile app',
                        style: TextStyle(
                            fontSize: 11,
                            color: Color(0xFF6B46C1),
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RightStatCard extends StatelessWidget {
  const _RightStatCard({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.value,
    required this.sub,
  });

  final IconData icon;
  final Color iconColor, iconBg;
  final String label, value, sub;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF9F9FB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF9E9E9E),
                        fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A1A1A))),
                Text(sub,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFFBBBBBB))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  const _QuickLink({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });

  final IconData icon;
  final String label, route;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFFF0F0F0)),
          color: Colors.white,
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 10),
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1A1A1A))),
            ),
            const Icon(Icons.chevron_right, size: 14, color: Color(0xFFCCCCCC)),
          ],
        ),
      ),
    );
  }
}