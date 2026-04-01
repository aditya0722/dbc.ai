import 'package:flutter/material.dart';

class NewsInsightCardWidget extends StatefulWidget {
  final Map<String, dynamic> newsItem;
  final VoidCallback? onTap;
  final VoidCallback? onSaveTap;

  const NewsInsightCardWidget({
    super.key,
    required this.newsItem,
    this.onTap,
    this.onSaveTap,
  });

  @override
  State<NewsInsightCardWidget> createState() => _NewsInsightCardWidgetState();
}

class _NewsInsightCardWidgetState extends State<NewsInsightCardWidget> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _hovered
                  ? const Color(0xFF6C22C8).withOpacity(0.3)
                  : const Color(0xFFE5E7EB),
            ),
            boxShadow: _hovered
                ? [
                    BoxShadow(
                      color: const Color(0xFF6C22C8).withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    )
                  ]
                : [],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image
              ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(10)),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    widget.newsItem['imageUrl'] ?? '',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF1F2937),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category tag + time
                    Row(
                      children: [
                        Text(
                          (widget.newsItem['category'] as String? ?? '')
                              .toUpperCase(),
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6C22C8),
                            letterSpacing: 0.8,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          widget.newsItem['timestamp'] ?? '',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 7),

                    // Title
                    Text(
                      widget.newsItem['title'] ?? '',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 6),

                    // Excerpt
                    Text(
                      widget.newsItem['summary'] ?? '',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF6B7280),
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 12),

                    // Author row
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: const Color(0xFF6C22C8)
                              .withOpacity(0.15),
                          child: Text(
                            (widget.newsItem['source'] as String? ?? 'N')
                                .substring(0, 1),
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6C22C8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 7),
                        Expanded(
                          child: Text(
                            widget.newsItem['source'] ?? '',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF374151),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onSaveTap,
                          child: Icon(
                            widget.newsItem['isSaved'] == true
                                ? Icons.bookmark
                                : Icons.bookmark_border,
                            size: 16,
                            color: widget.newsItem['isSaved'] == true
                                ? const Color(0xFF6C22C8)
                                : const Color(0xFF9CA3AF),
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
    );
  }
}