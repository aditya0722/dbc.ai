import 'package:flutter/material.dart';

class NewsMarketPanelWidget extends StatelessWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback? onViewAnalytics;

  const NewsMarketPanelWidget({
    super.key,
    required this.newsItem,
    this.onViewAnalytics,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6C22C8),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon row
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Title
          const Text(
            'Q3 Market Performance Analysis is now live',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),

          const SizedBox(height: 10),

          // Description
          Text(
            newsItem['summary'] ??
                'Deep dive into our internal metrics and performance benchmarks for the previous quarter.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 12,
              height: 1.5,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),

          const Spacer(),

          // CTA row
          GestureDetector(
            onTap: onViewAnalytics,
            child: Row(
              children: [
                const Text(
                  'View Analytics',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}