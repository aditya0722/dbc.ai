import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../services/marketplace_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/order_card_widget.dart';
import './widgets/status_filter_chip_widget.dart';

class OrderManagementHub extends StatefulWidget {
  const OrderManagementHub({super.key});

  @override
  State<OrderManagementHub> createState() => _OrderManagementHubState();
}

class _OrderManagementHubState extends State<OrderManagementHub>
    with SingleTickerProviderStateMixin {
  final MarketplaceService _marketplaceService = MarketplaceService();
  late TabController _tabController;

  List<dynamic> _orders = [];
  bool _isLoading = false;
  String _selectedStatus = 'all';

  final List<String> _statuses = [
    'all',
    'pending',
    'confirmed',
    'shipped',
    'delivered',
    'cancelled',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadOrders();
      }
    });
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final orders =
          _tabController.index == 0
              ? await _marketplaceService.getMyOrders(
                status: _selectedStatus == 'all' ? null : _selectedStatus,
              )
              : await _marketplaceService.getMySales(
                status: _selectedStatus == 'all' ? null : _selectedStatus,
              );

      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (error) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load orders: $error')),
        );
      }
    }
  }

  void _showOrderDetails(dynamic order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => _OrderDetailsSheet(
            order: order,
            isSeller: _tabController.index == 1,
            onStatusUpdate: (newStatus) async {
              try {
                await _marketplaceService.updateOrderStatus(
                  order['id'],
                  newStatus,
                );
                _loadOrders();
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Order status updated to $newStatus'),
                    ),
                  );
                }
              } catch (error) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update status: $error')),
                  );
                }
              }
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Order Management',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'My Orders'), Tab(text: 'My Sales')],
        ),
      ),
      body: Column(
        children: [
          // Status filter chips
          SizedBox(
            height: 6.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              itemCount: _statuses.length,
              itemBuilder: (context, index) {
                return StatusFilterChipWidget(
                  label: _statuses[index],
                  isSelected: _selectedStatus == _statuses[index],
                  onTap: () {
                    setState(() => _selectedStatus = _statuses[index]);
                    _loadOrders();
                  },
                );
              },
            ),
          ),

          // Orders list
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildOrdersList(), _buildOrdersList()],
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

  Widget _buildOrdersList() {
    final theme = Theme.of(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_orders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'receipt_long',
              color: theme.colorScheme.onSurfaceVariant,
              size: 64,
            ),
            SizedBox(height: 2.h),
            Text(
              'No orders found',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadOrders,
      child: ListView.builder(
        padding: EdgeInsets.all(4.w),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          return OrderCardWidget(
            order: _orders[index],
            isSeller: _tabController.index == 1,
            onTap: () => _showOrderDetails(_orders[index]),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

// Order details bottom sheet
class _OrderDetailsSheet extends StatelessWidget {
  final dynamic order;
  final bool isSeller;
  final Function(String) onStatusUpdate;

  const _OrderDetailsSheet({
    required this.order,
    required this.isSeller,
    required this.onStatusUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final product = order['product'];
    final otherParty = isSeller ? order['buyer'] : order['seller'];

    return Container(
      height: 85.h,
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
                  'Order Details',
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
                  // Product info
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.0),
                        child: CustomImageWidget(
                          imageUrl: product['image_url'] ?? '',
                          width: 20.w,
                          height: 20.w,
                          fit: BoxFit.cover,
                          semanticLabel: product['title'] ?? 'Product',
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['title'] ?? '',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 0.5.h),
                            Text(
                              'Quantity: ${order['quantity']}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            Text(
                              'Total: \$${order['total_price']?.toStringAsFixed(2)}',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),

                  // Status
                  _buildInfoRow(
                    context,
                    'Status',
                    order['status'] ?? 'Unknown',
                  ),
                  _buildInfoRow(
                    context,
                    'Order ID',
                    order['id']?.substring(0, 8) ?? 'N/A',
                  ),
                  _buildInfoRow(
                    context,
                    'Order Date',
                    order['created_at']?.substring(0, 10) ?? 'N/A',
                  ),

                  if (order['delivery_date'] != null)
                    _buildInfoRow(
                      context,
                      'Delivery Date',
                      order['delivery_date']?.substring(0, 10),
                    ),

                  if (order['delivery_address'] != null)
                    _buildInfoRow(
                      context,
                      'Delivery Address',
                      order['delivery_address'],
                    ),

                  SizedBox(height: 2.h),

                  // Contact info
                  Text(
                    isSeller ? 'Buyer Information' : 'Seller Information',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  _buildInfoRow(
                    context,
                    'Name',
                    otherParty['full_name'] ?? 'Unknown',
                  ),
                  _buildInfoRow(
                    context,
                    'Phone',
                    otherParty['phone'] ?? 'Not provided',
                  ),

                  if (order['notes'] != null &&
                      order['notes'].toString().isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Text(
                      'Notes',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Text(order['notes'], style: theme.textTheme.bodyMedium),
                  ],

                  if (isSeller &&
                      order['status'] != 'delivered' &&
                      order['status'] != 'cancelled') ...[
                    SizedBox(height: 3.h),
                    Text(
                      'Update Order Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Wrap(
                      spacing: 2.w,
                      runSpacing: 1.h,
                      children: [
                        if (order['status'] == 'pending')
                          ElevatedButton(
                            onPressed: () {
                              onStatusUpdate('confirmed');
                              Navigator.pop(context);
                            },
                            child: const Text('Confirm Order'),
                          ),
                        if (order['status'] == 'confirmed')
                          ElevatedButton(
                            onPressed: () {
                              onStatusUpdate('shipped');
                              Navigator.pop(context);
                            },
                            child: const Text('Mark as Shipped'),
                          ),
                        if (order['status'] == 'shipped')
                          ElevatedButton(
                            onPressed: () {
                              onStatusUpdate('delivered');
                              Navigator.pop(context);
                            },
                            child: const Text('Mark as Delivered'),
                          ),
                        OutlinedButton(
                          onPressed: () {
                            onStatusUpdate('cancelled');
                            Navigator.pop(context);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEF4444),
                          ),
                          child: const Text('Cancel Order'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 35.w,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
