import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class NotificationSearchWidget extends StatefulWidget {
  final Function(String) onSearch;
  final VoidCallback onClear;

  const NotificationSearchWidget({
    Key? key,
    required this.onSearch,
    required this.onClear,
  }) : super(key: key);

  @override
  State<NotificationSearchWidget> createState() =>
      _NotificationSearchWidgetState();
}

class _NotificationSearchWidgetState extends State<NotificationSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(2.w),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search notifications...',
          hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    widget.onClear();
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none,
          ),
          contentPadding:
              EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
        ),
        onSubmitted: widget.onSearch,
        onChanged: (value) => setState(() {}),
      ),
    );
  }
}
