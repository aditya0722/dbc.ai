import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class PaymentStatusFilterChipWidget extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? color;
  final VoidCallback onTap;

  const PaymentStatusFilterChipWidget({
    super.key,
    required this.label,
    required this.isSelected,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? (color ?? Theme.of(context).primaryColor)
              : Colors.white,
          borderRadius: BorderRadius.circular(5.w),
          border: Border.all(
            color: color ?? Theme.of(context).primaryColor,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : (color ?? Colors.black87),
          ),
        ),
      ),
    );
  }
}
