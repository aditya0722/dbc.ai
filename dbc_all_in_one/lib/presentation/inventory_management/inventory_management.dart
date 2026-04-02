import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/dbc_back_button.dart';
import './widgets/filter_bottom_sheet_widget.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({super.key});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Raw Materials';
  Map<String, dynamic> _activeFilters = {
    'stockStatus': null,
    'category': null,
    'supplier': null,
    'location': null,
    'lastUpdated': null,
  };

  // ── Colors ────────────────────────────────────────────────────────────────
  static const _purple = Color(0xFF6B46C1);
  static const _green = Color(0xFF10B981);
  static const _amber = Color(0xFFF59E0B);
  static const _red = Color(0xFFEF4444);
  static const _dark = Color(0xFF1A1A1A);
  static const _bg = Color(0xFFF5F5F7);

  // ── Data ──────────────────────────────────────────────────────────────────
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      "id": 1,
      "name": "Tomatoes",
      "category": "Raw Materials",
      "image":
          "https://images.unsplash.com/photo-1546094096-0df4bcaaa337?w=400&q=80",
      "currentStock": 45,
      "minThreshold": 20,
      "unit": "kg",
      "status": "Adequate",
      "supplier": "Supplier A",
      "location": "Main Store",
      "lastUpdated": "12/11/2025"
    },
    {
      "id": 2,
      "name": "Onions",
      "category": "Raw Materials",
      "image":
          "https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=400&q=80",
      "currentStock": 15,
      "minThreshold": 25,
      "unit": "kg",
      "status": "Low Stock",
      "supplier": "Supplier A",
      "location": "Main Store",
      "lastUpdated": "12/11/2025"
    },
    {
      "id": 3,
      "name": "Chicken Breast",
      "category": "Raw Materials",
      "image":
          "https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=400&q=80",
      "currentStock": 5,
      "minThreshold": 15,
      "unit": "kg",
      "status": "Critical",
      "supplier": "Supplier B",
      "location": "Kitchen",
      "lastUpdated": "12/11/2025"
    },
    {
      "id": 4,
      "name": "Potatoes",
      "category": "Raw Materials",
      "image":
          "https://images.unsplash.com/photo-1518977676601-b53f82aba655?w=400&q=80",
      "currentStock": 5,
      "minThreshold": 15,
      "unit": "kg",
      "status": "Low Stock",
      "supplier": "Supplier A",
      "location": "Main Store",
      "lastUpdated": "12/11/2025"
    },
    {
      "id": 5,
      "name": "Olive Oil",
      "category": "Store Items",
      "image":
          "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5?w=400&q=80",
      "currentStock": 12,
      "minThreshold": 8,
      "unit": "bottles",
      "status": "Adequate",
      "supplier": "Supplier C",
      "location": "Counter",
      "lastUpdated": "12/10/2025"
    },
    {
      "id": 6,
      "name": "Pasta",
      "category": "Store Items",
      "image":
          "https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=400&q=80",
      "currentStock": 8,
      "minThreshold": 15,
      "unit": "packets",
      "status": "Low Stock",
      "supplier": "Supplier C",
      "location": "Main Store",
      "lastUpdated": "12/10/2025"
    },
    {
      "id": 7,
      "name": "Coffee Beans",
      "category": "Store Items",
      "image":
          "https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=400&q=80",
      "currentStock": 3,
      "minThreshold": 10,
      "unit": "kg",
      "status": "Critical",
      "supplier": "Supplier B",
      "location": "Counter",
      "lastUpdated": "12/09/2025"
    },
    {
      "id": 8,
      "name": "Burger Buns",
      "category": "Finished Goods",
      "image":
          "https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&q=80",
      "currentStock": 50,
      "minThreshold": 30,
      "unit": "pieces",
      "status": "Adequate",
      "supplier": "In-house",
      "location": "Kitchen",
      "lastUpdated": "12/11/2025"
    },
    {
      "id": 9,
      "name": "Pizza Dough",
      "category": "Finished Goods",
      "image":
          "https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400&q=80",
      "currentStock": 10,
      "minThreshold": 20,
      "unit": "pieces",
      "status": "Low Stock",
      "supplier": "In-house",
      "location": "Kitchen",
      "lastUpdated": "12/11/2025"
    },
  ];

  static const _categories = [
    'Raw Materials',
    'Store Items',
    'Finished Goods',
    'All Items'
  ];

  // Weekly usage mock data (Mon–Wed repeated)
  static const _weeklyData = [80.0, 140.0, 110.0, 200.0, 160.0, 230.0, 190.0];
  static const _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  List<Map<String, dynamic>> get _filteredItems =>
      _inventoryItems.where((item) {
        if (_selectedCategory != 'All Items' &&
            item['category'] != _selectedCategory) return false;
        if (_searchController.text.isNotEmpty) {
          if (!(item['name'] as String)
              .toLowerCase()
              .contains(_searchController.text.toLowerCase())) return false;
        }
        if (_activeFilters['stockStatus'] != null &&
            item['status'] != _activeFilters['stockStatus']) return false;
        if (_activeFilters['supplier'] != null &&
            item['supplier'] != _activeFilters['supplier']) return false;
        if (_activeFilters['location'] != null &&
            item['location'] != _activeFilters['location']) return false;
        return true;
      }).toList();

  int get _adequateCount =>
      _inventoryItems.where((i) => i['status'] == 'Adequate').length;
  int get _lowCount =>
      _inventoryItems.where((i) => i['status'] == 'Low Stock').length;
  int get _criticalCount =>
      _inventoryItems.where((i) => i['status'] == 'Critical').length;
  int get _total => _inventoryItems.length;

  // ── Actions ───────────────────────────────────────────────────────────────
  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) setState(() {});
  }

  void _showBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BarcodeScannerSheet(onBarcodeDetected: (barcode) {
        Navigator.pop(context);
        _searchController.text = barcode;
        setState(() {});
      }),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onApplyFilters: (f) => setState(() => _activeFilters = f),
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemDetailsSheet(item: item),
    );
  }

  void _showAdjustStockDialog(Map<String, dynamic> item) {
    final ctrl = TextEditingController();
    String op = 'add';
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Adjust · ${item['name']}',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        content: StatefulBuilder(
            builder: (_, ss) =>
                Column(mainAxisSize: MainAxisSize.min, children: [
                  Row(children: [
                    Expanded(
                        child: RadioListTile<String>(
                            title: const Text('Add'),
                            value: 'add',
                            groupValue: op,
                            onChanged: (v) => ss(() => op = v!),
                            activeColor: _purple,
                            contentPadding: EdgeInsets.zero)),
                    Expanded(
                        child: RadioListTile<String>(
                            title: const Text('Remove'),
                            value: 'remove',
                            groupValue: op,
                            onChanged: (v) => ss(() => op = v!),
                            activeColor: _purple,
                            contentPadding: EdgeInsets.zero)),
                  ]),
                  const SizedBox(height: 10),
                  TextField(
                      controller: ctrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                          labelText: 'Quantity (${item['unit']})',
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10)))),
                ])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: _purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8))),
            child: const Text('Confirm', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── Buy Modal (bottom sheet) ───────────────────────────────────────────────
  void _showBuyModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _BuyItemsModal(),
    );
  }

  // ── Add Item Modal (CENTERED dialog) ──────────────────────────────────────
  void _showAddItemDialog() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.4),
      builder: (_) => _AddItemDialog(
        onAddItem: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Item added successfully'),
            backgroundColor: _green,
          ));
        },
      ),
    );
  }

  // ── BUILD ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
          child: Column(children: [
        _buildHeader(),
        _buildCategoryTabs(),
        _buildActionRow(),
        Expanded(
            child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: _purple,
          child: ListView(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 80),
              children: [
                // ── Charts row ──
                _buildChartsSection(),
                const SizedBox(height: 12),
                // ── Grid ──
                if (_filteredItems.isEmpty)
                  SizedBox(
                      height: 300,
                      child: Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                            Icon(Icons.inventory_2_outlined,
                                size: 56, color: Colors.grey.shade300),
                            const SizedBox(height: 12),
                            Text('No items found',
                                style: TextStyle(color: Colors.grey.shade500)),
                          ]))),
                if (_filteredItems.isNotEmpty)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 0.76),
                    itemCount: _filteredItems.length,
                    itemBuilder: (_, i) => _InventoryCard(
                      item: _filteredItems[i],
                      onTap: () => _showItemDetails(_filteredItems[i]),
                      onAdjustStock: () =>
                          _showAdjustStockDialog(_filteredItems[i]),
                      onReorder: () => Navigator.pushNamed(
                          context, '/marketplace-product-catalog'),
                    ),
                  ),
              ]),
        )),
      ])),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader() => Container(
        color: Colors.white,
        padding: const EdgeInsets.fromLTRB(16, 12, 12, 10),
        child: Row(children: [
          const Text('Stock Inventory',
              style: TextStyle(
                  color: _dark, fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(width: 12),
          Expanded(
              child: Container(
            height: 38,
            decoration: BoxDecoration(
                color: _bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFEEEEEE))),
            child: Row(children: [
              const SizedBox(width: 10),
              const Icon(Icons.search, color: Color(0xFF9E9E9E), size: 18),
              const SizedBox(width: 6),
              Expanded(
                  child: TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                    hintText: 'Search items, scan barcode...',
                    hintStyle:
                        TextStyle(color: Color(0xFFBBBBBB), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true),
              )),
              GestureDetector(
                  onTap: _showBarcodeScanner,
                  child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.qr_code_scanner,
                          color: Color(0xFF9E9E9E), size: 18))),
              GestureDetector(
                  onTap: _showBarcodeScanner,
                  child: const Padding(
                      padding: EdgeInsets.only(right: 8),
                      child: Icon(Icons.mic_none_rounded,
                          color: Color(0xFF9E9E9E), size: 18))),
            ]),
          )),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showFilterSheet,
            child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                    color: _bg,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFEEEEEE))),
                child: const Icon(Icons.tune_rounded,
                    color: Color(0xFF9E9E9E), size: 18)),
          ),
        ]),
      );

  // ── Tabs ──────────────────────────────────────────────────────────────────
  Widget _buildCategoryTabs() => Container(
        color: Colors.white,
        child: Row(
            children: _categories.map((cat) {
          final sel = cat == _selectedCategory;
          return Expanded(
              child: GestureDetector(
            onTap: () => setState(() => _selectedCategory = cat),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 11),
              decoration: BoxDecoration(
                  color: sel ? _purple : Colors.transparent,
                  border: Border(
                      bottom: BorderSide(
                          color: sel ? _purple : Colors.transparent,
                          width: 2))),
              child: Text(cat,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: sel ? Colors.white : const Color(0xFF9E9E9E),
                      fontSize: 12,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.w500)),
            ),
          ));
        }).toList()),
      );

  // ── Action Row ────────────────────────────────────────────────────────────
  Widget _buildActionRow() => Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
        child: Row(children: [
          Text('${_filteredItems.length} items',
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 12)),
          const Spacer(),
          GestureDetector(
            onTap: _showAddItemDialog,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0EEFA),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E0F5))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.add_rounded, color: _purple, size: 15),
                SizedBox(width: 4),
                Text('Add Item',
                    style: TextStyle(
                        color: _purple,
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ]),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _showBuyModal,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                  color: _purple,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: [
                    BoxShadow(
                        color: _purple.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ]),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.shopping_cart_rounded,
                    color: Colors.white, size: 15),
                SizedBox(width: 5),
                Text('Buy',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700)),
              ]),
            ),
          ),
        ]),
      );

  // ── Charts Section ────────────────────────────────────────────────────────
  Widget _buildChartsSection() {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      // Stock Health card
      Expanded(
          child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Stock Health',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 14),
          Center(
              child: SizedBox(
            width: 130,
            height: 130,
            child: CustomPaint(
              painter: _DonutChartPainter(
                  adequate: _adequateCount,
                  low: _lowCount,
                  critical: _criticalCount,
                  total: _total),
              child: Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text('${((_adequateCount / _total) * 100).toInt()}%',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _dark)),
                const Text('of items',
                    style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
              ])),
            ),
          )),
          const SizedBox(height: 14),
          _legendRow(_green, 'Good', _adequateCount),
          const SizedBox(height: 6),
          _legendRow(_amber, 'Low', _lowCount),
          const SizedBox(height: 6),
          _legendRow(_red, 'Critical', _criticalCount),
        ]),
      )),
      const SizedBox(width: 10),
      // Weekly Usage card
      Expanded(
          child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Weekly Usage',
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: _dark)),
          const SizedBox(height: 2),
          const Text('Ingredient consumption',
              style: TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
          const SizedBox(height: 14),
          SizedBox(
            height: 160,
            child:
                Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              // Y-axis labels
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: ['250', '200', '150', '100', '50', '0']
                    .map((l) => Text(l,
                        style: const TextStyle(
                            fontSize: 8, color: Color(0xFFCCCCCC))))
                    .toList(),
              ),
              const SizedBox(width: 6),
              // Chart
              Expanded(
                  child: CustomPaint(
                painter: _LineChartPainter(data: _weeklyData, days: _weekDays),
              )),
            ]),
          ),
        ]),
      )),
    ]);
  }

  Widget _legendRow(Color color, String label, int count) {
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 8),
      Text(label,
          style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
      const Spacer(),
      Text('$count',
          style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w700, color: _dark)),
    ]);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// ── Donut Chart Painter ───────────────────────────────────────────────────────
class _DonutChartPainter extends CustomPainter {
  final int adequate, low, critical, total;
  const _DonutChartPainter(
      {required this.adequate,
      required this.low,
      required this.critical,
      required this.total});

  @override
  void paint(Canvas canvas, Size size) {
    if (total == 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = min(cx, cy) - 8;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    const strokeW = 18.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeW
      ..strokeCap = StrokeCap.round;

    const gap = 0.04; // gap between segments in radians
    double start = -pi / 2;

    final segments = [
      {'value': adequate, 'color': const Color(0xFF10B981)},
      {'value': low, 'color': const Color(0xFFF59E0B)},
      {'value': critical, 'color': const Color(0xFFEF4444)},
    ];

    for (final seg in segments) {
      final v = (seg['value'] as int).toDouble();
      if (v == 0) continue;
      final sweep = (v / total) * (2 * pi) - gap;
      paint.color = seg['color'] as Color;
      canvas.drawArc(rect, start, sweep, false, paint);
      start += sweep + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

// ── Line Chart Painter ────────────────────────────────────────────────────────
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final List<String> days;
  const _LineChartPainter({required this.data, required this.days});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;
    const purple = Color(0xFF6B46C1);

    final maxVal = data.reduce(max);
    final minVal = data.reduce(min);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    const topPad = 6.0;
    const bottomPad = 22.0;
    const sidePad = 4.0;
    final chartH = size.height - topPad - bottomPad;
    final chartW = size.width - sidePad * 2;
    final stepX = chartW / (data.length - 1);

    // ── Horizontal grid lines ──
    final gridPaint = Paint()
      ..color = const Color(0xFFF0F0F0)
      ..strokeWidth = 1;
    const gridLines = 5;
    for (int i = 0; i <= gridLines; i++) {
      final y = topPad + (chartH / gridLines) * i;
      canvas.drawLine(
          Offset(sidePad, y), Offset(size.width - sidePad, y), gridPaint);
    }

    // ── Compute points ──
    List<Offset> points = [];
    for (int i = 0; i < data.length; i++) {
      final x = sidePad + i * stepX;
      final y = topPad + chartH - ((data[i] - minVal) / range) * chartH;
      points.add(Offset(x, y));
    }

    // ── Gradient fill ──
    final path = Path()..moveTo(points.first.dx, size.height - bottomPad);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    path
      ..lineTo(points.last.dx, size.height - bottomPad)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [purple.withOpacity(0.20), purple.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // ── Smooth line ──
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      final prev = points[i - 1];
      final curr = points[i];
      final cpx = (prev.dx + curr.dx) / 2;
      linePath.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }
    canvas.drawPath(
        linePath,
        Paint()
          ..color = purple
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);

    // ── Dots ──
    for (final pt in points) {
      canvas.drawCircle(
          pt,
          5.0,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          pt,
          5.0,
          Paint()
            ..color = purple
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8);
      canvas.drawCircle(
          pt,
          2.5,
          Paint()
            ..color = purple
            ..style = PaintingStyle.fill);
    }

    // ── Day labels ──
    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < days.length; i++) {
      tp.text = TextSpan(
        text: days[i],
        style: const TextStyle(
            fontSize: 9, color: Color(0xFF9E9E9E), fontWeight: FontWeight.w500),
      );
      tp.layout();
      final x = sidePad + i * stepX - tp.width / 2;
      tp.paint(canvas, Offset(x, size.height - bottomPad + 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ── Inventory Card ────────────────────────────────────────────────────────────
class _InventoryCard extends StatelessWidget {
  final Map<String, dynamic> item;
  final VoidCallback onTap, onAdjustStock, onReorder;
  const _InventoryCard(
      {required this.item,
      required this.onTap,
      required this.onAdjustStock,
      required this.onReorder});

  Color get _statusColor {
    switch (item['status']) {
      case 'Adequate':
        return const Color(0xFF10B981);
      case 'Low Stock':
        return const Color(0xFFF59E0B);
      case 'Critical':
        return const Color(0xFFEF4444);
      default:
        return Colors.grey;
    }
  }

  double get _stockRatio {
    final cur = (item['currentStock'] as num).toDouble();
    final min = (item['minThreshold'] as num).toDouble();
    if (min == 0) return 1.0;
    return (cur / (min * 2)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(14)),
            child: AspectRatio(
              aspectRatio: 16 / 10,
              child: Image.network(item['image'] as String,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFFF5F5F7),
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Color(0xFFCCCCCC), size: 32)),
                  loadingBuilder: (_, child, progress) => progress == null
                      ? child
                      : Container(
                          color: const Color(0xFFF5F5F7),
                          child: const Center(
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Color(0xFF6B46C1))))),
            ),
          ),
          // Content
          Expanded(
              child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(item['name'] as String,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1A1A1A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Row(children: [
                    const Text('Stock: ',
                        style:
                            TextStyle(fontSize: 10, color: Color(0xFF9E9E9E))),
                    Text('${item['currentStock']} ${item['unit']}',
                        style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: color)),
                    Text('  /  Min: ${item['minThreshold']}',
                        style: const TextStyle(
                            fontSize: 10, color: Color(0xFF9E9E9E))),
                  ]),
                  const SizedBox(height: 5),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                          value: _stockRatio,
                          minHeight: 5,
                          backgroundColor: color.withOpacity(0.12),
                          valueColor: AlwaysStoppedAnimation<Color>(color))),
                  const SizedBox(height: 5),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(item['status'] as String,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color))),
                  const SizedBox(height: 7),
                  SizedBox(
                      width: double.infinity,
                      child: GestureDetector(
                        onTap: onReorder,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                              color: const Color(0xFFF5F3FF),
                              borderRadius: BorderRadius.circular(8),
                              border:
                                  Border.all(color: const Color(0xFFE5E0F5))),
                          child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.shopping_cart_outlined,
                                    color: Color(0xFF6B46C1), size: 13),
                                SizedBox(width: 5),
                                Text('Quick Reorder',
                                    style: TextStyle(
                                        color: Color(0xFF6B46C1),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600)),
                              ]),
                        ),
                      )),
                ]),
          )),
        ]),
      ),
    );
  }
}

// ── Add Item Dialog (CENTERED) ────────────────────────────────────────────────
class _AddItemDialog extends StatefulWidget {
  final VoidCallback onAddItem;
  const _AddItemDialog({required this.onAddItem});

  @override
  State<_AddItemDialog> createState() => _AddItemDialogState();
}

class _AddItemDialogState extends State<_AddItemDialog> {
  static const _purple = Color(0xFF6B46C1);
  final _nameCtrl = TextEditingController();
  final _stockCtrl = TextEditingController();
  final _minCtrl = TextEditingController();
  String _category = 'Raw Materials';
  String _unit = 'kg';

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          // Header
          Row(children: [
            const Text('Add New Item',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A))),
            const Spacer(),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F7), shape: BoxShape.circle),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: Color(0xFF9E9E9E))),
            ),
          ]),
          const SizedBox(height: 20),
          // Fields
          _field(_nameCtrl, 'Item Name'),
          const SizedBox(height: 12),
          _dropdown<String>(
              'Category',
              _category,
              ['Raw Materials', 'Store Items', 'Finished Goods'],
              (v) => setState(() => _category = v!)),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(
                child: _field(_stockCtrl, 'Current Stock', isNumber: true)),
            const SizedBox(width: 10),
            SizedBox(
                width: 100,
                child: _dropdown<String>(
                    'Unit',
                    _unit,
                    ['kg', 'pieces', 'bottles', 'packets'],
                    (v) => setState(() => _unit = v!))),
          ]),
          const SizedBox(height: 12),
          _field(_minCtrl, 'Minimum Threshold', isNumber: true),
          const SizedBox(height: 22),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: widget.onAddItem,
              style: ElevatedButton.styleFrom(
                  backgroundColor: _purple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 0),
              child: const Text('Add Item',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String label,
          {bool isNumber = false}) =>
      TextField(
        controller: ctrl,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _purple, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
      );

  Widget _dropdown<T>(
          String label, T value, List<T> items, ValueChanged<T?> onChanged) =>
      DropdownButtonFormField<T>(
        value: value,
        decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: _purple, width: 1.5)),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12)),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i.toString())))
            .toList(),
        onChanged: onChanged,
      );

  @override
  void dispose() {
    _nameCtrl.dispose();
    _stockCtrl.dispose();
    _minCtrl.dispose();
    super.dispose();
  }
}

// ── Buy Items Modal ────────────────────────────────────────────────────────────
class _BuyItemsModal extends StatefulWidget {
  const _BuyItemsModal();
  @override
  State<_BuyItemsModal> createState() => _BuyItemsModalState();
}

class _BuyItemsModalState extends State<_BuyItemsModal> {
  static const _purple = Color(0xFF6B46C1);
  static const _red = Color(0xFFEF4444);
  static const _amber = Color(0xFFF59E0B);

  final List<Map<String, dynamic>> _items = [
    {
      'name': 'Chicken Breast',
      'status': 'Critical',
      'stock': '5 kg',
      'min': '15 kg',
      'image':
          'https://images.unsplash.com/photo-1604503468506-a8da13d82791?w=200&q=80'
    },
    {
      'name': 'Coffee Beans',
      'status': 'Critical',
      'stock': '3 kg',
      'min': '10 kg',
      'image':
          'https://images.unsplash.com/photo-1559056199-641a0ac8b55e?w=200&q=80'
    },
    {
      'name': 'Onions',
      'status': 'Low Stock',
      'stock': '15 kg',
      'min': '25 kg',
      'image':
          'https://images.unsplash.com/photo-1587049352846-4a222e784d38?w=200&q=80'
    },
    {
      'name': 'Pasta',
      'status': 'Low Stock',
      'stock': '8 pk',
      'min': '15 pk',
      'image':
          'https://images.unsplash.com/photo-1551462147-ff29053bfc14?w=200&q=80'
    },
    {
      'name': 'Pizza Dough',
      'status': 'Low Stock',
      'stock': '10 pc',
      'min': '20 pc',
      'image':
          'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=200&q=80'
    },
  ];

  final Set<int> _selected = {0, 1};

  Color _statusColor(String s) => s == 'Critical'
      ? _red
      : s == 'Low Stock'
          ? _amber
          : const Color(0xFF10B981);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
          child: Row(children: [
            const Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Buy Items',
                      style:
                          TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                  SizedBox(height: 3),
                  Text('Select items to reorder from marketplace',
                      style: TextStyle(fontSize: 12, color: Color(0xFF9E9E9E))),
                ])),
            IconButton(
                icon: const Icon(Icons.close_rounded, color: Color(0xFF9E9E9E)),
                onPressed: () => Navigator.pop(context)),
          ]),
        ),
        const Divider(height: 20, indent: 16, endIndent: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            Container(
                width: 4,
                height: 16,
                decoration: BoxDecoration(
                    color: _purple, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('Needs Restocking',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const Spacer(),
            GestureDetector(
              onTap: () => setState(() {
                _selected.length == _items.length
                    ? _selected.clear()
                    : _selected.addAll(List.generate(_items.length, (i) => i));
              }),
              child: Text(
                  _selected.length == _items.length
                      ? 'Deselect All'
                      : 'Select All',
                  style: const TextStyle(
                      fontSize: 12,
                      color: _purple,
                      fontWeight: FontWeight.w600)),
            ),
          ]),
        ),
        const SizedBox(height: 10),
        Expanded(
            child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _items.length,
          itemBuilder: (_, i) {
            final item = _items[i];
            final sel = _selected.contains(i);
            final color = _statusColor(item['status'] as String);
            return GestureDetector(
              onTap: () =>
                  setState(() => sel ? _selected.remove(i) : _selected.add(i)),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: sel ? _purple.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: sel
                            ? _purple.withOpacity(0.4)
                            : Colors.grey.shade200,
                        width: sel ? 1.5 : 1)),
                child: Row(children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                        color: sel ? _purple : Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                            color: sel ? _purple : Colors.grey.shade300,
                            width: 1.5)),
                    child: sel
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white, size: 13)
                        : null,
                  ),
                  const SizedBox(width: 12),
                  ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(item['image'] as String,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                              width: 44,
                              height: 44,
                              color: Colors.grey.shade100))),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(item['name'] as String,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text('Stock: ${item['stock']}  ·  Min: ${item['min']}',
                            style: const TextStyle(
                                fontSize: 11, color: Color(0xFF9E9E9E))),
                      ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(5)),
                      child: Text(item['status'] as String,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: color))),
                ]),
              ),
            );
          },
        )),
        Padding(
          padding: EdgeInsets.fromLTRB(
              16, 8, 16, MediaQuery.of(context).padding.bottom + 16),
          child: Column(children: [
            if (_selected.isNotEmpty)
              Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Text(
                      '${_selected.length} item${_selected.length > 1 ? 's' : ''} selected',
                      style: const TextStyle(
                          fontSize: 12, color: Color(0xFF9E9E9E)))),
            SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _selected.isEmpty
                      ? null
                      : () {
                          Navigator.pop(context);
                          Navigator.pushNamed(
                              context, '/marketplace-product-catalog');
                        },
                  icon: const Icon(Icons.shopping_cart_rounded, size: 18),
                  label: Text(
                      _selected.isEmpty
                          ? 'Select items to continue'
                          : 'Go to Marketplace (${_selected.length})',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _selected.isEmpty ? Colors.grey.shade300 : _purple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      elevation: 0),
                )),
          ]),
        ),
      ]),
    );
  }
}

// ── Barcode Scanner ────────────────────────────────────────────────────────────
class _BarcodeScannerSheet extends StatefulWidget {
  final Function(String) onBarcodeDetected;
  const _BarcodeScannerSheet({required this.onBarcodeDetected});
  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  final MobileScannerController _ctrl = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      child: Column(children: [
        Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(children: [
              const Text('Scan Barcode',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context)),
            ])),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: MobileScanner(
                        controller: _ctrl,
                        onDetect: (capture) {
                          final barcodes = capture.barcodes;
                          if (barcodes.isNotEmpty &&
                              barcodes.first.rawValue != null) {
                            widget.onBarcodeDetected(barcodes.first.rawValue!);
                          }
                        })))),
        const SizedBox(height: 12),
      ]),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }
}

// ── Item Details Sheet ─────────────────────────────────────────────────────────
class _ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;
  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      child: Column(children: [
        Container(
            margin: const EdgeInsets.only(top: 10),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2))),
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 0),
            child: Row(children: [
              const Text('Item Details',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const Spacer(),
              IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.pop(context)),
            ])),
        Expanded(
            child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(item['image'] as String,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey.shade100)))),
            const SizedBox(height: 16),
            Text(item['name'] as String,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ...[
              ['Category', item['category']],
              ['Current Stock', '${item['currentStock']} ${item['unit']}'],
              ['Min Threshold', '${item['minThreshold']} ${item['unit']}'],
              ['Status', item['status']],
              ['Supplier', item['supplier']],
              ['Location', item['location']],
              ['Last Updated', item['lastUpdated']],
            ].map((r) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(children: [
                  Text(r[0] as String,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9E9E9E))),
                  const Spacer(),
                  Text(r[1] as String,
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ]))),
          ]),
        )),
      ]),
    );
  }
}
