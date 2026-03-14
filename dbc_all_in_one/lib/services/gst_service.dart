import './supabase_service.dart';
import 'dart:convert';
import 'dart:io' if (dart.library.io) 'dart:io';
import 'package:universal_html/html.dart' as html;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';

/// Service for managing GST filing operations with Supabase
class GSTService {
  final _client = SupabaseService.instance.client;

  /// Get all GST returns for current user with optional filtering
  Future<List<Map<String, dynamic>>> getGSTReturns({
    String? status,
    String? periodType,
  }) async {
    try {
      var query = _client.from('gst_returns').select('*');

      if (status != null) {
        query = query.eq('filing_status', status);
      }

      if (periodType != null) {
        query = query.eq('period_type', periodType);
      }

      final response =
          await query.order('period_start_date', ascending: false).limit(50);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch GST returns: $error');
    }
  }

  /// Get GST return by ID
  Future<Map<String, dynamic>?> getGSTReturnById(String returnId) async {
    try {
      final response = await _client
          .from('gst_returns')
          .select('*')
          .eq('id', returnId)
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch GST return: $error');
    }
  }

  /// Get transactions for a specific GST return
  Future<List<Map<String, dynamic>>> getGSTTransactions(String returnId) async {
    try {
      final response = await _client
          .from('gst_transactions')
          .select('*')
          .eq('gst_return_id', returnId)
          .order('transaction_date', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch GST transactions: $error');
    }
  }

  /// Get current period GST summary
  Future<Map<String, dynamic>> getCurrentPeriodSummary() async {
    try {
      final now = DateTime.now();
      final startOfQuarter = DateTime(
        now.year,
        ((now.month - 1) ~/ 3) * 3 + 1,
        1,
      );
      final endOfQuarter = DateTime(now.year, startOfQuarter.month + 3, 0);

      var query = _client.from('gst_returns').select('*').gte(
            'period_start_date',
            startOfQuarter.toIso8601String().split('T')[0],
          );

      query = query.lte(
        'period_end_date',
        endOfQuarter.toIso8601String().split('T')[0],
      );

      final response = await query.maybeSingle();

      if (response == null) {
        return {
          'total_sales': 0.0,
          'total_purchases': 0.0,
          'input_tax_credit': 0.0,
          'gst_payable': 0.0,
        };
      }

      return {
        'total_sales': response['total_sales'] ?? 0.0,
        'total_purchases': response['total_purchases'] ?? 0.0,
        'input_tax_credit': response['input_tax_credit'] ?? 0.0,
        'gst_payable': response['gst_payable'] ?? 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch current period summary: $error');
    }
  }

  /// Get upcoming filing deadlines
  Future<List<Map<String, dynamic>>> getUpcomingDeadlines() async {
    try {
      final now = DateTime.now();
      final thirtyDaysLater = now.add(const Duration(days: 30));

      var query = _client
          .from('gst_returns')
          .select('*')
          .gte('filing_deadline', now.toIso8601String().split('T')[0]);

      query = query.lte(
        'filing_deadline',
        thirtyDaysLater.toIso8601String().split('T')[0],
      );

      final response =
          await query.order('filing_deadline', ascending: true).limit(10);

      return List<Map<String, dynamic>>.from(response);
    } catch (error) {
      throw Exception('Failed to fetch upcoming deadlines: $error');
    }
  }

  /// Get GST filing settings for current user
  Future<Map<String, dynamic>?> getGSTSettings() async {
    try {
      final response =
          await _client.from('gst_filing_settings').select('*').maybeSingle();

      return response;
    } catch (error) {
      throw Exception('Failed to fetch GST settings: $error');
    }
  }

  /// Create or update GST return
  Future<Map<String, dynamic>> upsertGSTReturn(
    Map<String, dynamic> returnData,
  ) async {
    try {
      final response = await _client
          .from('gst_returns')
          .upsert(returnData)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to save GST return: $error');
    }
  }

  /// Submit GST return for filing
  Future<Map<String, dynamic>> submitGSTReturn(
    String returnId,
    String acknowledgmentNumber,
  ) async {
    try {
      final response = await _client
          .from('gst_returns')
          .update({
            'filing_status': 'filed',
            'filed_date': DateTime.now().toIso8601String(),
            'acknowledgment_number': acknowledgmentNumber,
          })
          .eq('id', returnId)
          .select()
          .single();

      return response;
    } catch (error) {
      throw Exception('Failed to submit GST return: $error');
    }
  }

  /// Get GST statistics
  Future<Map<String, dynamic>> getGSTStatistics() async {
    try {
      final totalReturnsData =
          await _client.from('gst_returns').select('id').count();

      final pendingReturnsData = await _client
          .from('gst_returns')
          .select('id')
          .eq('filing_status', 'pending')
          .count();

      final filedReturnsData = await _client
          .from('gst_returns')
          .select('id')
          .eq('filing_status', 'filed')
          .count();

      return {
        'total_returns': totalReturnsData.count ?? 0,
        'pending_returns': pendingReturnsData.count ?? 0,
        'filed_returns': filedReturnsData.count ?? 0,
      };
    } catch (error) {
      throw Exception('Failed to fetch GST statistics: $error');
    }
  }

  /// Generate GST return from invoices
  Future<Map<String, dynamic>> generateGSTReturnFromInvoices({
    required DateTime startDate,
    required DateTime endDate,
    required String periodType,
  }) async {
    try {
      var query = _client
          .from('invoices')
          .select('*')
          .gte('issue_date', startDate.toIso8601String().split('T')[0]);

      query = query.lte('issue_date', endDate.toIso8601String().split('T')[0]);

      final invoices = await query;

      double totalSales = 0;
      double totalTax = 0;

      for (final invoice in invoices) {
        totalSales += (invoice['subtotal'] as num?)?.toDouble() ?? 0.0;
        totalTax += (invoice['tax_amount'] as num?)?.toDouble() ?? 0.0;
      }

      final gstPayable = totalTax;

      return {
        'total_sales': totalSales,
        'output_tax': totalTax,
        'gst_payable': gstPayable,
        'invoice_count': invoices.length,
      };
    } catch (error) {
      throw Exception('Failed to generate GST return: $error');
    }
  }

  /// Get return summary for date range
  Future<Map<String, dynamic>> getReturnSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      var query = _client.from('gst_returns').select('*').gte(
            'period_start_date',
            startDate.toIso8601String().split('T')[0],
          );

      query = query.lte(
        'period_end_date',
        endDate.toIso8601String().split('T')[0],
      );

      final response = await query;

      double totalSales = 0;
      double totalPurchases = 0;
      double outputTax = 0;
      double inputTaxCredit = 0;
      double gstPayable = 0;

      for (final record in response) {
        totalSales += (record['total_sales'] as num?)?.toDouble() ?? 0.0;
        totalPurchases +=
            (record['total_purchases'] as num?)?.toDouble() ?? 0.0;
        outputTax += (record['output_tax'] as num?)?.toDouble() ?? 0.0;
        inputTaxCredit +=
            (record['input_tax_credit'] as num?)?.toDouble() ?? 0.0;
        gstPayable += (record['gst_payable'] as num?)?.toDouble() ?? 0.0;
      }

      return {
        'total_sales': totalSales,
        'total_purchases': totalPurchases,
        'output_tax': outputTax,
        'input_tax_credit': inputTaxCredit,
        'gst_payable': gstPayable,
      };
    } catch (error) {
      throw Exception('Failed to fetch return summary: $error');
    }
  }

  /// Get tax liability summary
  Future<Map<String, dynamic>> getTaxLiabilitySummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      var query = _client.from('gst_returns').select('*').gte(
            'period_start_date',
            startDate.toIso8601String().split('T')[0],
          );

      query = query.lte(
        'period_end_date',
        endDate.toIso8601String().split('T')[0],
      );

      final response = await query;

      double outputTax = 0;
      double inputTaxCredit = 0;

      for (final record in response) {
        outputTax += (record['output_tax'] as num?)?.toDouble() ?? 0.0;
        inputTaxCredit +=
            (record['input_tax_credit'] as num?)?.toDouble() ?? 0.0;
      }

      final netLiability = outputTax - inputTaxCredit;

      return {
        'output_tax': outputTax,
        'input_tax_credit': inputTaxCredit,
        'net_liability': netLiability > 0 ? netLiability : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch tax liability: $error');
    }
  }

  /// Get input credit summary
  Future<Map<String, dynamic>> getInputCreditSummary({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      var query = _client.from('gst_returns').select('*').gte(
            'period_start_date',
            startDate.toIso8601String().split('T')[0],
          );

      query = query.lte(
        'period_end_date',
        endDate.toIso8601String().split('T')[0],
      );

      final response = await query;

      double totalItcClaimed = 0;
      double itcUtilized = 0;

      for (final record in response) {
        final itc = (record['input_tax_credit'] as num?)?.toDouble() ?? 0.0;
        totalItcClaimed += itc;
        if (record['filing_status'] == 'filed') {
          itcUtilized += itc;
        }
      }

      final itcBalance = totalItcClaimed - itcUtilized;

      return {
        'total_itc_claimed': totalItcClaimed,
        'itc_utilized': itcUtilized,
        'itc_balance': itcBalance > 0 ? itcBalance : 0.0,
      };
    } catch (error) {
      throw Exception('Failed to fetch input credit summary: $error');
    }
  }

  /// Get compliance status
  Future<Map<String, dynamic>> getComplianceStatus() async {
    try {
      final stats = await getGSTStatistics();

      final totalReturns = stats['total_returns'] as int;
      final filedReturns = stats['filed_returns'] as int;

      final complianceScore =
          totalReturns > 0 ? ((filedReturns / totalReturns) * 100).round() : 0;

      return {
        'filed_returns': filedReturns,
        'pending_returns': stats['pending_returns'],
        'total_returns': totalReturns,
        'compliance_score': complianceScore,
      };
    } catch (error) {
      throw Exception('Failed to fetch compliance status: $error');
    }
  }

  /// Export report to PDF
  Future<void> exportReportToPDF({
    required String reportType,
    required Map<String, dynamic> data,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final pdf = pw.Document();
      final dateFormat = DateFormat('dd MMM yyyy');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  reportType,
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Period: ${dateFormat.format(startDate)} - ${dateFormat.format(endDate)}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 20),
                ...data.entries.map((entry) {
                  final value = entry.value is num
                      ? '₹${entry.value.toStringAsFixed(2)}'
                      : entry.value.toString();
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 12),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                      children: [
                        pw.Text(
                          _formatLabel(entry.key),
                          style: const pw.TextStyle(fontSize: 14),
                        ),
                        pw.Text(
                          value,
                          style: pw.TextStyle(
                            fontSize: 14,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );

      final filename =
          'GST_${reportType.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(await pdf.save());
      }
    } catch (error) {
      throw Exception('Failed to export PDF: $error');
    }
  }

  /// Export report to CSV (Excel-compatible)
  Future<void> exportReportToCSV({
    required String reportType,
    required Map<String, dynamic> data,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final dateFormat = DateFormat('dd MMM yyyy');

      final csvContent = StringBuffer();
      csvContent.writeln('$reportType Report');
      csvContent.writeln(
          'Period,$dateFormat.format(startDate) - ${dateFormat.format(endDate)}');
      csvContent.writeln('');
      csvContent.writeln('Metric,Value');

      for (final entry in data.entries) {
        final value = entry.value is num
            ? entry.value.toStringAsFixed(2)
            : entry.value.toString();
        csvContent.writeln('${_formatLabel(entry.key)},$value');
      }

      final filename =
          'GST_${reportType.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(DateTime.now())}.csv';

      if (kIsWeb) {
        final bytes = utf8.encode(csvContent.toString());
        final blob = html.Blob([bytes], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsString(csvContent.toString());
      }
    } catch (error) {
      throw Exception('Failed to export CSV: $error');
    }
  }

  /// Download return PDF
  Future<void> downloadReturnPDF(String returnId) async {
    try {
      final returnData = await getGSTReturnById(returnId);
      if (returnData == null) {
        throw Exception('Return not found');
      }

      final transactions = await getGSTTransactions(returnId);

      final pdf = pw.Document();
      final dateFormat = DateFormat('dd MMM yyyy');

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'GST Return',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Return Period: ${returnData['return_period']}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                pw.Text(
                  'Filing Status: ${returnData['filing_status']}',
                  style: const pw.TextStyle(fontSize: 14),
                ),
                if (returnData['acknowledgment_number'] != null)
                  pw.Text(
                    'ACK: ${returnData['acknowledgment_number']}',
                    style: const pw.TextStyle(fontSize: 14),
                  ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Summary',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                _buildPDFRow('Total Sales', returnData['total_sales']),
                _buildPDFRow('Total Purchases', returnData['total_purchases']),
                _buildPDFRow('Output Tax', returnData['output_tax']),
                _buildPDFRow(
                    'Input Tax Credit', returnData['input_tax_credit']),
                _buildPDFRow('Net GST Payable', returnData['gst_payable']),
                pw.SizedBox(height: 30),
                pw.Text(
                  'Transactions (${transactions.length})',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                ...transactions.take(10).map((txn) {
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8),
                    child: pw.Text(
                      '${txn['party_name']} - ${txn['invoice_number']} - ₹${txn['total_gst']}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      );

      final filename =
          'GST_Return_${returnData['return_period']}_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';

      if (kIsWeb) {
        final bytes = await pdf.save();
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', filename)
          ..click();
        html.Url.revokeObjectUrl(url);
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final file = File('${directory.path}/$filename');
        await file.writeAsBytes(await pdf.save());
      }
    } catch (error) {
      throw Exception('Failed to download return PDF: $error');
    }
  }

  pw.Widget _buildPDFRow(String label, dynamic value) {
    final displayValue =
        value is num ? '₹${value.toStringAsFixed(2)}' : value.toString();
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 14)),
          pw.Text(
            displayValue,
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatLabel(String key) {
    return key
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }
}
