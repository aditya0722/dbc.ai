import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:video_player/video_player.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/alert_notification_widget.dart';
import './widgets/camera_selector_widget.dart';
import './widgets/control_bar_widget.dart';
import './widgets/emergency_alert_button_widget.dart';
import './widgets/recording_indicator_widget.dart';
import './widgets/split_screen_view_widget.dart';
import './widgets/video_player_widget.dart';

/// Live Camera View screen for real-time CCTV monitoring with AI-powered detection
class LiveCameraView extends StatefulWidget {
  const LiveCameraView({super.key});

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView> {
  // Camera management
  List<CameraDescription>? _cameras;
  CameraController? _cameraController;
  int _selectedCameraIndex = 0;
  bool _isCameraInitialized = false;
  bool _isRecording = false;

  // Demo video management
  VideoPlayerController? _demoVideoController;
  bool _isDemoMode = false;
  bool _isVideoInitialized = false;

  // UI state
  bool _isAudioEnabled = false;
  double _motionSensitivity = 0.5;
  bool _showAlert = false;
  String _alertMessage = '';
  String _alertTimestamp = '';
  bool _isSplitScreenMode = false;
  int? _selectedSplitScreenCamera;
  double _currentZoom = 1.0;
  bool _isFitMode = true;

  // Mock data for cameras
  final List<String> _cameraNames = [
    'Front Entrance',
    'Kitchen Area',
    'Store Room',
    'Counter Zone',
  ];

  // Mock AI detections
  final List<Map<String, dynamic>> _mockDetections = [
    {
      'type': 'person',
      'confidence': 0.95,
      'left': 50.0,
      'top': 100.0,
      'width': 80.0,
      'height': 120.0,
    },
    {
      'type': 'vehicle',
      'confidence': 0.87,
      'left': 200.0,
      'top': 150.0,
      'width': 100.0,
      'height': 80.0,
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _demoVideoController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameraPermission = await Permission.camera.request();
      if (!cameraPermission.isGranted) {
        _showToast('Camera permission denied - Using demo video');
        await _initializeDemoVideo();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _showToast('No cameras available - Using demo video');
        await _initializeDemoVideo();
        return;
      }

      await _setupCamera(_selectedCameraIndex);
    } catch (e) {
      _showToast('Failed to initialize camera - Using demo video');
      await _initializeDemoVideo();
    }
  }

  Future<void> _initializeDemoVideo() async {
    try {
      // False CCTV footage URL - loops continuously to simulate surveillance
      const falseCCTVFootageUrl =
          'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4';

      _demoVideoController =
          VideoPlayerController.networkUrl(Uri.parse(falseCCTVFootageUrl));

      await _demoVideoController!.initialize();
      // Enable continuous loop for false CCTV footage
      await _demoVideoController!.setLooping(true);
      await _demoVideoController!.play();

      if (mounted) {
        setState(() {
          _isDemoMode = true;
          _isVideoInitialized = true;
        });
      }
    } catch (e) {
      _showToast('Failed to load false CCTV footage');
    }
  }

  Future<void> _setupCamera(int cameraIndex) async {
    if (_cameras == null || _cameras!.isEmpty) return;

    try {
      _cameraController?.dispose();

      final camera = _cameras![cameraIndex];
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: _isAudioEnabled,
      );

      await _cameraController!.initialize();
      await _cameraController!.setFocusMode(FocusMode.auto);

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _selectedCameraIndex = cameraIndex;
        });
      }
    } catch (e) {
      _showToast('Failed to setup camera');
    }
  }

  Future<void> _captureSnapshot() async {
    if (_isDemoMode) {
      _showToast('Snapshot feature not available in demo mode');

      // Simulate motion detection alert even in demo mode
      setState(() {
        _showAlert = true;
        _alertMessage =
            'Motion detected in ${_cameraNames[_selectedCameraIndex]} (Demo)';
        _alertTimestamp = DateTime.now().toString().substring(0, 19);
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showAlert = false);
        }
      });
      return;
    }

    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _showToast('Camera not ready');
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();
      _showToast('Snapshot saved to gallery');

      // Simulate motion detection alert
      setState(() {
        _showAlert = true;
        _alertMessage =
            'Motion detected in ${_cameraNames[_selectedCameraIndex]}';
        _alertTimestamp = DateTime.now().toString().substring(0, 19);
      });

      Future.delayed(const Duration(seconds: 5), () {
        if (mounted) {
          setState(() => _showAlert = false);
        }
      });
    } catch (e) {
      _showToast('Failed to capture snapshot');
    }
  }

  void _toggleAudio() {
    setState(() {
      _isAudioEnabled = !_isAudioEnabled;
    });
    _setupCamera(_selectedCameraIndex);
  }

  void _handleEmergencyAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'emergency',
              color: Theme.of(context).colorScheme.error,
              size: 24,
            ),
            SizedBox(width: 2.w),
            const Text('Emergency Alert'),
          ],
        ),
        content: Text(
          'This will notify authorities with current camera snapshot and location. Continue?',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showToast('Emergency alert sent to authorities');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _handleDoubleTap() {
    setState(() {
      _isFitMode = !_isFitMode;
    });
    _showToast(_isFitMode ? 'Fit mode' : 'Fill mode');
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    setState(() {
      _currentZoom = (_currentZoom * details.scale).clamp(1.0, 8.0);
    });

    _cameraController!.setZoomLevel(_currentZoom);
  }

  void _showToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black87,
      textColor: Colors.white,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Main video player or split screen
          _isSplitScreenMode
              ? SplitScreenViewWidget(
                  cameraControllers: [_cameraController],
                  selectedCameraIndex: _selectedSplitScreenCamera,
                  onCameraSelected: (index) {
                    setState(() => _selectedSplitScreenCamera = index);
                  },
                )
              : _isDemoMode
                  ? _buildDemoVideoPlayer()
                  : VideoPlayerWidget(
                      cameraController: _cameraController,
                      isInitialized: _isCameraInitialized,
                      detections: _mockDetections,
                      onDoubleTap: _handleDoubleTap,
                      onScaleUpdate: _handleScaleUpdate,
                    ),

          // Demo mode indicator - False CCTV footage label
          if (_isDemoMode)
            SafeArea(
              child: Positioned(
                top: 12.h,
                left: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color:
                        theme.colorScheme.errorContainer.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.error,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'videocam',
                        color: theme.colorScheme.error,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'FALSE CCTV - Looping Footage',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: theme.colorScheme.error,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Top overlay controls
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CameraSelectorWidget(
                    selectedCamera: _cameraNames[_selectedCameraIndex],
                    cameras: _cameraNames,
                    onCameraChanged: (value) {
                      if (value != null) {
                        final index = _cameraNames.indexOf(value);
                        if (_isDemoMode && index == 0) {
                          // Already showing demo for Front Entrance
                          return;
                        }
                        _setupCamera(index);
                      }
                    },
                  ),
                  Row(
                    children: [
                      RecordingIndicatorWidget(isRecording: _isRecording),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName:
                                _isSplitScreenMode ? 'fullscreen' : 'grid_view',
                            color: theme.colorScheme.onSurface,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _isSplitScreenMode = !_isSplitScreenMode;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 2.w),
                      Container(
                        decoration: BoxDecoration(
                          color:
                              theme.colorScheme.surface.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: CustomIconWidget(
                            iconName: 'settings',
                            color: theme.colorScheme.onSurface,
                            size: 24,
                          ),
                          onPressed: () {
                            Navigator.pushNamed(context, '/business-dashboard');
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Alert notification
          if (_showAlert)
            AlertNotificationWidget(
              message: _alertMessage,
              timestamp: _alertTimestamp,
              onDismiss: () {
                setState(() => _showAlert = false);
              },
            ),

          // Emergency alert button
          EmergencyAlertButtonWidget(
            onPressed: _handleEmergencyAlert,
          ),

          // Bottom control bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: ControlBarWidget(
              onSnapshotPressed: _captureSnapshot,
              isAudioEnabled: _isAudioEnabled,
              onAudioToggle: _toggleAudio,
              motionSensitivity: _motionSensitivity,
              onSensitivityChanged: (value) {
                setState(() => _motionSensitivity = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDemoVideoPlayer() {
    if (!_isVideoInitialized || _demoVideoController == null) {
      return Container(
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
              SizedBox(height: 2.h),
              Text(
                'Loading false CCTV footage...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onDoubleTap: _handleDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: _demoVideoController!.value.aspectRatio,
              child: VideoPlayer(_demoVideoController!),
            ),
          ),
          // Timestamp overlay to show continuous loop
          Positioned(
            top: 14.h,
            right: 4.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'LOOP: ${_demoVideoController!.value.position.inMinutes}:${(_demoVideoController!.value.position.inSeconds % 60).toString().padLeft(2, '0')}',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontFamily: 'monospace',
                    ),
              ),
            ),
          ),
          ..._mockDetections.map((detection) => _buildDetectionOverlay(
                context,
                Theme.of(context),
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
