import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/filter_bottom_sheet_widget.dart';
import './widgets/inventory_header_widget.dart';
import './widgets/inventory_item_card_widget.dart';

class InventoryManagement extends StatefulWidget {
  const InventoryManagement({super.key});

  @override
  State<InventoryManagement> createState() => _InventoryManagementState();
}

class _InventoryManagementState extends State<InventoryManagement> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Raw Materials';
  bool _isRefreshing = false;
  Map<String, dynamic> _activeFilters = {
    'stockStatus': null,
    'category': null,
    'supplier': null,
    'location': null,
    'lastUpdated': null,
  };

  // Mock inventory data
  final List<Map<String, dynamic>> _inventoryItems = [
    {
      "id": 1,
      "name": "Tomatoes",
      "category": "Raw Materials",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_187bc0b48-1764686062386.png",
      "semanticLabel": "Fresh red tomatoes on vine against white background",
      "currentStock": 45,
      "minThreshold": 20,
      "unit": "kg",
      "status": "Adequate",
      "supplier": "Supplier A",
      "location": "Main Store",
      "lastUpdated": "12/11/2025",
    },
    {
      "id": 2,
      "name": "Onions",
      "category": "Raw Materials",
      "image": "https://images.unsplash.com/photo-1678954157574-cbbed4d055ab",
      "semanticLabel": "Brown onions in woven basket on wooden surface",
      "currentStock": 15,
      "minThreshold": 25,
      "unit": "kg",
      "status": "Low Stock",
      "supplier": "Supplier A",
      "location": "Main Store",
      "lastUpdated": "12/11/2025",
    },
    {
      "id": 3,
      "name": "Chicken Breast",
      "category": "Raw Materials",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1c39b6a83-1764693955968.png",
      "semanticLabel": "Raw chicken breast pieces on white cutting board",
      "currentStock": 5,
      "minThreshold": 15,
      "unit": "kg",
      "status": "Critical",
      "supplier": "Supplier B",
      "location": "Kitchen",
      "lastUpdated": "12/11/2025",
    },
    {
      "id": 4,
      "name": "Olive Oil",
      "category": "Store Items",
      "image": "https://images.unsplash.com/photo-1474979266404-7eaacbcd87c5",
      "semanticLabel": "Glass bottle of golden olive oil with green olives",
      "currentStock": 12,
      "minThreshold": 8,
      "unit": "bottles",
      "status": "Adequate",
      "supplier": "Supplier C",
      "location": "Counter",
      "lastUpdated": "12/10/2025",
    },
    {
      "id": 5,
      "name": "Pasta",
      "category": "Store Items",
      "image":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1391bdff0-1765097404991.png",
      "semanticLabel": "Dried pasta noodles in glass jar on wooden table",
      "currentStock": 8,
      "minThreshold": 15,
      "unit": "packets",
      "status": "Low Stock",
      "supplier": "Supplier C",
      "location": "Main Store",
      "lastUpdated": "12/10/2025",
    },
    {
      "id": 6,
      "name": "Burger Buns",
      "category": "Finished Goods",
      "image": "https://images.unsplash.com/photo-1701693429598-9ed21d97a2ca",
      "semanticLabel": "Stack of sesame seed burger buns on wooden board",
      "currentStock": 50,
      "minThreshold": 30,
      "unit": "pieces",
      "status": "Adequate",
      "supplier": "In-house",
      "location": "Kitchen",
      "lastUpdated": "12/11/2025",
    },
    {
      "id": 7,
      "name": "Pizza Dough",
      "category": "Finished Goods",
      "image": "https://images.unsplash.com/photo-1700459591381-c70245d94ba9",
      "semanticLabel": "Fresh pizza dough ball on floured surface",
      "currentStock": 10,
      "minThreshold": 20,
      "unit": "pieces",
      "status": "Low Stock",
      "supplier": "In-house",
      "location": "Kitchen",
      "lastUpdated": "12/11/2025",
    },
    {
      "id": 8,
      "name": "Coffee Beans",
      "category": "Store Items",
      "image": "https://images.unsplash.com/photo-1690983325192-a4c13c2e331d",
      "semanticLabel": "Roasted coffee beans in burlap sack with wooden scoop",
      "currentStock": 3,
      "minThreshold": 10,
      "unit": "kg",
      "status": "Critical",
      "supplier": "Supplier B",
      "location": "Counter",
      "lastUpdated": "12/09/2025",
    },
  ];

  List<Map<String, dynamic>> get _filteredItems {
    return _inventoryItems.where((item) {
      // Category filter
      if (item['category'] != _selectedCategory) return false;

      // Search filter
      if (_searchController.text.isNotEmpty) {
        final searchLower = _searchController.text.toLowerCase();
        final nameLower = (item['name'] as String).toLowerCase();
        if (!nameLower.contains(searchLower)) return false;
      }

      // Active filters
      if (_activeFilters['stockStatus'] != null &&
          item['status'] != _activeFilters['stockStatus']) return false;

      if (_activeFilters['supplier'] != null &&
          item['supplier'] != _activeFilters['supplier']) return false;

      if (_activeFilters['location'] != null &&
          item['location'] != _activeFilters['location']) return false;

      return true;
    }).toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Inventory synced successfully'),
          backgroundColor: const Color(0xFF10B981),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      );
    }
  }

  void _showBarcodeScanner() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _BarcodeScannerSheet(
        onBarcodeDetected: (barcode) {
          Navigator.pop(context);
          _searchController.text = barcode;
          setState(() {});
        },
      ),
    );
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheetWidget(
        currentFilters: _activeFilters,
        onApplyFilters: (filters) {
          setState(() => _activeFilters = filters);
        },
      ),
    );
  }

  void _showItemDetails(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ItemDetailsSheet(item: item),
    );
  }

  void _showAdjustStockDialog(Map<String, dynamic> item) {
    final theme = Theme.of(context);
    final TextEditingController quantityController = TextEditingController();
    String operation = 'add';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Adjust Stock - ${item['name']}'),
        content: StatefulBuilder(
          builder: (context, setDialogState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Add'),
                      value: 'add',
                      groupValue: operation,
                      onChanged: (value) =>
                          setDialogState(() => operation = value!),
                    ),
                  ),
                  Expanded(
                    child: RadioListTile<String>(
                      title: const Text('Remove'),
                      value: 'remove',
                      groupValue: operation,
                      onChanged: (value) =>
                          setDialogState(() => operation = value!),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Quantity (${item['unit']})',
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Stock ${operation == 'add' ? 'added' : 'removed'} successfully',
                  ),
                  backgroundColor: theme.colorScheme.primary,
                ),
              );
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void _handleReorder(Map<String, dynamic> item) {
    Navigator.pushNamed(context, '/marketplace-product-catalog');
  }

  void _showAddItemSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemSheet(
        onAddItem: () {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Item added successfully'),
              backgroundColor: Color(0xFF10B981),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Sticky header
            InventoryHeaderWidget(
              searchController: _searchController,
              selectedCategory: _selectedCategory,
              onCategoryChanged: (category) {
                setState(() => _selectedCategory = category);
              },
              onSearchTap: _showBarcodeScanner,
              onFilterTap: _showFilterSheet,
            ),
            // Quick access to marketplace
            Container(
              margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/marketplace-product-catalog');
                },
                icon: CustomIconWidget(
                  iconName: 'shopping_cart',
                  color: theme.colorScheme.onPrimary,
                  size: 20,
                ),
                label: Text(
                  'Buy',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 1.5.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
            // Item list
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                child: _filteredItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomIconWidget(
                              iconName: 'inventory_2',
                              color: theme.colorScheme.onSurfaceVariant,
                              size: 64,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'No items found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (context, index) {
                          final item = _filteredItems[index];
                          return InventoryItemCardWidget(
                            item: item,
                            onTap: () => _showItemDetails(item),
                            onAdjustStock: () => _showAdjustStockDialog(item),
                            onReorderNow: () => _handleReorder(item),
                            onViewHistory: () => _showItemDetails(item),
                            onSetAlert: () => _showAdjustStockDialog(item),
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddItemSheet,
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'Add Item',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Barcode scanner bottom sheet
class _BarcodeScannerSheet extends StatefulWidget {
  final Function(String) onBarcodeDetected;

  const _BarcodeScannerSheet({required this.onBarcodeDetected});

  @override
  State<_BarcodeScannerSheet> createState() => _BarcodeScannerSheetState();
}

class _BarcodeScannerSheetState extends State<_BarcodeScannerSheet> {
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Scan Barcode',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: MobileScanner(
                controller: _scannerController,
                onDetect: (capture) {
                  final List<Barcode> barcodes = capture.barcodes;
                  if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
                    widget.onBarcodeDetected(barcodes.first.rawValue!);
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
}

// Item details bottom sheet
class _ItemDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> item;

  const _ItemDetailsSheet({required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Item Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12.0),
                      child: CustomImageWidget(
                        imageUrl: item['image'] as String,
                        width: 40.w,
                        height: 40.w,
                        fit: BoxFit.cover,
                        semanticLabel: item['semanticLabel'] as String,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    item['name'] as String,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildDetailRow(
                    context,
                    'Category',
                    item['category'] as String,
                  ),
                  _buildDetailRow(
                    context,
                    'Current Stock',
                    '${item['currentStock']} ${item['unit']}',
                  ),
                  _buildDetailRow(
                    context,
                    'Minimum Threshold',
                    '${item['minThreshold']} ${item['unit']}',
                  ),
                  _buildDetailRow(context, 'Status', item['status'] as String),
                  _buildDetailRow(
                    context,
                    'Supplier',
                    item['supplier'] as String,
                  ),
                  _buildDetailRow(
                    context,
                    'Location',
                    item['location'] as String,
                  ),
                  _buildDetailRow(
                    context,
                    'Last Updated',
                    item['lastUpdated'] as String,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Stock Movement History',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildHistoryItem(
                    context,
                    'Stock Added',
                    '+20 kg',
                    '12/11/2025 10:30 AM',
                    'John Doe',
                  ),
                  _buildHistoryItem(
                    context,
                    'Stock Removed',
                    '-5 kg',
                    '12/10/2025 03:15 PM',
                    'Jane Smith',
                  ),
                  _buildHistoryItem(
                    context,
                    'Stock Added',
                    '+30 kg',
                    '12/09/2025 09:00 AM',
                    'John Doe',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(
    BuildContext context,
    String action,
    String quantity,
    String timestamp,
    String user,
  ) {
    final theme = Theme.of(context);
    return Container(
      margin: EdgeInsets.only(bottom: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: action.contains('Added')
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : const Color(0xFFEF4444).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: CustomIconWidget(
              iconName: action.contains('Added') ? 'add' : 'remove',
              color: action.contains('Added')
                  ? const Color(0xFF10B981)
                  : const Color(0xFFEF4444),
              size: 20,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  quantity,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  '$timestamp • $user',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Add item bottom sheet
class _AddItemSheet extends StatefulWidget {
  final VoidCallback onAddItem;

  const _AddItemSheet({required this.onAddItem});

  @override
  State<_AddItemSheet> createState() => _AddItemSheetState();
}

class _AddItemSheetState extends State<_AddItemSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _minController = TextEditingController();
  String _selectedCategory = 'Raw Materials';
  String _selectedUnit = 'kg';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 80.h,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 1.h),
            width: 10.w,
            height: 0.5.h,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2.0),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Add New Item',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: CustomIconWidget(
                    iconName: 'close',
                    color: theme.colorScheme.onSurface,
                    size: 24,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: ['Raw Materials', 'Store Items', 'Finished Goods']
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ),
                        )
                        .toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                  ),
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _stockController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Current Stock',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      SizedBox(
                        width: 20.w,
                        child: DropdownButtonFormField<String>(
                          initialValue: _selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: ['kg', 'pieces', 'bottles', 'packets']
                              .map(
                                (unit) => DropdownMenuItem(
                                  value: unit,
                                  child: Text(unit),
                                ),
                              )
                              .toList(),
                          onChanged: (value) =>
                              setState(() => _selectedUnit = value!),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  TextField(
                    controller: _minController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Minimum Threshold',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: widget.onAddItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: theme.colorScheme.onPrimary,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  'Add Item',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _minController.dispose();
    super.dispose();
  }
}
