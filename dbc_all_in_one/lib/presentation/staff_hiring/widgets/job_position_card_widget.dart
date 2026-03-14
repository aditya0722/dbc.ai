import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class JobPositionCardWidget extends StatelessWidget {
  final Map<String, dynamic> position;
  final VoidCallback? onTap;

  const JobPositionCardWidget({
    Key? key,
    required this.position,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      position['title'] ?? 'Untitled Position',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  _buildEmploymentTypeBadge(
                      position['employment_type'] ?? 'full_time'),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.business_outlined,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    position['department'] ?? 'No Department',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                  SizedBox(width: 16.w),
                  Icon(Icons.location_on_outlined,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    position['location'] ?? 'Remote',
                    style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined,
                      size: 16.sp, color: Colors.grey[600]),
                  SizedBox(width: 4.w),
                  Text(
                    position['salary_range'] ?? 'Competitive',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                position['description'] ?? 'No description available',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 12.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildExperienceLevelChip(
                      position['experience_level'] ?? 'mid'),
                  Row(
                    children: [
                      Icon(Icons.people_outline,
                          size: 16.sp, color: Colors.grey[600]),
                      SizedBox(width: 4.w),
                      Text(
                        '0 applicants',
                        style:
                            TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmploymentTypeBadge(String type) {
    final Map<String, Map<String, dynamic>> typeConfig = {
      'full_time': {'label': 'Full Time', 'color': Colors.blue},
      'part_time': {'label': 'Part Time', 'color': Colors.orange},
      'contract': {'label': 'Contract', 'color': Colors.purple},
      'internship': {'label': 'Internship', 'color': Colors.green},
    };

    final config = typeConfig[type] ?? typeConfig['full_time']!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (config['color'] as Color).withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: config['color'],
        ),
      ),
    );
  }

  Widget _buildExperienceLevelChip(String level) {
    final Map<String, Map<String, dynamic>> levelConfig = {
      'entry': {'label': 'Entry Level', 'color': Colors.teal},
      'mid': {'label': 'Mid Level', 'color': Colors.indigo},
      'senior': {'label': 'Senior Level', 'color': Colors.deepOrange},
      'lead': {'label': 'Lead', 'color': Colors.red},
    };

    final config = levelConfig[level] ?? levelConfig['mid']!;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        border: Border.all(color: config['color'], width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        config['label'],
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: config['color'],
        ),
      ),
    );
  }
}
