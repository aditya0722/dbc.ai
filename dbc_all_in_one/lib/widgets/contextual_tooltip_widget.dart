import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ContextualTooltipWidget extends StatefulWidget {
  final Widget child;
  final String tooltipMessage;
  final String? detailedHelp;
  final bool showOnFirstView;

  const ContextualTooltipWidget({
    super.key,
    required this.child,
    required this.tooltipMessage,
    this.detailedHelp,
    this.showOnFirstView = false,
  });

  @override
  State<ContextualTooltipWidget> createState() =>
      _ContextualTooltipWidgetState();
}

class _ContextualTooltipWidgetState extends State<ContextualTooltipWidget> {
  bool _showTooltip = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    if (widget.showOnFirstView) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showAutoTooltip();
      });
    }
  }

  void _showAutoTooltip() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showTooltip = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showTooltip = false;
            });
          }
        });
      }
    });
  }

  void _showDetailedHelp() {
    if (widget.detailedHelp == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.blue[700]),
            const SizedBox(width: 8),
            const Expanded(child: Text('Help')),
          ],
        ),
        content: Text(widget.detailedHelp!),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        setState(() {
          _showTooltip = !_showTooltip;
        });
      },
      child: Stack(
        children: [
          widget.child,
          if (_showTooltip)
            Positioned(
              top: 0,
              right: 0,
              child: GestureDetector(
                onTap: widget.detailedHelp != null ? _showDetailedHelp : null,
                child: Container(
                  padding: EdgeInsets.all(2.w),
                  constraints: BoxConstraints(maxWidth: 70.w),
                  decoration: BoxDecoration(
                    color: Colors.blue[700],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(51),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lightbulb, color: Colors.amber, size: 4.w),
                          SizedBox(width: 1.w),
                          Expanded(
                            child: Text(
                              widget.tooltipMessage,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 11.sp,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showTooltip = false;
                              });
                            },
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 4.w,
                            ),
                          ),
                        ],
                      ),
                      if (widget.detailedHelp != null) ...[
                        SizedBox(height: 1.h),
                        Text(
                          'Tap for more details',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 10.sp,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }
}
