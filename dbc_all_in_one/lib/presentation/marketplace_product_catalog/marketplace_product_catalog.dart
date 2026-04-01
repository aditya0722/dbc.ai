import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/dbc_back_button.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/category_filter_widget.dart';
import './widgets/filter_drawer_widget.dart';
import './widgets/product_card_widget.dart';

class MarketplaceProductCatalog extends StatefulWidget {
  const MarketplaceProductCatalog({super.key});

  @override
  State<MarketplaceProductCatalog> createState() =>
      _MarketplaceProductCatalogState();
}

class _MarketplaceProductCatalogState extends State<MarketplaceProductCatalog> {
  final MarketplaceService _marketplaceService = MarketplaceService();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _products = [];
  bool _isLoading = false;
  String _selectedCategory = 'all';
  String _selectedCondition = 'all';
  String _sortBy = 'newest';

  final List<String> _categories = [
    'all',
    'raw_materials',
    'equipment',
    'finished_goods',
    'supplies',
    'electronics',
    'furniture',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final products = await _marketplaceService.getAllProducts(
        category: _selectedCategory,
        searchQuery: _searchController.text,
        condition: _selectedCondition,
        sortBy: _sortBy,
      );
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load products: $error')),
        );
      }
    }
  }

  void _showFilterDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterDrawerWidget(
        selectedCondition: _selectedCondition,
        selectedSort: _sortBy,
        onApplyFilters: (condition, sort) {
          setState(() {
            _selectedCondition = condition;
            _sortBy = sort;
          });
          _loadProducts();
        },
      ),
    );
  }

  void _navigateToProductDetails(dynamic product) {
    Navigator.pushNamed(
      context,
      '/marketplace-product-details',
      arguments: product['id'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: DBCBackButton(
          onPressed: () => Navigator.maybePop(context),
          iconColor: theme.colorScheme.onSurface,
          backgroundColor: Colors.white,
        ),
        title: Text(
          'Marketplace',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: CustomIconWidget(
              iconName: 'filter_list',
              color: theme.colorScheme.onSurface,
              size: 24,
            ),
            onPressed: _showFilterDrawer,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: EdgeInsets.all(4.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
                prefixIcon: CustomIconWidget(
                  iconName: 'search',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: CustomIconWidget(
                          iconName: 'close',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _loadProducts();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              onSubmitted: (value) => _loadProducts(),
            ),
          ),

          // Category filter chips
          SizedBox(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                return CategoryFilterWidget(
                  label: _categories[index],
                  isSelected: _selectedCategory == _categories[index],
                  onTap: () {
                    setState(() => _selectedCategory = _categories[index]);
                    _loadProducts();
                  },
                );
              },
            ),
          ),

          SizedBox(height: 1.h),

          // Products grid
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _products.isEmpty
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
                              'No products found',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadProducts,
                        child: GridView.builder(
                          padding: EdgeInsets.all(4.w),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 3.w,
                            mainAxisSpacing: 2.h,
                            childAspectRatio: 0.75,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            return ProductCardWidget(
                              product: _products[index],
                              onTap: () =>
                                  _navigateToProductDetails(_products[index]),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
