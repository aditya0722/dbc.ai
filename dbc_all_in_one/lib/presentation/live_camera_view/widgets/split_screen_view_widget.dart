import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


/// Split-screen view for monitoring multiple cameras simultaneously
class SplitScreenViewWidget extends StatelessWidget {
  final List<CameraController?> cameraControllers;
  final int? selectedCameraIndex;
  final ValueChanged<int> onCameraSelected;

  const SplitScreenViewWidget({
    super.key,
    required this.cameraControllers,
    this.selectedCameraIndex,
    required this.onCameraSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GridView.builder(
      padding: EdgeInsets.all(2.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 16 / 9,
      ),
      itemCount: cameraControllers.length > 4 ? 4 : cameraControllers.length,
      itemBuilder: (context, index) {
        final controller = cameraControllers[index];
        final isSelected = selectedCameraIndex == index;

        return GestureDetector(
          onTap: () => onCameraSelected(index),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
                width: isSelected ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: controller != null && controller.value.isInitialized
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(controller),
                        Positioned(
                          top: 1.h,
                          left: 2.w,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.h,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surface
                                  .withValues(alpha: 0.9),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Camera ${index + 1}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.black,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
