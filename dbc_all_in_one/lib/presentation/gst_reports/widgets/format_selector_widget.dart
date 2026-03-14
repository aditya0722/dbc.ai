import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class FormatSelectorWidget extends StatelessWidget {
  final String selectedFormat;
  final Function(String) onFormatChanged;

  const FormatSelectorWidget({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Export Format',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: _FormatOption(
                format: 'PDF',
                icon: Icons.picture_as_pdf,
                isSelected: selectedFormat == 'PDF',
                onTap: () => onFormatChanged('PDF'),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: _FormatOption(
                format: 'Excel',
                icon: Icons.table_chart,
                isSelected: selectedFormat == 'Excel',
                onTap: () => onFormatChanged('Excel'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FormatOption extends StatelessWidget {
  final String format;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FormatOption({
    required this.format,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF2196F3).withAlpha(26)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20.0,
              color: isSelected ? const Color(0xFF2196F3) : Colors.grey[700],
            ),
            SizedBox(width: 2.w),
            Text(
              format,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? const Color(0xFF2196F3) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
