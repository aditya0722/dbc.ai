import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class ExportButtonWidget extends StatelessWidget {
  final String format;
  final VoidCallback onExport;

  const ExportButtonWidget({
    super.key,
    required this.format,
    required this.onExport,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onExport,
      icon: Icon(
        format == 'PDF' ? Icons.picture_as_pdf : Icons.table_chart,
        size: 18.0,
      ),
      label: Text(
        'Export as $format',
        style: TextStyle(fontSize: 12.sp),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(
          horizontal: 3.w,
          vertical: 1.h,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}
