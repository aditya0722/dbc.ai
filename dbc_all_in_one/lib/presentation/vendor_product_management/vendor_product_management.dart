import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/dbc_back_button.dart';
import './widgets/add_listing_dialog_widget.dart';
import './widgets/vendor_listing_card_widget.dart';

class VendorProductManagement extends StatefulWidget {
  const VendorProductManagement({super.key});

  @override
  State<VendorProductManagement> createState() =>
      _VendorProductManagementState();
}

class _VendorProductManagementState extends State<VendorProductManagement> {
  final TextEditingController _searchController = TextEditingController();
  final MarketplaceService _marketplaceService = MarketplaceService();

  String _selectedStatus = 'active';
  bool _isLoading = true;
  List<Map<String, dynamic>> _listings = [];
  Map<String, dynamic>? _statistics;
  String? _selectedVendorId;

  @override
  void initState() {
    super.initState();
    _loadVendorData();
  }

  Future<void> _loadVendorData() async {
    setState(() => _isLoading = true);
    try {
      // Get user's vendors - replace with direct service call
      final vendors = await _marketplaceService.getVendorsByUserId();
      if (vendors.isEmpty) {
        setState(() => _isLoading = false);
        if (mounted) {
          _showCreateVendorDialog();
        }
        return;
      }

      // Use first vendor for simplicity
      final vendorId = vendors.first['id'] as String;
      setState(() => _selectedVendorId = vendorId);

      // Load listings and statistics
      await _loadListings(vendorId);
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load vendor data: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _loadListings(String vendorId) async {
    try {
      final dashboardData = await _marketplaceService.fetchVendorDashboard(
        vendorId,
      );

      final allListings = List<Map<String, dynamic>>.from(
        dashboardData['listings'] ?? [],
      );

      setState(() {
        _listings = allListings
            .where(
              (l) =>
                  _selectedStatus == 'all' ||
                  l['listing_status'] == _selectedStatus,
            )
            .toList();
        _statistics = dashboardData['statistics'] as Map<String, dynamic>?;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load listings: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (_selectedVendorId != null) {
      await _loadListings(_selectedVendorId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Listings refreshed successfully'),
            backgroundColor: Color(0xFF10B981),
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showCreateVendorDialog() {
    final theme = Theme.of(context);
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Create Vendor Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Vendor Name',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Business Address',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () async {
              try {
                await _marketplaceService.createVendor(
                  name: nameController.text,
                  contactEmail: emailController.text,
                  contactPhone: phoneController.text,
                  address: addressController.text,
                );
                if (mounted) {
                  Navigator.pop(context);
                  await _loadVendorData();
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to create vendor: $e'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  void _showAddListingDialog() {
    showDialog(
      context: context,
      builder: (context) => AddListingDialogWidget(
        vendorId: _selectedVendorId!,
        onListingCreated: () async {
          await _loadListings(_selectedVendorId!);
        },
      ),
    );
  }

  void _showUpdateStockDialog(Map<String, dynamic> listing) {
    final theme = Theme.of(context);
    final stockController = TextEditingController(
      text: listing['current_stock'].toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Update Stock - ${listing['marketplace_products']['product_name']}',
        ),
        content: TextField(
          controller: stockController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Current Stock',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                final newStock = int.tryParse(stockController.text) ?? 0;
                String availabilityStatus;
                if (newStock == 0) {
                  availabilityStatus = 'out_of_stock';
                } else if (newStock < 10) {
                  availabilityStatus = 'low_stock';
                } else {
                  availabilityStatus = 'in_stock';
                }

                await _marketplaceService.updateMarketplaceListing(
                  listingId: listing['id'] as String,
                  currentStock: newStock,
                  availabilityStatus: availabilityStatus,
                );

                if (mounted) {
                  Navigator.pop(context);
                  await _loadListings(_selectedVendorId!);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Stock updated successfully'),
                      backgroundColor: Color(0xFF10B981),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to update stock: $e'),
                      backgroundColor: theme.colorScheme.error,
                    ),
                  );
                }
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _toggleVisibility(Map<String, dynamic> listing) async {
    final currentStatus = listing['listing_status'] as String;
    final newStatus = currentStatus == 'active' ? 'pending' : 'active';

    try {
      await _marketplaceService.updateMarketplaceListing(
        listingId: listing['id'] as String,
        listingStatus: newStatus,
      );
      await _loadListings(_selectedVendorId!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Listing ${newStatus == 'active' ? 'activated' : 'deactivated'}',
            ),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to toggle visibility: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header with statistics
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      DBCBackButton(
                        onPressed: () => Navigator.pop(context),
                        iconColor: theme.colorScheme.onSurface,
                        backgroundColor: Colors.white,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        'Vendor Management',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  if (_statistics != null) ...[
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Active',
                            _statistics!['active_listings'].toString(),
                            const Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Total',
                            _statistics!['total_listings'].toString(),
                            theme.colorScheme.primary,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Views',
                            _statistics!['total_views'].toString(),
                            const Color(0xFFFBBF24),
                          ),
                        ),
                      ],
                    ),
                  ],
                  SizedBox(height: 2.h),
                  // Status segmented control
                  Row(
                    children: [
                      Expanded(child: _buildStatusChip('Active', 'active')),
                      SizedBox(width: 2.w),
                      Expanded(child: _buildStatusChip('Pending', 'pending')),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: _buildStatusChip('Out of Stock', 'out_of_stock'),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  // Search
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search products, SKU...',
                      prefixIcon: CustomIconWidget(
                        iconName: 'search',
                        color: theme.colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ],
              ),
            ),
            // Listings
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: _listings.isEmpty
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
                                    'No listings found',
                                    style:
                                        theme.textTheme.titleMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              padding: EdgeInsets.all(4.w),
                              itemCount: _listings.length,
                              itemBuilder: (context, index) {
                                final listing = _listings[index];
                                return VendorListingCardWidget(
                                  listing: listing,
                                  onUpdateStock: () =>
                                      _showUpdateStockDialog(listing),
                                  onToggleVisibility: () =>
                                      _toggleVisibility(listing),
                                );
                              },
                            ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: _selectedVendorId != null
          ? FloatingActionButton.extended(
              onPressed: _showAddListingDialog,
              icon: CustomIconWidget(
                iconName: 'add',
                color: theme.colorScheme.onPrimary,
                size: 24,
              ),
              label: Text(
                'Add Product',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: theme.colorScheme.onPrimary,
                ),
              ),
            )
          : null,
      bottomNavigationBar: CustomBottomBar(
        currentIndex: 2,
        onTap: (index) {
          if (index != 2) {
            final routes = [
              '/business-dashboard',
              '/live-camera-view',
              '/inventory-management',
              '/staff-management',
              '/business-dashboard',
            ];
            Navigator.pushReplacementNamed(context, routes[index]);
          }
        },
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label, String status) {
    final theme = Theme.of(context);
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedStatus = status;
        });
        if (_selectedVendorId != null) {
          _loadListings(_selectedVendorId!);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.h),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isSelected
                ? theme.colorScheme.onPrimary
                : theme.colorScheme.onSurface,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
