import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Main video player widget with gesture controls and AI detection overlays
class VideoPlayerWidget extends StatelessWidget {
  final CameraController? cameraController;
  final bool isInitialized;
  final List<Map<String, dynamic>> detections;
  final VoidCallback onDoubleTap;
  final Function(ScaleUpdateDetails) onScaleUpdate;

  const VideoPlayerWidget({
    super.key,
    required this.cameraController,
    required this.isInitialized,
    required this.detections,
    required this.onDoubleTap,
    required this.onScaleUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (!isInitialized || cameraController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: theme.colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing camera...',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onScaleUpdate: onScaleUpdate,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CameraPreview(cameraController!),
          ...detections.map((detection) => _buildDetectionOverlay(
                context,
                theme,
                detection,
              )),
        ],
      ),
    );
  }

  Widget _buildDetectionOverlay(
    BuildContext context,
    ThemeData theme,
    Map<String, dynamic> detection,
  ) {
    final String type = detection['type'] as String;
    final double confidence = detection['confidence'] as double;
    final double left = detection['left'] as double;
    final double top = detection['top'] as double;
    final double width = detection['width'] as double;
    final double height = detection['height'] as double;

    final Color boxColor = type == 'person'
        ? theme.colorScheme.primary
        : theme.colorScheme.secondary;

    return Positioned(
      left: left,
      top: top,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          border: Border.all(
            color: boxColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
            decoration: BoxDecoration(
              color: boxColor.withValues(alpha: 0.9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                bottomRight: Radius.circular(4),
              ),
            ),
            child: Text(
              '$type ${(confidence * 100).toStringAsFixed(0)}%',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
