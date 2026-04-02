import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import '../../widgets/dbc_back_button.dart';
import './widgets/category_chip_widget.dart';
import './widgets/search_header_widget.dart';
import './widgets/vendor_card_widget.dart';

/// Vendor Marketplace screen for business procurement
/// Enables efficient supplier discovery and ordering through mobile-optimized interface
class VendorMarketplace extends StatefulWidget {
  const VendorMarketplace({super.key});

  @override
  State<VendorMarketplace> createState() => _VendorMarketplaceState();
}

class _VendorMarketplaceState extends State<VendorMarketplace>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentBottomIndex = 0;
  String _selectedCategory = 'All';
  bool _isRefreshing = false;
  final TextEditingController _searchController = TextEditingController();

  // Mock vendor data
  final List<Map<String, dynamic>> _vendors = [
    {
      "id": 1,
      "name": "Fresh Foods Wholesale",
      "rating": 4.8,
      "deliveryTime": "2-4 hours",
      "commission": "5%",
      "category": "Food Supplies",
      "logo": "https://images.unsplash.com/photo-1702306456795-24410322485f",
      "semanticLabel":
          "Fresh produce display with colorful vegetables and fruits in wooden crates at a farmer's market",
      "isFavorite": true,
      "minOrder": "\$50",
      "paymentTerms": "Net 30"
    },
    {
      "id": 2,
      "name": "Kitchen Equipment Pro",
      "rating": 4.6,
      "deliveryTime": "1-2 days",
      "commission": "8%",
      "category": "Equipment",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1b801991c-1764668078116.png",
      "semanticLabel":
          "Modern commercial kitchen with stainless steel appliances and professional cooking equipment",
      "isFavorite": false,
      "minOrder": "\$200",
      "paymentTerms": "Net 15"
    },
    {
      "id": 3,
      "name": "CleanPro Supplies",
      "rating": 4.9,
      "deliveryTime": "Same day",
      "commission": "6%",
      "category": "Cleaning",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1790b3efe-1764670564239.png",
      "semanticLabel":
          "Organized cleaning supplies including spray bottles, brushes, and microfiber cloths on white shelves",
      "isFavorite": true,
      "minOrder": "\$30",
      "paymentTerms": "COD"
    },
    {
      "id": 4,
      "name": "Office Essentials Hub",
      "rating": 4.5,
      "deliveryTime": "3-5 hours",
      "commission": "7%",
      "category": "Office",
      "logo": "https://images.unsplash.com/photo-1424392904403-8e1c65a6133a",
      "semanticLabel":
          "Modern office workspace with laptop, notebooks, pens, and coffee cup on wooden desk",
      "isFavorite": false,
      "minOrder": "\$75",
      "paymentTerms": "Net 30"
    },
    {
      "id": 5,
      "name": "Maintenance Masters",
      "rating": 4.7,
      "deliveryTime": "4-6 hours",
      "commission": "9%",
      "category": "Maintenance",
      "logo": "https://images.unsplash.com/photo-1676311396794-f14881e9daaa",
      "semanticLabel":
          "Professional maintenance tools including wrench, screwdriver, and measuring tape on workbench",
      "isFavorite": false,
      "minOrder": "\$100",
      "paymentTerms": "Net 15"
    },
    {
      "id": 6,
      "name": "Organic Farm Direct",
      "rating": 4.9,
      "deliveryTime": "1-3 hours",
      "commission": "4%",
      "category": "Food Supplies",
      "logo":
          "https://img.rocket.new/generatedImages/rocket_gen_img_1e59e3328-1765273319614.png",
      "semanticLabel":
          "Fresh organic vegetables including tomatoes, lettuce, and carrots in wicker basket on rustic table",
      "isFavorite": true,
      "minOrder": "\$40",
      "paymentTerms": "COD"
    },
  ];

  final List<String> _categories = [
    'All',
    'Food Supplies',
    'Equipment',
    'Cleaning',
    'Office',
    'Maintenance'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredVendors {
    if (_selectedCategory == 'All') {
      return _vendors;
    }
    return _vendors
        .where((vendor) => vendor['category'] == _selectedCategory)
        .toList();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _isRefreshing = false);
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildFilterBottomSheet(),
    );
  }

  void _showVendorContextMenu(Map<String, dynamic> vendor) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildVendorContextMenu(vendor),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: DBCBackButton(
          onPressed: () => Navigator.maybePop(context),
          iconColor: theme.colorScheme.onSurface,
          backgroundColor: Colors.white,
        ),
        title: Text(
          'Vendor Marketplace',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Suppliers'),
            Tab(text: 'Marketplace'),
            Tab(text: 'Orders'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSuppliersTab(theme),
          _buildMarketplaceTab(theme),
          _buildOrdersTab(theme),
        ],
      ),
      bottomNavigationBar: CustomBottomBar(
        currentIndex: _currentBottomIndex,
        onTap: (index) {
          setState(() => _currentBottomIndex = index);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Add New Vendor Request'),
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'OK',
                onPressed: () {},
              ),
            ),
          );
        },
        icon: CustomIconWidget(
          iconName: 'add',
          color: theme.colorScheme.onPrimary,
          size: 24,
        ),
        label: Text(
          'Request Vendor',
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildSuppliersTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'business',
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Suppliers Directory',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'View your connected suppliers',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMarketplaceTab(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _handleRefresh,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: SearchHeaderWidget(
              searchController: _searchController,
              onFilterPressed: _showFilterBottomSheet,
              onVoicePressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Voice search activated'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 6.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                itemCount: _categories.length,
                separatorBuilder: (context, index) => SizedBox(width: 2.w),
                itemBuilder: (context, index) {
                  return CategoryChipWidget(
                    label: _categories[index],
                    isSelected: _selectedCategory == _categories[index],
                    onTap: () {
                      setState(() => _selectedCategory = _categories[index]);
                    },
                  );
                },
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.all(4.w),
            sliver: _isRefreshing
                ? SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.h),
                        child: CircularProgressIndicator(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  )
                : _filteredVendors.isEmpty
                    ? SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(8.h),
                            child: Column(
                              children: [
                                CustomIconWidget(
                                  iconName: 'search_off',
                                  color: theme.colorScheme.onSurfaceVariant,
                                  size: 64,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'No vendors found',
                                  style: theme.textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.75,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 2.h,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final vendor = _filteredVendors[index];
                            return VendorCardWidget(
                              vendor: vendor,
                              onTap: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Opening ${vendor['name']} catalog'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                              onLongPress: () => _showVendorContextMenu(vendor),
                              onQuickOrder: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Quick order from ${vendor['name']}'),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                            );
                          },
                          childCount: _filteredVendors.length,
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersTab(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: 'shopping_bag',
            color: theme.colorScheme.onSurfaceVariant,
            size: 64,
          ),
          SizedBox(height: 2.h),
          Text(
            'Order History',
            style: theme.textTheme.titleLarge,
          ),
          SizedBox(height: 1.h),
          Text(
            'Track your vendor orders',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filter Vendors',
                style: theme.textTheme.titleLarge,
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: theme.colorScheme.onSurface,
                  size: 24,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),
          _buildFilterOption(theme, 'Location Radius', '10 miles'),
          _buildFilterOption(theme, 'Delivery Speed', 'Same day'),
          _buildFilterOption(theme, 'Minimum Order', '\$50'),
          _buildFilterOption(theme, 'Payment Terms', 'Net 30'),
          _buildFilterOption(theme, 'Vendor Rating', '4.5+'),
          SizedBox(height: 3.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Apply Filters'),
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildFilterOption(ThemeData theme, String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 2.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyLarge,
          ),
          Row(
            children: [
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(width: 2.w),
              CustomIconWidget(
                iconName: 'chevron_right',
                color: theme.colorScheme.onSurfaceVariant,
                size: 20,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVendorContextMenu(Map<String, dynamic> vendor) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(6.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildContextMenuItem(
            theme,
            'favorite',
            vendor['isFavorite'] == true
                ? 'Remove from Favorites'
                : 'Add to Favorites',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(vendor['isFavorite'] == true
                      ? 'Removed from favorites'
                      : 'Added to favorites'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildContextMenuItem(
            theme,
            'star',
            'View Reviews',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening vendor reviews'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildContextMenuItem(
            theme,
            'phone',
            'Contact Directly',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Opening contact options'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          _buildContextMenuItem(
            theme,
            'block',
            'Block Vendor',
            () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Vendor blocked'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildContextMenuItem(
      ThemeData theme, String iconName, String label, VoidCallback onTap) {
    return ListTile(
      leading: CustomIconWidget(
        iconName: iconName,
        color: theme.colorScheme.onSurface,
        size: 24,
      ),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge,
      ),
      onTap: onTap,
    );
  }
}
