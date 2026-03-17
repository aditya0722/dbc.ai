import 'dart:async';
import 'package:flutter/material.dart';

// ── Model (unchanged – same fields your dashboard already uses) ──────────────
class NotificationItem {
  final String title;
  final String message;
  final String icon;
  final Color color;
  final int displayDuration; // seconds

  const NotificationItem({
    required this.title,
    required this.message,
    required this.icon,
    required this.color,
    required this.displayDuration,
  });
}

// ── Widget ────────────────────────────────────────────────────────────────────
class NotificationCarousel extends StatefulWidget {
  final List<NotificationItem> notifications;
  final VoidCallback onDismiss;

  const NotificationCarousel({
    super.key,
    required this.notifications,
    required this.onDismiss,
  });

  @override
  State<NotificationCarousel> createState() => _NotificationCarouselState();
}

class _NotificationCarouselState extends State<NotificationCarousel>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Timer? _cycleTimer;
  late AnimationController _animController;
  late Animation<Offset> _slideIn;
  late Animation<Offset> _slideOut;
  bool _isAnimatingOut = false;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _slideIn = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _slideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInCubic,
    ));

    // Slide in the first card
    _animController.forward();
    _scheduleNext();
  }

  void _scheduleNext() {
    if (widget.notifications.length <= 1) return;

    final currentItem = widget.notifications[_currentIndex];
    _cycleTimer?.cancel();
    _cycleTimer = Timer(
      Duration(seconds: currentItem.displayDuration + 1),
      _advanceToNext,
    );
  }

  Future<void> _advanceToNext() async {
    if (!mounted) return;
    setState(() => _isAnimatingOut = true);

    // Reverse = slide current card out to left
    await _animController.reverse();

    if (!mounted) return;
    setState(() {
      _currentIndex = (_currentIndex + 1) % widget.notifications.length;
      _isAnimatingOut = false;
    });

    // Slide new card in from right
    _animController.forward();
    _scheduleNext();
  }

  @override
  void dispose() {
    _cycleTimer?.cancel();
    _animController.dispose();
    super.dispose();
  }

  IconData _resolveIcon(String name) {
    const map = {
      'payment': Icons.payment,
      'security': Icons.security,
      'inventory': Icons.inventory_2,
      'warning': Icons.warning_amber_rounded,
      'info': Icons.info_outline,
      'check': Icons.check_circle_outline,
    };
    return map[name] ?? Icons.notifications_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.notifications[_currentIndex];

    return ClipRect(
      child: SlideTransition(
        position: _isAnimatingOut ? _slideOut : _slideIn,
        child: _NotificationCard(
          item: item,
          resolveIcon: _resolveIcon,
          total: widget.notifications.length,
          currentIndex: _currentIndex,
          onDismiss: widget.onDismiss,
        ),
      ),
    );
  }
}

// ── Single card UI (Image 1 style) ────────────────────────────────────────────
class _NotificationCard extends StatelessWidget {
  final NotificationItem item;
  final IconData Function(String) resolveIcon;
  final int total;
  final int currentIndex;
  final VoidCallback onDismiss;

  const _NotificationCard({
    required this.item,
    required this.resolveIcon,
    required this.total,
    required this.currentIndex,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Colored icon badge ──
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                resolveIcon(item.icon),
                color: item.color,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // ── Title + message ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1A1A1A),
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(
                    item.message,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B6B6B),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  // ── Dot indicators (if multiple notifications) ──
                  if (total > 1) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(total, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 4),
                          width: i == currentIndex ? 16 : 6,
                          height: 4,
                          decoration: BoxDecoration(
                            color: i == currentIndex
                                ? item.color
                                : item.color.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),

            // ── Dismiss ──
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  Icons.close,
                  size: 18,
                  color: const Color(0xFFBDBDBD),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}