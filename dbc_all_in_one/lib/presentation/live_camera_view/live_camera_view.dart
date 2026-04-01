import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/dbc_back_button.dart';

class LiveCameraView extends StatefulWidget {
  const LiveCameraView({super.key});

  @override
  State<LiveCameraView> createState() => _LiveCameraViewState();
}

class _LiveCameraViewState extends State<LiveCameraView>
    with TickerProviderStateMixin {
  // ── UI state ──────────────────────────────────────────────────────────────
  int _selectedCameraIndex = 0;
  bool _isAudioEnabled = false;
  double _motionSensitivity = 0.09;
  bool _showAlert = false;
  String _alertMessage = '';
  bool _isSplitScreenMode = false;
  int? _selectedSplitScreenCamera;
  double _currentZoom = 1.0;
  bool _showControls = true;

  AnimationController? _pulseCtrl;
  Animation<double>? _pulseAnim;
  Timer? _clockTicker;
  DateTime _now = DateTime.now();

  // ── Theme ─────────────────────────────────────────────────────────────────
  static const _purple = Color(0xFF6B46C1);
  static const _surface = Colors.white;
  static const _dark = Color(0xFF1A1A1A);
  static const _feedBg = Color(0xFF0A0A12);

  // ── Camera data ───────────────────────────────────────────────────────────
  static const List<Map<String, Object>> _cameraList = [
    {
      'name': 'Front Entrance',
      'zone': 'Zone A',
      'icon': Icons.door_front_door_outlined,
      'imageUrl':
          'https://images.unsplash.com/photo-1557597774-9d273605dfa9?w=800&q=80',
    },
    {
      'name': 'Kitchen Area',
      'zone': 'Zone B',
      'icon': Icons.kitchen_outlined,
      'imageUrl':
          'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80',
    },
    {
      'name': 'Store Room',
      'zone': 'Zone C',
      'icon': Icons.inventory_2_outlined,
      'imageUrl':
          'https://images.unsplash.com/photo-1558494949-ef010cbdcc31?w=800&q=80',
    },
    {
      'name': 'Counter Zone',
      'zone': 'Zone D',
      'icon': Icons.point_of_sale_outlined,
      'imageUrl':
          'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&q=80',
    },
  ];

  static const List<Map<String, Object>> _mockDetections = [
    {
      'type': 'person',
      'confidence': 0.95,
      'left': 60.0,
      'top': 90.0,
      'width': 80.0,
      'height': 120.0
    },
    {
      'type': 'vehicle',
      'confidence': 0.87,
      'left': 220.0,
      'top': 130.0,
      'width': 100.0,
      'height': 70.0
    },
  ];

  String _camName(int i) => _cameraList[i]['name'] as String;
  String _camZone(int i) => _cameraList[i]['zone'] as String;
  IconData _camIcon(int i) => _cameraList[i]['icon'] as IconData;
  String _camImage(int i) => _cameraList[i]['imageUrl'] as String;

  // ── Lifecycle ─────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        duration: const Duration(milliseconds: 900), vsync: this)
      ..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _pulseCtrl!, curve: Curves.easeInOut));
    _clockTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _pulseCtrl?.dispose();
    _clockTicker?.cancel();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────
  void _captureSnapshot() {
    _showToast('Snapshot captured (Demo)');
    _triggerAlert('Motion detected · ${_camName(_selectedCameraIndex)}');
  }

  void _triggerAlert(String msg) {
    setState(() {
      _showAlert = true;
      _alertMessage = msg;
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) setState(() => _showAlert = false);
    });
  }

  void _toggleAudio() => setState(() => _isAudioEnabled = !_isAudioEnabled);

  void _showToast(String msg) => Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.black87,
        textColor: Colors.white,
      );

  void _handleEmergencyAlert() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Icons.warning_amber_rounded,
                  color: Colors.red, size: 28),
            ),
            const SizedBox(height: 14),
            const Text('Emergency Alert',
                style: TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w700, color: _dark)),
            const SizedBox(height: 8),
            Text(
              'This will notify authorities with current camera feed and location.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 22),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    side: BorderSide(color: Colors.grey.shade300)),
                child: const Text('Cancel', style: TextStyle(color: _dark)),
              )),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showToast('Emergency alert sent');
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    elevation: 0),
                child: const Text('Send Alert',
                    style: TextStyle(fontWeight: FontWeight.w700)),
              )),
            ]),
          ]),
        ),
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: Column(children: [
        _buildTopBar(),
        Expanded(child: _buildFeedCard()),
        _buildCameraStrip(),
        _buildBottomPanel(),
      ]),
    );
  }

  // ── TOP BAR ───────────────────────────────────────────────────────────────
  Widget _buildTopBar() {
    return Container(
      color: _surface,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 12, 10),
          child: Row(children: [
            DBCBackButton(
              onPressed: () => Navigator.pop(context),
              iconColor: _dark,
              backgroundColor: _surface,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_camName(_selectedCameraIndex),
                    style: const TextStyle(
                        color: _dark,
                        fontSize: 15,
                        fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(children: [
                  Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                          color: Color(0xFF10B981), shape: BoxShape.circle)),
                  const SizedBox(width: 5),
                  Text('${_camZone(_selectedCameraIndex)} · DEMO',
                      style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ]),
              ],
            )),
            _topBtn(
              _isSplitScreenMode
                  ? Icons.fullscreen_exit_rounded
                  : Icons.grid_view_rounded,
              () => setState(() => _isSplitScreenMode = !_isSplitScreenMode),
            ),
            const SizedBox(width: 6),
            _topBtn(Icons.tune_rounded,
                () => Navigator.pushNamed(context, '/business-dashboard')),
            const SizedBox(width: 8),
            // Compact SOS
            GestureDetector(
              onTap: _handleEmergencyAlert,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.red.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.emergency_rounded, color: Colors.white, size: 12),
                  SizedBox(width: 3),
                  Text('SOS',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.8)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _topBtn(IconData icon, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
              color: const Color(0xFFF0EEFA),
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFE5E0F5))),
          child: Icon(icon, color: _purple, size: 17),
        ),
      );

  // ── FEED CARD ─────────────────────────────────────────────────────────────
  Widget _buildFeedCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      decoration: BoxDecoration(
        color: _feedBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4))
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: GestureDetector(
        onTap: () => setState(() => _showControls = !_showControls),
        child: Stack(fit: StackFit.expand, children: [
          // Feed
          _isSplitScreenMode ? _buildSplitScreen() : _buildDemoImageFeed(),

          // Overlays
          if (_showControls) ...[
            Positioned(top: 12, left: 12, child: _buildLiveBadge()),
            Positioned(top: 12, right: 12, child: _buildDemoBadge()),
            Positioned(bottom: 12, right: 12, child: _buildTimestamp()),
            if (_currentZoom > 1.01)
              Positioned(bottom: 12, left: 12, child: _buildZoomBadge()),
          ],

          if (_showAlert)
            Positioned(
                top: 12, left: 12, right: 12, child: _buildAlertBanner()),

          if (!_isSplitScreenMode) ..._mockDetections.map(_buildDetection),
        ]),
      ),
    );
  }

  Widget _buildDemoImageFeed() {
    final url = _camImage(_selectedCameraIndex);
    return Stack(fit: StackFit.expand, children: [
      Image.network(
        url,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) =>
            progress == null ? child : _placeholder('Loading feed...'),
        errorBuilder: (_, __, ___) => _placeholder('Feed unavailable'),
      ),
      DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.black.withOpacity(0.40),
              Colors.transparent,
              Colors.transparent,
              Colors.black.withOpacity(0.45),
            ],
            stops: const [0.0, 0.25, 0.70, 1.0],
          ),
        ),
      ),
    ]);
  }

  Widget _buildSplitScreen() {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 16 / 9),
        itemCount: _cameraList.length,
        itemBuilder: (_, i) {
          final isSelected = _selectedSplitScreenCamera == i;
          return GestureDetector(
            onTap: () => setState(() => _selectedSplitScreenCamera = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              decoration: BoxDecoration(
                  color: _feedBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color:
                          isSelected ? _purple : Colors.white.withOpacity(0.12),
                      width: isSelected ? 2 : 1)),
              clipBehavior: Clip.antiAlias,
              child: Stack(fit: StackFit.expand, children: [
                Image.network(_camImage(i),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Center(
                        child: Icon(_camIcon(i),
                            color: Colors.white.withOpacity(0.15), size: 28))),
                DecoratedBox(
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                      Colors.black.withOpacity(0.35),
                      Colors.transparent,
                      Colors.black.withOpacity(0.5)
                    ],
                            stops: const [
                      0.0,
                      0.4,
                      1.0
                    ]))),
                Positioned(
                    top: 7,
                    left: 8,
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(
                          width: 5,
                          height: 5,
                          decoration: const BoxDecoration(
                              color: Colors.red, shape: BoxShape.circle)),
                      const SizedBox(width: 3),
                      const Text('REC',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)),
                    ])),
                Positioned(
                    bottom: 7,
                    left: 8,
                    right: 8,
                    child: Text(_camName(i),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis)),
              ]),
            ),
          );
        },
      ),
    );
  }

  Widget _placeholder(String label) => Container(
        color: _feedBg,
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircularProgressIndicator(
              color: _purple.withOpacity(0.7), strokeWidth: 2),
          const SizedBox(height: 14),
          Text(label,
              style: const TextStyle(color: Colors.white38, fontSize: 12)),
        ]),
      );

  // ── Overlays ──────────────────────────────────────────────────────────────
  Widget _buildLiveBadge() {
    final anim = _pulseAnim;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.55),
          borderRadius: BorderRadius.circular(7)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        anim != null
            ? AnimatedBuilder(
                animation: anim,
                builder: (_, __) => Opacity(
                    opacity: anim.value,
                    child: Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: Colors.red, shape: BoxShape.circle))))
            : Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                    color: Colors.red, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        const Text('DEMO',
            style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2)),
      ]),
    );
  }

  Widget _buildDemoBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.15),
            borderRadius: BorderRadius.circular(7),
            border: Border.all(color: Colors.red.withOpacity(0.35))),
        child: const Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.videocam_outlined, color: Colors.red, size: 11),
          SizedBox(width: 4),
          Text('LOOPING',
              style: TextStyle(
                  color: Colors.red,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
        ]),
      );

  Widget _buildTimestamp() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.55),
            borderRadius: BorderRadius.circular(6)),
        child: Text(
            '${_now.hour.toString().padLeft(2, '0')}:'
            '${_now.minute.toString().padLeft(2, '0')}:'
            '${_now.second.toString().padLeft(2, '0')}',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: 'monospace',
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5)),
      );

  Widget _buildZoomBadge() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: _purple.withOpacity(0.85),
            borderRadius: BorderRadius.circular(6)),
        child: Text('${_currentZoom.toStringAsFixed(1)}×',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700)),
      );

  Widget _buildAlertBanner() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
            color: Colors.red.shade900.withOpacity(0.95),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(color: Colors.orange.withOpacity(0.4))),
        child: Row(children: [
          const Icon(Icons.warning_amber_rounded,
              color: Colors.orange, size: 18),
          const SizedBox(width: 8),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Motion Detected',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700)),
              Text(_alertMessage,
                  style: const TextStyle(color: Colors.white70, fontSize: 11)),
            ],
          )),
          GestureDetector(
              onTap: () => setState(() => _showAlert = false),
              child: const Icon(Icons.close, color: Colors.white54, size: 16)),
        ]),
      );

  Widget _buildDetection(Map<String, Object> d) {
    final type = d['type'] as String;
    final confidence = d['confidence'] as double;
    final color = type == 'person' ? _purple : Colors.orange;
    return Positioned(
      left: d['left'] as double,
      top: d['top'] as double,
      child: Container(
        width: d['width'] as double,
        height: d['height'] as double,
        decoration: BoxDecoration(
            border: Border.all(color: color, width: 1.5),
            borderRadius: BorderRadius.circular(4)),
        child: Align(
          alignment: Alignment.topLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(3),
                    bottomRight: Radius.circular(3))),
            child: Text('$type ${(confidence * 100).toInt()}%',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }

  // ── CAMERA STRIP ──────────────────────────────────────────────────────────
  Widget _buildCameraStrip() => Container(
        color: _surface,
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: SizedBox(
          height: 62,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cameraList.length,
            itemBuilder: (_, i) {
              final isSelected = i == _selectedCameraIndex;
              return GestureDetector(
                onTap: () => setState(() => _selectedCameraIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                      color: isSelected ? _purple : const Color(0xFFF5F3FF),
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(
                          color:
                              isSelected ? _purple : const Color(0xFFE9E4FB))),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(_camIcon(i),
                        color: isSelected
                            ? Colors.white
                            : _purple.withOpacity(0.5),
                        size: 15),
                    const SizedBox(width: 8),
                    Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_camName(i),
                              style: TextStyle(
                                  color: isSelected ? Colors.white : _dark,
                                  fontSize: 12,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                          Text(_camZone(i),
                              style: TextStyle(
                                  color: isSelected
                                      ? Colors.white70
                                      : Colors.grey.shade500,
                                  fontSize: 10)),
                        ]),
                  ]),
                ),
              );
            },
          ),
        ),
      );

  // ── BOTTOM PANEL ──────────────────────────────────────────────────────────
  Widget _buildBottomPanel() => Container(
        color: _surface,
        padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 12,
            bottom: MediaQuery.of(context).padding.bottom + 14),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
              height: 1,
              color: const Color(0xFFEEEEEE),
              margin: const EdgeInsets.only(bottom: 12)),

          // Motion sensitivity
          Row(children: [
            const Icon(Icons.sensors_rounded,
                color: Color(0xFFBBBBBB), size: 15),
            const SizedBox(width: 6),
            const Text('Motion Sensitivity',
                style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                  color: _purple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(5)),
              child: Text('${(_motionSensitivity * 100).toInt()}%',
                  style: const TextStyle(
                      color: _purple,
                      fontSize: 11, // ← fixed (was 20)
                      fontWeight: FontWeight.w700)),
            ),
          ]),
          SliderTheme(
            data: SliderThemeData(
                trackHeight: 3,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: _purple,
                inactiveTrackColor: const Color(0xFFE5E0F5),
                thumbColor: _purple,
                overlayColor: _purple.withOpacity(0.12)),
            child: Slider(
                value: _motionSensitivity,
                min: 0,
                max: 1,
                divisions: 20,
                onChanged: (v) => setState(() => _motionSensitivity = v)),
          ),

          const SizedBox(height: 6),

          Row(children: [
            _actionBtn(
                icon: Icons.camera_alt_outlined,
                label: 'Snapshot',
                onTap: _captureSnapshot),
            const SizedBox(width: 8),
            _actionBtn(
                icon:
                    _isAudioEnabled ? Icons.mic_rounded : Icons.mic_off_rounded,
                label: _isAudioEnabled ? 'Audio On' : 'Audio Off',
                onTap: _toggleAudio,
                active: _isAudioEnabled),
            const SizedBox(width: 8),
            _actionBtn(
                icon: Icons.zoom_in_rounded,
                label: '${_currentZoom.toStringAsFixed(1)}×',
                onTap: () => setState(() => _currentZoom = 1.0),
                active: _currentZoom > 1.01),
          ]),
        ]),
      );

  Widget _actionBtn({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool active = false,
  }) =>
      Expanded(
          child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
              color:
                  active ? _purple.withOpacity(0.08) : const Color(0xFFF8F8FA),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: active
                      ? _purple.withOpacity(0.35)
                      : const Color(0xFFEEEEEE))),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon,
                color: active ? _purple : const Color(0xFF9E9E9E), size: 21),
            const SizedBox(height: 5),
            Text(label,
                style: TextStyle(
                    color: active ? _purple : const Color(0xFF9E9E9E),
                    fontSize: 11, // ← fixed (was 20)
                    fontWeight: FontWeight.w500)),
          ]),
        ),
      ));
}
