import './supabase_service.dart';

/// Service for managing invoicing operations with Supabase
class InvoicingService {
  final _client = SupabaseService.instance.client;

  /// Fetches all available invoice templates
  Future<List<Map<String, dynamic>>> getInvoiceTemplates() async {
    try {
      final response = await _client
          .from('invoice_templates')
          .select()
          .eq('is_active', true)
          .order('category')
          .order('template_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch invoice templates: $error');
    }
  }

  /// Fetches templates by category
  Future<List<Map<String, dynamic>>> getTemplatesByCategory(
      String category) async {
    try {
      final response = await _client
          .from('invoice_templates')
          .select()
          .eq('category', category)
          .eq('is_active', true)
          .order('template_name');
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch templates by category: $error');
    }
  }

  /// Creates a new invoice from template
  Future<Map<String, dynamic>> createInvoiceFromTemplate({
    required String templateId,
    required String customerName,
    String? customerEmail,
    String? customerPhone,
    String? customerAddress,
    required DateTime dueDate,
    String? notes,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      // Generate invoice number
      final invoiceNumberResponse =
          await _client.rpc('generate_invoice_number');
      final invoiceNumber = invoiceNumberResponse as String;

      final invoiceData = {
        'invoice_number': invoiceNumber,
        'template_id': templateId,
        'created_by': userId,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_phone': customerPhone,
        'customer_address': customerAddress,
        'issue_date': DateTime.now().toIso8601String(),
        'due_date': dueDate.toIso8601String(),
        'status': 'draft',
        'notes': notes,
      };

      final response =
          await _client.from('invoices').insert(invoiceData).select().single();
      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to create invoice: $error');
    }
  }

  /// Fetches user invoices with optional status filter
  Future<List<Map<String, dynamic>>> getUserInvoices(
      {String? statusFilter}) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      var query = _client
          .from('invoices')
          .select('*, invoice_templates(template_name, category)')
          .eq('created_by', userId);

      if (statusFilter != null) {
        query = query.eq('status', statusFilter);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch invoices: $error');
    }
  }

  /// Fetches invoice details with items
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    try {
      final response = await _client
          .from('invoices')
          .select(
              '*, invoice_templates(template_name, category, template_data), invoice_items(*)')
          .eq('id', invoiceId)
          .single();
      return Map<String, dynamic>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch invoice details: $error');
    }
  }

  /// Adds items to invoice
  Future<void> addInvoiceItems(
      String invoiceId, List<Map<String, dynamic>> items) async {
    try {
      final itemsWithInvoiceId = items
          .map((item) => {
                ...item,
                'invoice_id': invoiceId,
              })
          .toList();

      await _client.from('invoice_items').insert(itemsWithInvoiceId);

      // Recalculate totals
      await _recalculateInvoiceTotals(invoiceId);
    } catch (error) {
      throw Exception('Failed to add invoice items: $error');
    }
  }

  /// Updates invoice status
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    try {
      await _client
          .from('invoices')
          .update({'status': status}).eq('id', invoiceId);
    } catch (error) {
      throw Exception('Failed to update invoice status: $error');
    }
  }

  /// Deletes invoice
  Future<void> deleteInvoice(String invoiceId) async {
    try {
      await _client.from('invoices').delete().eq('id', invoiceId);
    } catch (error) {
      throw Exception('Failed to delete invoice: $error');
    }
  }

  /// Private helper to recalculate invoice totals
  Future<void> _recalculateInvoiceTotals(String invoiceId) async {
    try {
      final items = await _client
          .from('invoice_items')
          .select()
          .eq('invoice_id', invoiceId);

      double subtotal = 0;
      for (var item in items) {
        subtotal += (item['total_price'] as num).toDouble();
      }

      final taxRate = 0.08; // 8% tax
      final taxAmount = subtotal * taxRate;
      final totalAmount = subtotal + taxAmount;

      await _client.from('invoices').update({
        'subtotal': subtotal,
        'tax_amount': taxAmount,
        'total_amount': totalAmount,
      }).eq('id', invoiceId);
    } catch (error) {
      throw Exception('Failed to recalculate totals: $error');
    }
  }

  /// Gets invoice statistics
  Future<Map<String, dynamic>> getInvoiceStatistics() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final totalResponse = await _client
          .from('invoices')
          .select()
          .eq('created_by', userId)
          .count();

      final draftResponse = await _client
          .from('invoices')
          .select()
          .eq('created_by', userId)
          .eq('status', 'draft')
          .count();

      final paidResponse = await _client
          .from('invoices')
          .select()
          .eq('created_by', userId)
          .eq('status', 'paid')
          .count();

      final overdueResponse = await _client
          .from('invoices')
          .select()
          .eq('created_by', userId)
          .eq('status', 'overdue')
          .count();

      return {
        'total': totalResponse.count ?? 0,
        'draft': draftResponse.count ?? 0,
        'paid': paidResponse.count ?? 0,
        'overdue': overdueResponse.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to get statistics: $error');
    }
  }

  /// Fetches invoices filtered by date range and customer
  Future<List<Map<String, dynamic>>> getFilteredInvoices({
    String? statusFilter,
    DateTime? startDate,
    DateTime? endDate,
    String? customerSearch,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      var query = _client
          .from('invoices')
          .select('*, invoice_templates(template_name, category)')
          .eq('created_by', userId);

      if (statusFilter != null && statusFilter != 'all') {
        query = query.eq('status', statusFilter);
      }

      if (startDate != null) {
        query = query.gte('issue_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('issue_date', endDate.toIso8601String());
      }

      if (customerSearch != null && customerSearch.isNotEmpty) {
        query = query.or(
            'customer_name.ilike.%$customerSearch%,invoice_number.ilike.%$customerSearch%');
      }

      final response = await query.order('issue_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch filtered invoices: $error');
    }
  }

  /// Duplicate invoice
  Future<Map<String, dynamic>> duplicateInvoice(String invoiceId) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('User not authenticated');
      }

      final originalInvoice = await getInvoiceDetails(invoiceId);

      final invoiceNumberResponse =
          await _client.rpc('generate_invoice_number');
      final invoiceNumber = invoiceNumberResponse as String;

      final duplicatedData = {
        'invoice_number': invoiceNumber,
        'template_id': originalInvoice['template_id'],
        'created_by': userId,
        'customer_name': originalInvoice['customer_name'],
        'customer_email': originalInvoice['customer_email'],
        'customer_phone': originalInvoice['customer_phone'],
        'customer_address': originalInvoice['customer_address'],
        'issue_date': DateTime.now().toIso8601String(),
        'due_date':
            DateTime.now().add(const Duration(days: 30)).toIso8601String(),
        'status': 'draft',
        'notes': originalInvoice['notes'],
      };

      final newInvoice = await _client
          .from('invoices')
          .insert(duplicatedData)
          .select()
          .single();

      if (originalInvoice['invoice_items'] != null) {
        final items =
            List<Map<String, dynamic>>.from(originalInvoice['invoice_items']);
        final newItems = items
            .map((item) => {
                  'invoice_id': newInvoice['id'],
                  'item_name': item['item_name'],
                  'description': item['description'],
                  'quantity': item['quantity'],
                  'unit_price': item['unit_price'],
                  'total_price': item['total_price'],
                })
            .toList();

        await _client.from('invoice_items').insert(newItems);
        await _recalculateInvoiceTotals(newInvoice['id']);
      }

      return Map<String, dynamic>.from(newInvoice);
    } catch (error) {
      throw Exception('Failed to duplicate invoice: $error');
    }
  }
}
