import 'package:flutter/material.dart';

class NewsHeroCardWidget extends StatefulWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback? onTap;

  const NewsHeroCardWidget({
    super.key,
    required this.newsItem,
    this.onTap,
  });

  @override
  State<NewsHeroCardWidget> createState() => _NewsHeroCardWidgetState();
}

class _NewsHeroCardWidgetState extends State<NewsHeroCardWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    )
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                // Background Image
                SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: Image.network(
                    widget.newsItem['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                ),

                // Gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.85),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // Content
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C22C8),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'FEATURED REPORT',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Title
                      Text(
                        widget.newsItem['title'] ?? '',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Meta row
                      Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined,
                              size: 11, color: Color(0xFFD1D5DB)),
                          const SizedBox(width: 4),
                          Text(
                            widget.newsItem['timestamp'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFFD1D5DB),
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Icon(Icons.access_time_outlined,
                              size: 11, color: Color(0xFFD1D5DB)),
                          const SizedBox(width: 4),
                          Text(
                            '${widget.newsItem['readingTime'] ?? '5 min'} read',
                            style: const TextStyle(
                              color: Color(0xFFD1D5DB),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}