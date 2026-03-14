import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class WorkflowNodeWidget extends StatelessWidget {
  final Map<String, dynamic> module;
  final Function(String) onScreenTap;

  const WorkflowNodeWidget({
    super.key,
    required this.module,
    required this.onScreenTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = module['color'] as Color;
    final screens = module['screens'] as List<Map<String, dynamic>>;
    final connections = module['connections'] as List<String>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withAlpha(77),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withAlpha(179)]),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    module['icon'] as IconData,
                    color: color,
                    size: 6.w,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module['name'],
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${screens.length} Screen${screens.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(230),
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(3.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...screens.map((screen) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 2.h),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => onScreenTap(screen['route']),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: BoxDecoration(
                            color: color.withAlpha(26),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: color.withAlpha(77)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(1.5.w),
                                decoration: BoxDecoration(
                                  color: color.withAlpha(51),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.touch_app,
                                  color: color,
                                  size: 5.w,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      screen['title'],
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[900],
                                      ),
                                    ),
                                    SizedBox(height: 0.5.h),
                                    Text(
                                      screen['description'],
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 4.w,
                                color: color,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
                if (connections.isNotEmpty) ...[
                  Divider(color: Colors.grey[300]),
                  SizedBox(height: 1.h),
                  Row(
                    children: [
                      Icon(Icons.link, color: Colors.grey[600], size: 4.w),
                      SizedBox(width: 1.w),
                      Text(
                        'Connected to:',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),
                  Wrap(
                    spacing: 1.w,
                    runSpacing: 1.h,
                    children: connections.map((connection) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 0.5.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          connection,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.grey[700],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
