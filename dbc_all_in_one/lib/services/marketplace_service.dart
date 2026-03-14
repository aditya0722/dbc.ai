import './supabase_service.dart';

class MarketplaceService {
  final _client = SupabaseService.instance.client;

  // Product operations
  Future<List<Map<String, dynamic>>> getAllProducts({
    String? category,
    String? searchQuery,
    String? condition,
    String? sortBy,
  }) async {
    try {
      var query = _client.from('vendor_product_listings').select(
        '''
            id,
            price_per_unit,
            current_stock,
            availability_status,
            min_order_quantity,
            delivery_time_days,
            location_proximity,
            certifications,
            listing_status,
            product:marketplace_products!vendor_product_listings_product_id_fkey(
              id,
              product_name,
              description,
              base_unit,
              category,
              image_url,
              is_active
            ),
            vendor:vendors!vendor_product_listings_vendor_id_fkey(
              id,
              vendor_name,
              business_address,
              contact_phone,
              rating
            )
            ''',
      );

      // Apply filters
      if (category != null && category != 'all') {
        query = query.eq('product.category', category);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.ilike('product.product_name', '%$searchQuery%');
      }

      query = query.eq('listing_status', 'active');
      query = query.eq('product.is_active', true);

      // Execute query
      final response = await query;

      // Transform data to match UI expectations
      final List<Map<String, dynamic>> transformedProducts = [];

      for (final item in response) {
        final product = item['product'] as Map<String, dynamic>?;
        final vendor = item['vendor'] as Map<String, dynamic>?;

        if (product != null) {
          transformedProducts.add({
            'id': item['id'],
            'title': product['product_name'],
            'description': product['description'],
            'price': item['price_per_unit'],
            'unit': product['base_unit'],
            'category': product['category'],
            'image_url': product['image_url'],
            'condition': 'new', // Default for raw materials
            'status': item['listing_status'],
            'location': item['location_proximity'] ?? 'Unknown',
            'is_featured': (vendor?['rating'] ?? 0) >= 4.7,
            'stock': item['current_stock'],
            'min_order': item['min_order_quantity'],
            'delivery_days': item['delivery_time_days'],
            'certifications': item['certifications'] ?? [],
            'vendor_name': vendor?['vendor_name'],
            'vendor_address': vendor?['business_address'],
            'vendor_phone': vendor?['contact_phone'],
            'vendor_rating': vendor?['rating'],
          });
        }
      }

      // Apply sorting
      if (sortBy == 'price_low') {
        transformedProducts.sort(
          (a, b) => (a['price'] as num).compareTo(b['price'] as num),
        );
      } else if (sortBy == 'price_high') {
        transformedProducts.sort(
          (a, b) => (b['price'] as num).compareTo(a['price'] as num),
        );
      } else if (sortBy == 'featured') {
        transformedProducts.sort((a, b) {
          final aFeatured = a['is_featured'] == true ? 1 : 0;
          final bFeatured = b['is_featured'] == true ? 1 : 0;
          return bFeatured.compareTo(aFeatured);
        });
      }

      return transformedProducts;
    } catch (error) {
      throw Exception('Failed to fetch products: $error');
    }
  }

  Future<Map<String, dynamic>> getProductDetails(String productId) async {
    try {
      final response = await _client
          .from('vendor_product_listings')
          .select(
            '''
            id,
            price_per_unit,
            current_stock,
            availability_status,
            min_order_quantity,
            delivery_time_days,
            location_proximity,
            certifications,
            bulk_pricing,
            listing_status,
            product:marketplace_products!vendor_product_listings_product_id_fkey(
              id,
              product_name,
              description,
              base_unit,
              category,
              image_url,
              is_active
            ),
            vendor:vendors!vendor_product_listings_vendor_id_fkey(
              id,
              vendor_name,
              business_address,
              contact_phone,
              contact_email,
              rating,
              total_reviews
            )
            ''',
          )
          .eq('id', productId)
          .single();

      final product = response['product'] as Map<String, dynamic>;
      final vendor = response['vendor'] as Map<String, dynamic>;

      return {
        'id': response['id'],
        'title': product['product_name'],
        'description': product['description'],
        'price': response['price_per_unit'],
        'unit': product['base_unit'],
        'category': product['category'],
        'image_url': product['image_url'],
        'condition': 'new',
        'status': response['listing_status'],
        'location': response['location_proximity'] ?? 'Unknown',
        'stock': response['current_stock'],
        'min_order': response['min_order_quantity'],
        'delivery_days': response['delivery_time_days'],
        'certifications': response['certifications'] ?? [],
        'bulk_pricing': response['bulk_pricing'],
        'availability_status': response['availability_status'],
        'vendor': {
          'id': vendor['id'],
          'name': vendor['vendor_name'],
          'address': vendor['business_address'],
          'phone': vendor['contact_phone'],
          'email': vendor['contact_email'],
          'rating': vendor['rating'],
          'total_reviews': vendor['total_reviews'],
        },
      };
    } catch (error) {
      throw Exception('Failed to fetch product details: $error');
    }
  }

  Future<List<dynamic>> getProductReviews(String productId) async {
    try {
      final response = await _client
          .from('marketplace_reviews')
          .select(
            '*, reviewer:user_profiles!marketplace_reviews_reviewer_id_fkey(id, full_name)',
          )
          .eq('product_id', productId)
          .order('created_at', ascending: false);
      return response;
    } catch (error) {
      throw Exception('Failed to fetch reviews: $error');
    }
  }

  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> productData,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      productData['seller_id'] = userId;

      final response = await _client
          .from('marketplace_products')
          .insert(productData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create product: $error');
    }
  }

  Future<Map<String, dynamic>> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await _client
          .from('marketplace_products')
          .update(updates)
          .eq('id', productId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update product: $error');
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _client.from('marketplace_products').delete().eq('id', productId);
    } catch (error) {
      throw Exception('Failed to delete product: $error');
    }
  }

  // Order operations
  Future<Map<String, dynamic>> createOrder(
    Map<String, dynamic> orderData,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      orderData['buyer_id'] = userId;

      final response = await _client
          .from('marketplace_orders')
          .insert(orderData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create order: $error');
    }
  }

  Future<List<dynamic>> getMyOrders({String? status}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('marketplace_orders')
          .select(
            '*, product:marketplace_products!marketplace_orders_product_id_fkey(title, image_url), seller:user_profiles!marketplace_orders_seller_id_fkey(full_name, phone)',
          )
          .eq('buyer_id', userId);

      if (status != null && status != 'all') {
        query = query.eq('status', status);
      }

      return await query.order('created_at', ascending: false);
    } catch (error) {
      throw Exception('Failed to fetch orders: $error');
    }
  }

  Future<List<dynamic>> getMySales({String? status}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      var query = _client
          .from('marketplace_orders')
          .select(
            '*, product:marketplace_products!marketplace_orders_product_id_fkey(title, image_url), buyer:user_profiles!marketplace_orders_buyer_id_fkey(full_name, phone)',
          )
          .eq('seller_id', userId);

      if (status != null && status != 'all') {
        query = query.eq('status', status);
      }

      return await query.order('created_at', ascending: false);
    } catch (error) {
      throw Exception('Failed to fetch sales: $error');
    }
  }

  Future<Map<String, dynamic>> updateOrderStatus(
    String orderId,
    String newStatus,
  ) async {
    try {
      final response = await _client
          .from('marketplace_orders')
          .update({'status': newStatus})
          .eq('id', orderId)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to update order status: $error');
    }
  }

  // Review operations
  Future<Map<String, dynamic>> createReview(
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) throw Exception('User not authenticated');

      reviewData['reviewer_id'] = userId;

      final response = await _client
          .from('marketplace_reviews')
          .insert(reviewData)
          .select()
          .single();
      return response;
    } catch (error) {
      throw Exception('Failed to create review: $error');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getMarketplaceStats() async {
    try {
      final productsData = await _client
          .from('marketplace_products')
          .select('id')
          .eq('is_active', true)
          .count();

      final listingsData = await _client
          .from('vendor_product_listings')
          .select('id')
          .eq('listing_status', 'active')
          .count();

      return {
        'active_products': productsData.count ?? 0,
        'active_listings': listingsData.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch marketplace stats: $error');
    }
  }
}
