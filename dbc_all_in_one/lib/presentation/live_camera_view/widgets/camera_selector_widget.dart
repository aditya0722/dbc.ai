import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Camera selector dropdown widget for switching between multiple cameras
class CameraSelectorWidget extends StatelessWidget {
  final String selectedCamera;
  final List<String> cameras;
  final ValueChanged<String?> onCameraChanged;

  const CameraSelectorWidget({
    super.key,
    required this.selectedCamera,
    required this.cameras,
    required this.onCameraChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomIconWidget(
            iconName: 'videocam',
            color: theme.colorScheme.primary,
            size: 20,
          ),
          SizedBox(width: 2.w),
          DropdownButton<String>(
            value: selectedCamera,
            underline: const SizedBox(),
            icon: CustomIconWidget(
              iconName: 'arrow_drop_down',
              color: theme.colorScheme.onSurface,
              size: 20,
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            items: cameras.map((String camera) {
              return DropdownMenuItem<String>(
                value: camera,
                child: Text(camera),
              );
            }).toList(),
            onChanged: onCameraChanged,
          ),
        ],
      ),
    );
  }
}
