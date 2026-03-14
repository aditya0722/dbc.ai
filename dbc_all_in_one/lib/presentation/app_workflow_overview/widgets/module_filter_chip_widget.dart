import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ModuleFilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onSelected;

  const ModuleFilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? Colors.grey[700]!;

    return Padding(
      padding: EdgeInsets.only(right: 2.w),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onSelected(),
        backgroundColor: Colors.grey[200],
        selectedColor: chipColor.withAlpha(51),
        checkmarkColor: chipColor,
        labelStyle: TextStyle(
          color: isSelected ? chipColor : Colors.grey[700],
          fontSize: 11.sp,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        ),
        side: BorderSide(
          color: isSelected ? chipColor : Colors.grey[300]!,
          width: isSelected ? 2 : 1,
        ),
        padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      ),
    );
  }
}
