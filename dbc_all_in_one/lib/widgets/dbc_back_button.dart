import 'package:flutter/material.dart';

/// Reusable back button styled to match the security screen.
/// Keeps a minimum tap target and plays nicely inside rows/toolbars.
class DBCBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Color iconColor;
  final Color? backgroundColor;
  final double iconSize;

  const DBCBackButton({
    super.key,
    this.onPressed,
    this.iconColor = const Color(0xFF1A1A1A),
    this.backgroundColor,
    this.iconSize = 20.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: Material(
        color: backgroundColor ?? Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: IconButton(
          padding: const EdgeInsets.all(8.0),
          splashRadius: 20,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: iconSize,
            color: iconColor,
          ),
          onPressed: onPressed ?? () => Navigator.maybePop(context),
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        ),
      ),
    );
  }
}
