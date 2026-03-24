import 'dart:async';
import 'package:flutter/material.dart';

class AppNotificationWidget extends StatefulWidget {
  final String message;
  final Color color;
  final Duration duration;
  final VoidCallback onDismiss;

  const AppNotificationWidget({
    super.key,
    required this.message,
    required this.color,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<AppNotificationWidget> createState() => _AppNotificationWidgetState();
}

class _AppNotificationWidgetState extends State<AppNotificationWidget>
    with SingleTickerProviderStateMixin {
  double progress = 1.0;
  Timer? timer;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    )..forward();

    final totalMs = widget.duration.inMilliseconds;
    const interval = 50;

    timer = Timer.periodic(const Duration(milliseconds: interval), (t) {
      setState(() {
        progress -= interval / totalMs;

        if (progress <= 0) {
          t.cancel();
          widget.onDismiss();
        }
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  IconData _getIcon() {
    if (widget.color == Colors.green) return Icons.payments;
    if (widget.color == Colors.red) return Icons.warning;
    if (widget.color == Colors.orange) return Icons.inventory;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween(
        begin: const Offset(1, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      )),
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: 320,
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 12,
              )
            ],
            border: Border(
              left: BorderSide(
                width: 5,
                color: widget.color,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(_getIcon(), color: widget.color),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(widget.color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
