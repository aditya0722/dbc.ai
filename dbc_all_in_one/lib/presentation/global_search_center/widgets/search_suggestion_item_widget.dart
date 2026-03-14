import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class SearchSuggestionItemWidget extends StatelessWidget {
  final String suggestion;
  final VoidCallback onTap;

  const SearchSuggestionItemWidget({
    super.key,
    required this.suggestion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        child: Row(
          children: [
            Icon(Icons.search, size: 20.0, color: Colors.grey[400]),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                suggestion,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[800]),
              ),
            ),
            Icon(Icons.arrow_outward, size: 16.0, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
