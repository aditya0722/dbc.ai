import 'package:flutter/material.dart';

class NewsSubscribeBannerWidget extends StatefulWidget {
  final VoidCallback? onSubscribe;

  const NewsSubscribeBannerWidget({
    super.key,
    this.onSubscribe,
  });

  @override
  State<NewsSubscribeBannerWidget> createState() =>
      _NewsSubscribeBannerWidgetState();
}

class _NewsSubscribeBannerWidgetState extends State<NewsSubscribeBannerWidget> {
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Text content
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'The Executive Digest',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Get a weekly briefing of curated insights, market shifts, and leadership strategies delivered directly to your secure inbox.',
                  style: TextStyle(
                    fontSize: 12,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Email + button
          Expanded(
            flex: 2,
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _emailController,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF111827)),
                      decoration: InputDecoration(
                        hintText: 'executive@domain.com',
                        hintStyle: const TextStyle(
                            fontSize: 13, color: Color(0xFF9CA3AF)),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFD1D5DB)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFF6C22C8)),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: widget.onSubscribe,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C22C8),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                    ),
                    child: const Text(
                      'Subscribe',
                      style:
                          TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
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
