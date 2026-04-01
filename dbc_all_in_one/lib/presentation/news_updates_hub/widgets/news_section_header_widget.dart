import 'package:flutter/material.dart';

class NewsSectionHeaderWidget extends StatelessWidget {
  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  const NewsSectionHeaderWidget({
    super.key,
    required this.title,
    this.actionLabel = 'View All Updates',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: onAction,
          child: Row(
            children: [
              Text(
                actionLabel,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6C22C8),
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.arrow_forward,
                size: 13,
                color: Color(0xFF6C22C8),
              ),
            ],
          ),
        ),
      ],
    );
  }
}