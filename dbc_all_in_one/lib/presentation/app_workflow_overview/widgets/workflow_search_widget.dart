import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WorkflowSearchWidget extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;

  const WorkflowSearchWidget({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Search screens or modules...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 12.sp),
          prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 5.w),
          suffixIcon: controller.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[600], size: 5.w),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 3.w,
            vertical: 1.5.h,
          ),
        ),
        style: TextStyle(fontSize: 12.sp, color: Colors.grey[900]),
      ),
    );
  }
}
