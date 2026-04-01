import 'package:flutter/material.dart';

class NewsPodcastPromoWidget extends StatelessWidget {
  final VoidCallback? onPlay;

  const NewsPodcastPromoWidget({
    super.key,
    this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'NEW PODCAST',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9CA3AF),
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Leading with Intent',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF111827),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onPlay,
            child: Icon(
              Icons.play_circle_fill,
              color: const Color(0xFF6C22C8),
              size: 36,
            ),
          ),
        ],
      ),
    );
  }
}