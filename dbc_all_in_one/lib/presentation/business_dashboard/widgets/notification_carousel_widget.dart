import 'dart:async';
import 'package:flutter/material.dart';

// ── Model (unchanged) ─────────────────────────────────────────────────────────
class NotificationItem {
  final String title;
  final String message;
  final String icon;
  final Color color;
  final int displayDuration;

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
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  bool _isVisible = true; // controls whether card is shown during interval gap

  late AnimationController _slideController;
  late Animation<Offset> _slideAnimation;

  late AnimationController _progressController;

  Timer? _holdTimer;
  Timer? _intervalTimer; // ← NEW: 5s gap between notifications

  static const int _holdSeconds = 10;
  static const int _progressSeconds = 5;
  static const int _intervalSeconds = 5; // ← NEW

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _progressSeconds),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _slideOut(); // ← slide OUT first, then wait 5s, then show next
        }
      });

    _startCycle();
  }

  /// Step 1: Slide in → hold 10s → progress bar 5s
  void _startCycle() {
    if (!mounted) return;

    setState(() => _isVisible = true);
    _slideController.reset();
    _progressController.reset();
    _slideController.forward();

    _holdTimer?.cancel();
    _holdTimer = Timer(const Duration(seconds: _holdSeconds), () {
      if (mounted) _progressController.forward();
    });
  }

  /// Step 2: Slide the card back UP (out of view)
  void _slideOut() {
    if (!mounted) return;
    _slideController.reverse().then((_) {
      if (!mounted) return;
      setState(() => _isVisible = false); // hide completely during gap
      _startInterval();                   // wait 5s before next
    });
  }

  /// Step 3: Wait 5 seconds, then advance to next notification
  void _startInterval() {
    _intervalTimer?.cancel();
    _intervalTimer = Timer(const Duration(seconds: _intervalSeconds), () {
      if (!mounted) return;
      setState(() {
        _currentIndex = (_currentIndex + 1) % widget.notifications.length;
      });
      _startCycle(); // Step 1 again for next notification
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _intervalTimer?.cancel();
    _slideController.dispose();
    _progressController.dispose();
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
    // During the 5s gap, render nothing
    if (!_isVisible) return const SizedBox.shrink();

    final item = widget.notifications[_currentIndex];

    return ClipRect(
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 10, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _resolveIcon(item.icon),
                        color: item.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
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
                              height: 1.35,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: widget.onDismiss,
                      child: const Padding(
                        padding: EdgeInsets.all(6),
                        child: Icon(
                          Icons.close,
                          size: 18,
                          color: Color(0xFFBDBDBD),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 0, 14, 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: AnimatedBuilder(
                          animation: _progressController,
                          builder: (_, __) => LinearProgressIndicator(
                            value: _progressController.value,
                            minHeight: 3,
                            backgroundColor: item.color.withOpacity(0.15),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(item.color),
                          ),
                        ),
                      ),
                    ),
                    if (widget.notifications.length > 1) ...[
                      const SizedBox(width: 10),
                      Row(
                        children: List.generate(
                          widget.notifications.length,
                          (i) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.only(left: 4),
                            width: i == _currentIndex ? 16 : 6,
                            height: 4,
                            decoration: BoxDecoration(
                              color: i == _currentIndex
                                  ? item.color
                                  : item.color.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                      ),
                    ],
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
