import 'package:flutter/material.dart';

class DesktopSidebarWidget extends StatelessWidget {
  const DesktopSidebarWidget({
    super.key,
    required this.currentIndex,
    required this.navItems,
    required this.onTap,
  });

  final int currentIndex;
  final List<Map<String, Object>> navItems;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Brand avatar
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('D',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18)),
              ),
            ),

            const SizedBox(height: 20),
            const Divider(height: 1, indent: 12, endIndent: 12),
            const SizedBox(height: 12),

            // Nav items
            Expanded(
              child: Column(
                children: List.generate(navItems.length, (i) {
                  final item = navItems[i];
                  final isActive = currentIndex == i;
                  return _SidebarItem(
                    icon: isActive
                        ? item['activeIcon'] as IconData
                        : item['icon'] as IconData,
                    label: item['label'] as String,
                    isActive: isActive,
                    onTap: () => onTap(i),
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

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFF6B46C1).withOpacity(0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon,
                  size: 22,
                  color: isActive
                      ? const Color(0xFF6B46C1)
                      : const Color(0xFF9E9E9E)),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: isActive
                        ? const Color(0xFF6B46C1)
                        : const Color(0xFF9E9E9E))),
          ],
        ),
      ),
    );
  }
}