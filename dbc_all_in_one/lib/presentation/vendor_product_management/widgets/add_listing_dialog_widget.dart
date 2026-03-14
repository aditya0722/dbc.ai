import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../services/marketplace_service.dart';


class AddListingDialogWidget extends StatefulWidget {
  final String vendorId;
  final VoidCallback onListingCreated;

  const AddListingDialogWidget({
    super.key,
    required this.vendorId,
    required this.onListingCreated,
  });

  @override
  State<AddListingDialogWidget> createState() => _AddListingDialogWidgetState();
}

class _AddListingDialogWidgetState extends State<AddListingDialogWidget> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _minOrderController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();
  final TextEditingController _deliveryController = TextEditingController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  String? _selectedProductId;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _marketplaceService.getVendorProducts(widget.vendorId);
      setState(() {
        _products = products;
        _isLoading = false;
        if (_products.isNotEmpty) {
          _selectedProductId = _products.first['id'] as String;
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load products: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _createListing() async {
    if (_selectedProductId == null) return;

    try {
      await _marketplaceService.createVendorListing(
        vendorId: widget.vendorId,
        productId: _selectedProductId!,
        pricePerUnit: double.tryParse(_priceController.text) ?? 0,
        minOrderQuantity: int.tryParse(_minOrderController.text) ?? 1,
        currentStock: int.tryParse(_stockController.text) ?? 0,
        deliveryTimeDays: int.tryParse(_deliveryController.text),
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onListingCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listing created successfully'),
            backgroundColor: Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create listing: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: const Text('Add Product Listing'),
      content:
          _isLoading
              ? SizedBox(
                height: 20.h,
                child: const Center(child: CircularProgressIndicator()),
              )
              : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<String>(
                      initialValue: _selectedProductId,
                      decoration: const InputDecoration(
                        labelText: 'Select Product',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          _products.map((product) {
                            return DropdownMenuItem(
                              value: product['id'] as String,
                              child: Text(product['product_name'] as String),
                            );
                          }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedProductId = value);
                      },
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price per Unit',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: _minOrderController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Minimum Order Quantity',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Current Stock',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    TextField(
                      controller: _deliveryController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Delivery Time (days)',
                        border: OutlineInputBorder(),
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
          onPressed: _isLoading ? null : _createListing,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _priceController.dispose();
    _minOrderController.dispose();
    _stockController.dispose();
    _deliveryController.dispose();
    super.dispose();
  }
}