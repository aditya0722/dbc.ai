import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class SourceSelectorWidget extends StatelessWidget {
  final Function(String) onSourceSelected;

  const SourceSelectorWidget({super.key, required this.onSourceSelected});

  @override
  Widget build(BuildContext context) {
    final sources = [
      {
        'name': 'QuickBooks',
        'icon': Icons.business,
        'color': const Color(0xFF2CA01C)
      },
      {
        'name': 'Tally',
        'icon': Icons.account_balance,
        'color': const Color(0xFFE53935)
      },
      {
        'name': 'SAP',
        'icon': Icons.warehouse,
        'color': const Color(0xFF0F52BA)
      },
      {
        'name': 'Excel',
        'icon': Icons.table_chart,
        'color': const Color(0xFF217346)
      },
      {'name': 'Zoho', 'icon': Icons.cloud, 'color': const Color(0xFFE8710A)},
      {
        'name': 'FreshBooks',
        'icon': Icons.receipt_long,
        'color': const Color(0xFF0075DD)
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Select Source Platform',
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
        SizedBox(height: 2.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 2.w,
            mainAxisSpacing: 1.h,
            childAspectRatio: 1.2,
          ),
          itemCount: sources.length,
          itemBuilder: (context, index) {
            final source = sources[index];
            return InkWell(
              onTap: () =>
                  onSourceSelected(source['name'].toString().toLowerCase()),
              borderRadius: BorderRadius.circular(12.0),
              child: Container(
                decoration: BoxDecoration(
                  color: (source['color'] as Color).withAlpha(26),
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                      color: (source['color'] as Color).withAlpha(77)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(source['icon'] as IconData,
                        size: 32, color: source['color'] as Color),
                    SizedBox(height: 0.5.h),
                    Text(source['name'] as String,
                        style: TextStyle(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                            color: source['color'] as Color)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
