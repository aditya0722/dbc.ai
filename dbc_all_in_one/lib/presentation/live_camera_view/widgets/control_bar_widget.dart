import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Bottom control bar with snapshot, audio, and motion detection controls
class ControlBarWidget extends StatelessWidget {
  final VoidCallback onSnapshotPressed;
  final bool isAudioEnabled;
  final VoidCallback onAudioToggle;
  final double motionSensitivity;
  final ValueChanged<double> onSensitivityChanged;

  const ControlBarWidget({
    super.key,
    required this.onSnapshotPressed,
    required this.isAudioEnabled,
    required this.onAudioToggle,
    required this.motionSensitivity,
    required this.onSensitivityChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildControlButton(
                  context,
                  theme,
                  icon: 'camera_alt',
                  label: 'Snapshot',
                  onPressed: onSnapshotPressed,
                ),
                _buildControlButton(
                  context,
                  theme,
                  icon: isAudioEnabled ? 'mic' : 'mic_off',
                  label: 'Audio',
                  onPressed: onAudioToggle,
                  isActive: isAudioEnabled,
                ),
                _buildControlButton(
                  context,
                  theme,
                  icon: 'settings',
                  label: 'Settings',
                  onPressed: () {
                    Navigator.pushNamed(context, '/business-dashboard');
                  },
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'motion_photos_on',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Motion Sensitivity',
                  style: theme.textTheme.labelMedium,
                ),
                Expanded(
                  child: Slider(
                    value: motionSensitivity,
                    min: 0.0,
                    max: 1.0,
                    divisions: 10,
                    label: '${(motionSensitivity * 100).toInt()}%',
                    onChanged: onSensitivityChanged,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    BuildContext context,
    ThemeData theme, {
    required String icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 15.w,
          height: 15.w,
          decoration: BoxDecoration(
            color: isActive
                ? theme.colorScheme.primary.withValues(alpha: 0.2)
                : theme.colorScheme.surface,
            shape: BoxShape.circle,
            border: Border.all(
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outline.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: IconButton(
            icon: CustomIconWidget(
              iconName: icon,
              color: isActive
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
              size: 24,
            ),
            onPressed: onPressed,
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: isActive
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
