import 'package:flutter/material.dart';

// ── Keep the same enum so BusinessDashboard needs zero changes ────────────────
enum CustomBottomBarVariant { standard }

// ── Drop-in replacement widget ────────────────────────────────────────────────
class CustomBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;
  final CustomBottomBarVariant variant;

  const CustomBottomBar({
    super.key,
    this.currentIndex = 0,
    this.onTap,
    this.variant = CustomBottomBarVariant.standard,
  });

  // Tab definitions – icons + labels match Image 1
  static const List<_NavItem> _items = [
    _NavItem(
      label: 'Home',
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
    ),
    _NavItem(
      label: 'Security',
      activeIcon: Icons.shield_rounded,
      inactiveIcon: Icons.shield_outlined,
    ),
    _NavItem(
      label: 'Stock',
      activeIcon: Icons.inventory_2_rounded,
      inactiveIcon: Icons.inventory_2_outlined,
    ),
    _NavItem(
      label: 'Staff',
      activeIcon: Icons.badge_rounded,
      inactiveIcon: Icons.badge_outlined,
    ),
    _NavItem(
      label: 'More',
      activeIcon: Icons.more_horiz_rounded,
      inactiveIcon: Icons.more_horiz_rounded,
    ),
  ];

  static const Color _activeColor = Color(0xFF6B46C1);
  static const Color _inactiveColor = Color(0xFFAAAAAA);
  static const Color _bgColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    // Default route mapping for indices when caller doesn't provide `onTap`.
    const List<String> _defaultRoutes = [
      '/business-dashboard',
      '/live-camera-view',
      '/inventory-management',
      '/staff-management',
      '/business-dashboard',
    ];
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item = _items[index];
              final isActive = index == currentIndex;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    if (onTap != null) {
                      onTap!.call(index);
                      return;
                    }
                    // Fallback: navigate using named routes so web history updates
                    final route = (index >= 0 && index < _defaultRoutes.length)
                        ? _defaultRoutes[index]
                        : null;
                    if (route != null) {
                      Navigator.pushReplacementNamed(context, route);
                    }
                  },
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // ── Icon with animated scale ──
                        TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: isActive ? 0.85 : 1.0,
                            end: isActive ? 1.0 : 0.85,
                          ),
                          duration: const Duration(milliseconds: 200),
                          builder: (_, scale, child) =>
                              Transform.scale(scale: scale, child: child),
                          child: Icon(
                            isActive ? item.activeIcon : item.inactiveIcon,
                            color: isActive ? _activeColor : _inactiveColor,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 3),
                        // ── Label ──
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight:
                                isActive ? FontWeight.w700 : FontWeight.w500,
                            color: isActive ? _activeColor : _inactiveColor,
                            letterSpacing: 0.2,
                          ),
                          child: Text(item.label),
                        ),
                        // ── Active dot indicator ──
                        const SizedBox(height: 3),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: isActive ? 18 : 0,
                          height: 3,
                          decoration: BoxDecoration(
                            color: isActive ? _activeColor : Colors.transparent,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Internal data class ───────────────────────────────────────────────────────
class _NavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _NavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
