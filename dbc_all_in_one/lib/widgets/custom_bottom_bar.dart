import 'package:flutter/material.dart';

/// Navigation item configuration for bottom bar
class CustomBottomBarItem {
  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final String route;

  const CustomBottomBarItem({
    required this.icon,
    this.activeIcon,
    required this.label,
    required this.route,
  });
}

/// Custom bottom navigation bar widget for DBC.AI business management app
/// Implements thumb-accessible primary navigation with five core business pillars
/// Follows Contemporary Business Minimalism design with clean, purposeful interactions
class CustomBottomBar extends StatelessWidget {
  /// Current selected index
  final int currentIndex;

  /// Callback when navigation item is tapped
  final ValueChanged<int>? onTap;

  /// Variant of the bottom bar
  final CustomBottomBarVariant variant;

  const CustomBottomBar({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.variant = CustomBottomBarVariant.standard,
  });

  /// Navigation items mapped to core business functions
  static final List<CustomBottomBarItem> _navigationItems = [
    const CustomBottomBarItem(
      icon: Icons.dashboard_outlined,
      activeIcon: Icons.dashboard,
      label: 'Dashboard',
      route: '/business-dashboard',
    ),
    const CustomBottomBarItem(
      icon: Icons.shield_outlined,
      activeIcon: Icons.shield,
      label: 'Security',
      route: '/live-camera-view',
    ),
    const CustomBottomBarItem(
      icon: Icons.inventory_2_outlined,
      activeIcon: Icons.inventory_2,
      label: 'Inventory',
      route: '/inventory-management',
    ),
    const CustomBottomBarItem(
      icon: Icons.people_outline,
      activeIcon: Icons.people,
      label: 'Staff',
      route: '/staff-management',
    ),
    const CustomBottomBarItem(
      icon: Icons.menu,
      activeIcon: Icons.menu,
      label: 'More',
      route:
          '/business-dashboard', // More menu stays on dashboard with drawer/modal
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomBottomBarVariant.standard:
        return _buildStandardBottomBar(context, theme, colorScheme);
      case CustomBottomBarVariant.floating:
        return _buildFloatingBottomBar(context, theme, colorScheme);
      case CustomBottomBarVariant.minimal:
        return _buildMinimalBottomBar(context, theme, colorScheme);
    }
  }

  /// Standard bottom navigation bar with full labels
  Widget _buildStandardBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8.0,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          height: 72,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavigationItem(
                context,
                theme,
                colorScheme,
                _navigationItems[index],
                index,
                showLabel: true,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Floating bottom navigation bar with rounded corners
  Widget _buildFloatingBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SafeArea(
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(32.0),
            boxShadow: [
              BoxShadow(
                color: colorScheme.shadow.withValues(alpha: 0.12),
                blurRadius: 16.0,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavigationItem(
                context,
                theme,
                colorScheme,
                _navigationItems[index],
                index,
                showLabel: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Minimal bottom navigation bar with icons only
  Widget _buildMinimalBottomBar(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _navigationItems.length,
              (index) => _buildNavigationItem(
                context,
                theme,
                colorScheme,
                _navigationItems[index],
                index,
                showLabel: false,
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Build individual navigation item
  Widget _buildNavigationItem(BuildContext context, ThemeData theme,
      ColorScheme colorScheme, CustomBottomBarItem item, int index,
      {required bool showLabel}) {
    final isSelected = currentIndex == index;
    final color =
        isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: () {
          if (onTap != null) {
            onTap!(index);
          }
          
        },
        borderRadius: BorderRadius.circular(12.0),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon with selection indicator
              Stack(
                alignment: Alignment.center,
                children: [
                  // Selection indicator background
                  if (isSelected)
                    Container(
                      width: 48,
                      height: 32,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                    ),
                  // Icon
                  Icon(
                    isSelected && item.activeIcon != null
                        ? item.activeIcon
                        : item.icon,
                    color: color,
                    size: 24,
                  ),
                ],
              ),
              // Label
              if (showLabel) ...[
                const SizedBox(height: 4),
                Text(
                  item.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    fontSize: 12,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Variants of the custom bottom bar
enum CustomBottomBarVariant {
  /// Standard bottom bar with full labels and icons
  standard,

  /// Floating bottom bar with rounded corners
  floating,

  /// Minimal bottom bar with icons only
  minimal,
}
