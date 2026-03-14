import '../core/app_export.dart';
import './supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GlobalSearchService {
  final SupabaseClient _supabase = SupabaseService.instance.client;

  // Search across all modules
  Future<Map<String, List<Map<String, dynamic>>>> searchAll(
    String query, {
    DateTime? startDate,
    DateTime? endDate,
    String? statusFilter,
    double? minAmount,
    double? maxAmount,
  }) async {
    try {
      final results = await Future.wait([
        searchInvoices(query,
            startDate: startDate,
            endDate: endDate,
            statusFilter: statusFilter,
            minAmount: minAmount,
            maxAmount: maxAmount),
        searchInventory(query, statusFilter: statusFilter),
        searchStaff(query),
        searchVendors(query, minRating: minAmount),
        searchOrders(query, startDate: startDate, endDate: endDate),
      ]);

      return {
        'invoices': results[0],
        'inventory': results[1],
        'staff': results[2],
        'vendors': results[3],
        'orders': results[4],
      };
    } catch (e) {
      return {
        'invoices': [],
        'inventory': [],
        'staff': [],
        'vendors': [],
        'orders': [],
      };
    }
  }

  // Search invoices
  Future<List<Map<String, dynamic>>> searchInvoices(
    String query, {
    DateTime? startDate,
    DateTime? endDate,
    String? statusFilter,
    double? minAmount,
    double? maxAmount,
  }) async {
    try {
      var queryBuilder = _supabase.from('invoices').select('*').or(
          'invoice_number.ilike.%$query%,customer_name.ilike.%$query%,customer_email.ilike.%$query%');

      if (startDate != null) {
        queryBuilder = queryBuilder.gte(
            'issue_date', startDate.toIso8601String().split('T')[0]);
      }
      if (endDate != null) {
        queryBuilder = queryBuilder.lte(
            'issue_date', endDate.toIso8601String().split('T')[0]);
      }
      if (statusFilter != null && statusFilter.isNotEmpty) {
        queryBuilder = queryBuilder.eq('status', statusFilter);
      }
      if (minAmount != null) {
        queryBuilder = queryBuilder.gte('total_amount', minAmount);
      }
      if (maxAmount != null) {
        queryBuilder = queryBuilder.lte('total_amount', maxAmount);
      }

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Search inventory/products
  Future<List<Map<String, dynamic>>> searchInventory(
    String query, {
    String? statusFilter,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('marketplace_products')
          .select('*, vendor_product_listings(*)')
          .or('product_name.ilike.%$query%,description.ilike.%$query%')
          .eq('is_active', true);

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Search staff
  Future<List<Map<String, dynamic>>> searchStaff(String query) async {
    try {
      final response = await _supabase
          .from('user_profiles')
          .select('*')
          .or('full_name.ilike.%$query%,email.ilike.%$query%,phone.ilike.%$query%,role.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Search vendors
  Future<List<Map<String, dynamic>>> searchVendors(
    String query, {
    double? minRating,
  }) async {
    try {
      var queryBuilder = _supabase.from('vendors').select('*').or(
          'vendor_name.ilike.%$query%,contact_email.ilike.%$query%,contact_phone.ilike.%$query%,business_address.ilike.%$query%');

      if (minRating != null) {
        queryBuilder = queryBuilder.gte('rating', minRating);
      }

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Search orders (using invoice_items as order items)
  Future<List<Map<String, dynamic>>> searchOrders(
    String query, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var queryBuilder = _supabase
          .from('invoice_items')
          .select('*, invoices(*)')
          .or('item_name.ilike.%$query%,description.ilike.%$query%');

      final response =
          await queryBuilder.order('created_at', ascending: false).limit(20);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Get search suggestions based on recent/popular searches
  List<String> getSearchSuggestions(String query) {
    if (query.isEmpty) {
      return [
        'show overdue invoices from last month',
        'find staff working today',
        'search high-rated vendors',
        'view pending orders',
        'list inventory items low in stock',
      ];
    }

    // Simple suggestion logic - in production this would use ML
    final suggestions = <String>[];
    if (query.toLowerCase().contains('invoice')) {
      suggestions
          .addAll(['overdue invoices', 'paid invoices', 'draft invoices']);
    } else if (query.toLowerCase().contains('staff')) {
      suggestions.addAll(['staff members', 'staff by department', 'new staff']);
    } else if (query.toLowerCase().contains('vendor')) {
      suggestions.addAll(
          ['verified vendors', 'top-rated vendors', 'vendor by location']);
    } else if (query.toLowerCase().contains('inventory')) {
      suggestions
          .addAll(['inventory items', 'low stock items', 'active products']);
    }

    return suggestions.take(3).toList();
  }

  // Calculate relevance score (simple implementation)
  double calculateRelevanceScore(Map<String, dynamic> item, String query) {
    final searchableFields = [
      item['name']?.toString() ?? '',
      item['customer_name']?.toString() ?? '',
      item['product_name']?.toString() ?? '',
      item['vendor_name']?.toString() ?? '',
      item['full_name']?.toString() ?? '',
    ];

    int matches = 0;
    final queryLower = query.toLowerCase();

    for (final field in searchableFields) {
      if (field.toLowerCase().contains(queryLower)) {
        matches++;
      }
    }

    return matches / searchableFields.length;
  }
}