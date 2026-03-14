import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class NewsSearchBarWidget extends StatefulWidget {
  final Function(String) onSearchChanged;

  const NewsSearchBarWidget({super.key, required this.onSearchChanged});

  @override
  State<NewsSearchBarWidget> createState() => _NewsSearchBarWidgetState();
}

class _NewsSearchBarWidgetState extends State<NewsSearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: TextField(
        controller: _searchController,
        onChanged: widget.onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search news articles...',
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 22.h),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: Icon(
                      Icons.clear,
                      color: Colors.grey[600],
                      size: 20.h,
                    ),
                    onPressed: () {
                      _searchController.clear();
                      widget.onSearchChanged('');
                    },
                  )
                  : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.h),
            borderSide: BorderSide(
              color: Theme.of(context).primaryColor,
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
      ),
    );
  }
}
